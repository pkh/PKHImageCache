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
    [[PKHImageCache sharedImageCache] addImageOperationForImageView:self usingURL:imageURL andPlaceholderImage:placeholder];
}

@end
