//
//  PKHImageDownloadOperation.h
//  PKHImageCache
//
//  Created by Patrick Hanlon on 5/4/15.
//  Copyright (c) 2015 Patrick Hanlon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^PKHImageDownloaderCompletionBlock)(UIImage *image, NSURL *imageURL);

@interface PKHImageDownloadOperation : NSObject

@property (nonatomic, strong) NSString *imageURLString;

- (void)startWithCompletion:(PKHImageDownloaderCompletionBlock)completionBlock;

@end
