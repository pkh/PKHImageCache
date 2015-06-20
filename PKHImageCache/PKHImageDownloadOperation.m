//
//  PKHImageDownloadOperation.m
//  PKHImageCache
//
//  Created by Patrick Hanlon on 5/4/15.
//  Copyright (c) 2015 Patrick Hanlon. All rights reserved.
//

#import "PKHImageDownloadOperation.h"
#import "PKHImageCache.h"

@interface PKHImageDownloadOperation () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>
{
    NSURLSession *_session;
    NSURLSessionDownloadTask *_downloadTask;
    PKHImageDownloaderCompletionBlock _completionBlock;
}

@end

@implementation PKHImageDownloadOperation

#pragma mark - Public

- (void)startWithCompletion:(PKHImageDownloaderCompletionBlock)completionBlock
{
    _completionBlock = [completionBlock copy];
    _downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.imageURLString]];
    [_downloadTask resume];
}

#pragma mark - Private

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    return _session;
}

#pragma mark - NSURLSessionDownloadDelegate methods

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:data];
    
    if (_completionBlock != nil) {
        _completionBlock(image, [NSURL URLWithString:self.imageURLString]);
    }

    [_session finishTasksAndInvalidate];
}


@end
