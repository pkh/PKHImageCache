//
//  PKHImageCache.h
//  PKHImageCache
//
//  Created by Patrick Hanlon on 5/4/15.
//  Copyright (c) 2015 Patrick Hanlon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^PKHImageCacheCompletionBlock)(UIImage *cachedImage, NSURL *cachedImageURL);

@interface PKHImageCache : NSObject

+ (PKHImageCache *)sharedImageCache;

- (void)addImageOperationWithURL:(NSURL *)imageURL withCompletionBlock:(PKHImageCacheCompletionBlock)completionBlock;

- (void)clearAndEmptyCache;
- (NSUInteger)cacheSize;

@end
