//
//  PKHImageCache.swift
//  PKHIC-Example
//
//  Created by Patrick Hanlon on 6/23/15.
//  Copyright (c) 2015 pkh. All rights reserved.
//

import Foundation
import UIKit

typealias PKHImageCacheCompletionBlock = (cachedImage: UIImage?, cachedImageURL: NSURL?) -> Void

extension UIImageView {
    
    @objc func pkhic_setImageWith(imageURL: NSURL?, placeholder: UIImage?) {
        
        self.image = placeholder!
        
        if (imageURL == nil) {
            return
        }
        
        weak var weakSelf = self
        
        PKHImageCache.sharedImageCache.addImageOperation(imageURL, completionBlock: { (cachedImage, cachedImageURL) -> Void in
            
            if (cachedImage != nil && imageURL?.absoluteString == cachedImageURL?.absoluteString) {
                weakSelf?.image = cachedImage
            }
            
        })
        
    }
    
}

class PKHImageCache : NSObject {
    
    static let sharedImageCache = PKHImageCache()
    
    private let kMaxCacheAgeForUnusedImages: Int = 60 * 60 * 24 * 3; // 3 days
    private let kMaxCacheAgeForAllImages: Int = 60 * 60 * 24 * 14; // 2 weeks
    
    private var memoryCache: NSCache
    private var pkhImageCacheQueue: dispatch_queue_t
    private var maxCacheAge: Int
    
    private let fileManager: NSFileManager = NSFileManager()
    
    // MARK:
    
    override init() {
        
        self.memoryCache = NSCache()
        self.memoryCache.name = "default"
        
        self.maxCacheAge = kMaxCacheAgeForAllImages;
        
        self.pkhImageCacheQueue = dispatch_queue_create("io.pkh.PKHImageCache", DISPATCH_QUEUE_SERIAL)
        /*
        dispatch_sync(queue: self.pkhImageCacheQueue) { () -> Void in
            self.fileManager = NSFileManager()
        }
        */
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearMemory", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cleanDisk", name: UIApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backgroundCleanDisk", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK:
    
    func addImageOperation(imageURL: NSURL?, completionBlock: PKHImageCacheCompletionBlock?) {
        
        if (imageURL == nil) {    // // if imageURL is nil, skip the rest of this
            if (completionBlock != nil) {
                completionBlock!(cachedImage: nil, cachedImageURL: nil)
            }
            return
        }
        
        dispatch_async(self.pkhImageCacheQueue, { () -> Void in
            
            // look for image in local cache
            let cachedImage: UIImage? = self.searchLocalImageCacheForImageURL(imageURL!)
            
            if (cachedImage != nil) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionBlock!(cachedImage: cachedImage!, cachedImageURL: imageURL!)
                })
            } else {
                // image NOT present in local cache, enqueue download operation
                let operation: PKHImageDownloadOperation = PKHImageDownloadOperation()
                operation.start(imageURL!.absoluteString!, completionBlock: { (image, imageURL) -> Void in
                    self.insertImageInLocalCache(image, urlString: imageURL!.absoluteString!)
                    
                    if let completion = completionBlock {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(cachedImage: image, cachedImageURL: imageURL!)
                        })
                    }
                    
                })
                
            }
            
        })
    }
    
    func insertImageInLocalCache(image: UIImage, urlString: String) {
        
        let hashedFileName = self.hashedImageURLString(urlString)
        let cacheDirectoryPath = self.cacheDirectoryPath()
        
        dispatch_async(self.pkhImageCacheQueue, { () -> Void in
            
            if (self.fileManager.fileExistsAtPath(cacheDirectoryPath) == false) {
                // create cache directory
                self.fileManager.createDirectoryAtPath(cacheDirectoryPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            let diskImagePath = cacheDirectoryPath.stringByAppendingPathComponent(hashedFileName)
            self.fileManager.createFileAtPath(diskImagePath, contents: UIImagePNGRepresentation(image), attributes: nil)
            self.memoryCache.setObject(image, forKey: hashedFileName)
        })
    
    }
    
    @objc func clearAndEmptyCache() {
        dispatch_async(self.pkhImageCacheQueue, { () -> Void in
            
            // clear the in-memory cache
            self.memoryCache.removeAllObjects()
            
            // clear the on-disk cache
            var error: NSError?
            self.fileManager.removeItemAtPath(self.cacheDirectoryPath(), error: &error)
            if (error != nil) {
                println("Error removing disk cache: \(error)")
            }
            
            // Re-create the on-disk cache folder
            self.fileManager.createDirectoryAtPath(self.cacheDirectoryPath(), withIntermediateDirectories: false, attributes: nil, error: nil)

        })
    }
    
    @objc func cacheSize() -> Int {
        var size: Int = 0;
        dispatch_sync(self.pkhImageCacheQueue, { () -> Void in
            let fileEnumerator: NSDirectoryEnumerator = self.fileManager.enumeratorAtPath(self.cacheDirectoryPath())!
            for fileName in fileEnumerator {
                let filePath: String = self.cacheDirectoryPath().stringByAppendingPathComponent(fileName as! String)
                let attrs: NSDictionary = self.fileManager.attributesOfItemAtPath(filePath, error: nil)!
                size += Int(attrs.fileSize())
            }
        });
        return size
    }
    
    // MARK: Private
    
    private func searchLocalImageCacheForImageURL(imageURL: NSURL) -> UIImage? {
        
        let imageURLHash = self.hashedImageURLString(imageURL.absoluteString!)
        
        // First, search the in-memory cache
        var cachedImage: UIImage? = self.memoryCache.objectForKey(imageURLHash) as? UIImage
        if (cachedImage != nil) {
            println("Have image in in-memory cache")
            return cachedImage
        }
        
        // Second, search the cache on disk
        var imageData: NSData? = NSData(contentsOfFile: self.diskImagePathWithHash(imageURLHash))
        if (imageData != nil) {
            println("Have image in on-disk cache!")
            let image = UIImage(data: imageData!)
            self.memoryCache.setObject(image!, forKey: imageURLHash)
            return image
        }
        
        println("Can't find image locally...")
        return nil
    }
    
    // MARK: Helpers
    
    private func diskImagePathWithHash(hash: String) -> String {
        return self.cacheDirectoryPath().stringByAppendingPathComponent(hash)
    }
    
    private func hashedImageURLString(imageURLString: String) -> String {
        
        let str = imageURLString.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(imageURLString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return hash as String
        
    }
    
    private func cacheDirectoryPath() -> String {
        let cacheName: String = "io.pkh.PKHImageCache"
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) as! [String]
        return paths[0].stringByAppendingPathComponent(cacheName)
    }
    
    // MARK: Clean Up
    
    private func clearMemory() {
        println("clearMemory")
        self.memoryCache.removeAllObjects()
    }
    
    private func cleanDisk() {
        println("cleanDisk")
        self.cleanDiskWithCompletion({ _ in })
    }
    
    private func cleanDiskWithCompletion(completion: ()->() ) {
        
        println("cleanDiskWithCompletion")
        
        // clean up the on-disk cache by deleting image files
        // that haven't been accessed in 3 days (aggressive option)
        
        dispatch_async(self.pkhImageCacheQueue, { () -> Void in
            
            let expirationDate: NSDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(-self.maxCacheAge))
            println("expirationDate: \(expirationDate)")
            
            let cacheURL: NSURL = NSURL(fileURLWithPath: self.cacheDirectoryPath(), isDirectory: false)!
            let resourceKeys: [String] = [NSURLIsDirectoryKey, NSURLContentAccessDateKey, NSURLCreationDateKey]
            
            let fileEnumerator: NSDirectoryEnumerator = self.fileManager.enumeratorAtURL(cacheURL, includingPropertiesForKeys: resourceKeys, options: .SkipsHiddenFiles, errorHandler: nil)!
            
            var fileURLsToDelete: NSMutableSet = NSMutableSet()
            
            for fileURLString in fileEnumerator {
                
                let fileURL: NSURL = NSURL(string: fileURLString as! String)!
                let resourceValues: NSDictionary = fileURL.resourceValuesForKeys(resourceKeys, error: nil)!
                
                if (resourceValues[NSURLIsDirectoryKey]?.boolValue == true) {
                    continue
                }
                
                // if this image is older than 2 weeks, clear it from cache regardless
                let creationDate: NSDate = resourceValues[NSURLCreationDateKey] as! NSDate
                if  creationDate.laterDate(expirationDate).isEqualToDate(expirationDate) {
                    fileURLsToDelete.addObject(fileURL)
                }
                
                // if this image hasn't been accessed in the last 3 days, remove it from the cache
                let lastAccessDate: NSDate = resourceValues[NSURLContentAccessDateKey] as! NSDate
                let recentlyUsedExpirationDate: NSDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(-self.kMaxCacheAgeForUnusedImages))
                
                if lastAccessDate.laterDate(recentlyUsedExpirationDate).isEqualToDate(recentlyUsedExpirationDate) {
                    if fileURLsToDelete.containsObject(fileURL) == false {
                        fileURLsToDelete.addObject(fileURL)
                    }
                }
                
            }
            
            println("Deleting \(fileURLsToDelete.count) files")
            println("\(fileURLsToDelete)")
            
            for fileURL in fileURLsToDelete {
                self.fileManager.removeItemAtURL(fileURL as! NSURL, error: nil)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion()
            })
            
        })
        
    }
    
    private func backgroundCleanDisk() {
        
        println("backgroundCleanDisk")
        /*
        let app: UIApplication = UIApplication.sharedApplication()
        var bgTask: UIBackgroundTaskIdentifier = app.beginBackgroundTaskWithExpirationHandler { () -> Void in
            app.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskInvalid
        }
        
        self.cleanDiskWithCompletion { () -> () in
            app.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskInvalid
        }
        */
    }
    
}