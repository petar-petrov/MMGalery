//
//  MMImageDetailsViewController.m
//  MMGalery
//
//  Created by Petar Petrov on 09/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMImageDetailsViewController.h"
#import "MMFlickrImage.h"
#import "UIImageView+Networking.h"


#import <SDWebImage/UIImageView+WebCache.h>

@interface MMImageDetailsViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;

@property (assign, nonatomic, getter=isZoomedIn) BOOL zoomedIn;

@property (assign, nonatomic) CGFloat zoomingScale;

@end

@implementation MMImageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.scrollView.zoomScale = 1.0f;
    
    self.title = self.imageInfo.title;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor orangeColor];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.imageView sd_setImageWithURL:self.imageInfo.largeImageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType type, NSURL *imageURL) {
        self.scrollView.contentSize = image.size;
        
        self.imageView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        
        CGFloat minScale = [self calculateMinScale];
        self.scrollView.minimumZoomScale = minScale;
        
        self.scrollView.maximumZoomScale = 1.5f;
        self.scrollView.zoomScale = minScale;

        [self centerScrollViewContent];

        self.zoomedIn = YES;
        
        [self.scrollView addSubview:self.imageView];
    }];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    NSLog(@"%@", NSStringFromCGSize(size));
//    
//    self.scrollView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
//    
//    CGFloat minScale = [self calculateMinScale];
//    self.scrollView.minimumZoomScale = minScale;
//    self.scrollView.zoomScale = minScale;
//    
//    [self centerScrollViewContent];
//}

#pragma mark - Private

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    
    CGPoint pointInView = [gesture locationInView:self.imageView];
    
    CGRect rectToZoomTo = [self zoomRectForPoint:pointInView];
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (CGRect)zoomRectForPoint:(CGPoint)point {
    CGFloat newZoomScale;
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    if (self.isZoomedIn) {
        newZoomScale = self.scrollView.zoomScale * 1.5f;
        newZoomScale = 2.5f;
        
        self.zoomedIn = NO;
    } else {
        newZoomScale = [self calculateMinScale];
        
        self.zoomedIn = YES;
    }
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    
    return CGRectMake(x, y, w, h);
}

- (CGFloat)calculateMinScale {
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    
    return MIN(scaleWidth, scaleHeight);
}

- (void)centerScrollViewContent {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - UIScrollViewDelegate 

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContent];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.zoomingScale = self.scrollView.zoomScale;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.zoomingScale < scale) {
        self.zoomedIn = NO;
    } else {
        self.zoomedIn = YES;
    }
}

@end
