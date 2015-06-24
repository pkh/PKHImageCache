//
//  PKHImageDownloadOperation.swift
//  PKHIC-Example
//
//  Created by Patrick Hanlon on 6/24/15.
//  Copyright (c) 2015 pkh. All rights reserved.
//

import Foundation
import UIKit

typealias PKHImageDownloaderCompletionBlock = (image: UIImage, imageURL: NSURL?) -> Void

class PKHImageDownloadOperation: NSObject, NSURLSessionDownloadDelegate {
    
    var imageURLString: String!
    var downloadTask: NSURLSessionDownloadTask!
    var completionBlock: PKHImageDownloaderCompletionBlock!
    
    lazy var session: NSURLSession = {
        let sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var newSession: NSURLSession = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        return newSession
    }()
    
    // MARK: Public Interface
    
    func start(imageURLString: String, completionBlock: PKHImageDownloaderCompletionBlock) {
        self.imageURLString = imageURLString
        self.completionBlock = completionBlock
        self.downloadTask = self.session.downloadTaskWithURL(NSURL(string: self.imageURLString)!)
        self.downloadTask.resume()
    }
    
    // MARK: NSURLSessionDownloadDelegate Methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let data: NSData = NSData(contentsOfURL: location)!
        let image: UIImage = UIImage(data: data)!
        
        if let completion = self.completionBlock {
            completion(image: image, imageURL: NSURL(string: self.imageURLString!))
        }
        
        session.finishTasksAndInvalidate()
    }
    
}
