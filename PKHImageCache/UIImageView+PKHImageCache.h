//
//  UIImageView+PKHImageCache.h
//  PKHImageCache
//
//  Created by Patrick Hanlon on 5/8/15.
//  Copyright (c) 2015 Patrick Hanlon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (PKHImageCache)

- (void)pkhic_setImageWithURL:(NSURL *)imageURL andPlaceholderImage:(UIImage *)placeholder;

@end
