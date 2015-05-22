//
//  PKHImageCache.m
//  PKHImageCache
//
//  Created by Patrick Hanlon on 5/4/15.
//  Copyright (c) 2015 Patrick Hanlon. All rights reserved.
//

#import "PKHImageCache.h"

#import <CommonCrypto/CommonDigest.h>
#import "PKHImageDownloadOperation.h"

static const NSInteger kMaxCacheAgeForUnusedImages = 60 * 60 * 24 * 3; // 3 days
static const NSInteger kMaxCacheAgeForAllImages = 60 * 60 * 24 * 14; // 2 weeks

@interface PKHImageCache ()

@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic) dispatch_queue_t pkhImageCacheQueue;
@property (nonatomic) NSInteger maxCacheAge;

@end

@implementation PKHImageCache
{
    NSFileManager *_fileManager;
}

+ (PKHImageCache *)sharedImageCache
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.name = @"default";
        
        _maxCacheAge = kMaxCacheAgeForAllImages;
        
        _pkhImageCacheQueue = dispatch_queue_create("io.pkh.PKHImageCache", DISPATCH_QUEUE_SERIAL);
        
        dispatch_sync(_pkhImageCacheQueue, ^{
            _fileManager = [NSFileManager new];
        });
        
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)addImageOperationForImageView:(UIImageView *)imageView usingURL:(NSURL *)imageURL andPlaceholderImage:(UIImage *)placeholder
{
    // First, set the image view's placeholder image
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.image = placeholder;
    });
    
    if (!imageURL) {    // if imageURL is nil, skip the rest of this
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    dispatch_async(self.pkhImageCacheQueue, ^{
        
        // Look for image in local cache
        UIImage *cachedImage = [weakSelf searchLocalImageCacheForImageURL:imageURL];
    
        if (cachedImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = cachedImage;
            });
        } else {
            // if image NOT present in local cache, enqueue download operation
            PKHImageDownloadOperation *operation = [PKHImageDownloadOperation new];
            operation.imageURLString = [imageURL absoluteString];
            operation.imageView = imageView;
            [operation start];
        }
    });
}

- (void)insertImageInLocalCache:(UIImage *)image withImageURLString:(NSString *)imageURLString
{
    NSString *hashedFilename = [self hashedImageURLString:imageURLString];
    
    NSString *cacheDirectoryPath = [self cacheDirectoryPath];
    
    dispatch_async(self.pkhImageCacheQueue, ^{
        
        if ([_fileManager fileExistsAtPath:cacheDirectoryPath isDirectory:NULL] == NO) {
            // create cache directory
            [_fileManager createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
        }
        
        NSString *diskImagePath = [cacheDirectoryPath stringByAppendingPathComponent:hashedFilename];
        
        [_fileManager createFileAtPath:diskImagePath contents:UIImagePNGRepresentation(image) attributes:nil];
        
        [self.memoryCache setObject:image forKey:hashedFilename];
        
    });
}

- (void)clearAndEmptyCache
{
    dispatch_async(self.pkhImageCacheQueue, ^{
        
        // clear the in-memory cache
        [self.memoryCache removeAllObjects];
        
        // clear the on-disk cache
        NSError *error = nil;
        [_fileManager removeItemAtPath:[self cacheDirectoryPath] error:&error];
        if (error != nil) {
            NSLog(@"Error removing disk cache: %@", error);
        }
        
        // Re-create the on-disk cache folder
        [_fileManager createDirectoryAtPath:[self cacheDirectoryPath] withIntermediateDirectories:NO attributes:nil error:NULL];
        
    });
}

#pragma mark - Private

- (UIImage *)searchLocalImageCacheForImageURL:(NSURL *)imageURL
{
    NSString *imageURLHash = [self hashedImageURLString:[imageURL absoluteString]];
    
    // First, search the in memory cache
    UIImage *cachedImage = [self.memoryCache objectForKey:imageURLHash];
    if (cachedImage) {
        NSLog(@"Have image in in-memory cache!");
        return cachedImage;
    }
    
    // Second, search the cache on disk
    NSData *data = [NSData dataWithContentsOfFile:[self diskImagePathWithHash:imageURLHash]];
    if (data) {
        NSLog(@"Have image in on-disk cache!");
        UIImage *image = [UIImage imageWithData:data];
        
        [self.memoryCache setObject:image forKey:imageURLHash];
        
        return image;
    }
    
    NSLog(@"Can't find image locally....");
    return nil;
}

#pragma mark - Helpers

- (NSString *)diskImagePathWithHash:(NSString *)hash
{
    return [[self cacheDirectoryPath] stringByAppendingPathComponent:hash];
}

- (NSString *)hashedImageURLString:(NSString *)imageURLString
{
    const char *charArrayStr = [imageURLString UTF8String];
    if (charArrayStr == NULL) {
        charArrayStr = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(charArrayStr, (CC_LONG)strlen(charArrayStr), r);
    NSString *hashedFilename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
    return hashedFilename;
}

- (NSString *)cacheDirectoryPath
{
    NSString *cacheName = @"io.pkh.PKHImageCache";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:cacheName];
}

- (NSUInteger)cacheSize
{
    __block NSUInteger size = 0;
    dispatch_sync(self.pkhImageCacheQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:[self cacheDirectoryPath]];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [[self cacheDirectoryPath] stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

#pragma mark - Clean Up

- (void)clearMemory
{
    [self.memoryCache removeAllObjects];
}

- (void)cleanDisk
{
    [self cleanDiskWithCompletion:nil];
}

- (void)cleanDiskWithCompletion:(void(^)(void))completionBlock
{
    // clean up the on-disk cache by deleting image files
    // that haven't been accessed in 3 days (aggressive option)
    
    __weak typeof(self)weakSelf = self;
    
    dispatch_async(self.pkhImageCacheQueue, ^{
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSLog(@"expirationDate: %@",expirationDate);
        
        NSURL *cacheURL = [NSURL fileURLWithPath:[weakSelf cacheDirectoryPath] isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentAccessDateKey, NSURLCreationDateKey];
        
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:cacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        NSMutableSet *fileURLsToDelete = [NSMutableSet new];
        
        for (NSURL *fileURL in fileEnumerator) {
            
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            // if this image is older than 2 weeks, clear it from cache regardless
            NSDate *creationDate = resourceValues[NSURLCreationDateKey];
            if ([[creationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [fileURLsToDelete addObject:fileURL];
            }
            
            // if this image hasn't been accessed in the last 3 days, remove it from the cache
            NSDate *lastAccessDate = resourceValues[NSURLContentAccessDateKey];
            NSDate *recentlyUsedExpirationDate = [NSDate dateWithTimeIntervalSinceNow:-kMaxCacheAgeForUnusedImages];
            
            if ([[lastAccessDate laterDate:recentlyUsedExpirationDate] isEqualToDate:recentlyUsedExpirationDate]) {
                if ([fileURLsToDelete containsObject:fileURL] == NO) {
                    [fileURLsToDelete addObject:fileURL];
                }
            }
            
        }
        
        NSLog(@"Deleting %lu files",(long)[fileURLsToDelete count]);
        NSLog(@"%@",fileURLsToDelete);
        
        for (NSURL *fileURL in fileURLsToDelete) {
            [_fileManager removeItemAtURL:fileURL error:nil];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

- (void)backgroundCleanDisk
{
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [self cleanDiskWithCompletion:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

@end
