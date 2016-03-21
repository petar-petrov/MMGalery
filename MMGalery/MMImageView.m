//
//  MMImageView.m
//  MMGalery
//
//  Created by Petar Petrov on 07/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMImageView.h"

@import QuartzCore;

@interface MMImageView ()

@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
//@property (strong, nonatomic) dispatch_queue_t imageLoadingQueue;

@end

@implementation MMImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [[UIColor alloc]initWithRed: 0.956863 green: 0.956863 blue: 0.956863 alpha: 1 ];
//        self.imageLoadingQueue = dispatch_queue_create("com.mmgalery.imageloading", 0);
    }
    
    return self;
}

@end
