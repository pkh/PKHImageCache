//
//  UIImageView+PKHImageCache.m
//  PKHImageCache
//
//  Created by Patrick Hanlon on 5/8/15.
//  Copyright (c) 2015 Patrick Hanlon. All rights reserved.
//

#import "UIImageView+PKHImageCache.h"
#import "PKHImageCache.h"

@implementation UIImageView (PKHImageCache)

- (void)pkhic_setImageWithURL:(NSURL *)imageURL andPlaceholderImage:(UIImage *)placeholder
{
    self.image = placeholder;
    
    if (!imageURL) {    // make sure we have an imageURL to set before continuing
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [[PKHImageCache sharedImageCache] addImageOperationWithURL:imageURL withCompletionBlock:^(UIImage *cachedImage, NSURL *cachedImageURL) {
        
        if (cachedImage != nil && [[imageURL absoluteString] isEqualToString:[cachedImageURL absoluteString]]) {
            weakSelf.image = cachedImage;
        }
        
    }];
}

@end
