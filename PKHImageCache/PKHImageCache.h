//
//  PKHImageCache.h
//  PKHImageCache
//
//  Created by Patrick Hanlon on 5/4/15.
//  Copyright (c) 2015 Patrick Hanlon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PKHImageCache : NSObject

+ (PKHImageCache *)sharedImageCache;

- (void)addImageOperationForImageView:(UIImageView *)imageView usingURL:(NSURL *)imageURL andPlaceholderImage:(UIImage *)placeholder;

- (void)insertImageInLocalCache:(UIImage *)image withImageURLString:(NSString *)imageURLString;

- (void)clearAndEmptyCache;
- (NSUInteger)cacheSize;

@end
