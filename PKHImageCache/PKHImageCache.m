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

@interface PKHImageCache ()

@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic) dispatch_queue_t pkhImageCacheQueue;

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
        
        _pkhImageCacheQueue = dispatch_queue_create("io.pkh.PKHImageCache", DISPATCH_QUEUE_SERIAL);
        
        dispatch_sync(_pkhImageCacheQueue, ^{
            _fileManager = [NSFileManager new];
        });
    }
    return self;
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

@end
