//
//  UIImageView+Networking.m
//
//  Created by Petar Petrov on 04/05/2014.
//  Copyright (c) 2014 Petar Petrov. All rights reserved.
//

#import "UIImageView+Networking.h"
#import <objc/runtime.h>

@interface UIImageView (NetworkingPrivate)

@property (strong, nonatomic) NSOperationQueue  * _Nullable operationQueue;
@property (strong, nonatomic) NSURLSessionDataTask * _Nullable dataTask;

@end

@implementation UIImageView (NetworkingPrivate)

@dynamic operationQueue;
@dynamic dataTask;

NSString *const operationQueueKey = @"com.mmgallery.imageViewOperationQueue";

- (void)setOperationQueue:(NSOperationQueue *)operationQueue {
    objc_setAssociatedObject(self, @selector(operationQueue), operationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSOperationQueue *)operationQueue {
    
    NSOperationQueue *operationQueue = objc_getAssociatedObject(self, @selector(operationQueue));
    
    if (!operationQueue) {
        objc_setAssociatedObject(self, @selector(operationQueue), [NSOperationQueue new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return operationQueue;
}

- (void)setDataTask:(NSURLSessionDataTask *)dataTask {
    objc_setAssociatedObject(self, @selector(dataTask), dataTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDataTask *)dataTask {
    return objc_getAssociatedObject(self, @selector(dataTask));;
}

@end


@implementation UIImageView (Networking)

#pragma mark - Image Loading

- (void)psetImageWithURLString:(NSString *)urlString placeholder:(UIImage *)placeholderImage
{
    NSURL *imageUrl = [NSURL URLWithString:urlString];
    
    [self psetImageWithURL:imageUrl placeholder:placeholderImage];
}

- (void)psetImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholderImage
{
    self.image = placeholderImage;
    NSString *fileName = [[url.absoluteString componentsSeparatedByString:@"/"] lastObject];
    NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:imagePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        
        [self.operationQueue cancelAllOperations];
        
        [self.operationQueue addOperationWithBlock: ^{
            
            NSData *data = [NSData dataWithContentsOfURL:fileURL];
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = image;
                });
            }
        }];
        
    } else if (url) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        if (self.dataTask) {
            [self.dataTask cancel];
            self.dataTask = nil;
        }
        
        self.dataTask = [session dataTaskWithURL:url
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                            NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
                            __autoreleasing NSError *error = nil;
                            
                            if (![imageData writeToURL:fileURL options:NSDataWritingAtomic error:&error] && error != nil) {
                                NSLog(@"%@ : %@", error, [error userInfo]);
                                abort();
                            }
                        }
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.image = image;
                        });
                    }
                    
                }];
        
        [self.dataTask resume];
    }
}

@end


