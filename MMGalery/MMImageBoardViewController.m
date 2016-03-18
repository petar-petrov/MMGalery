//
//  ViewController.m
//  MMGalery
//
//  Created by Petar Petrov on 26/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMImageBoardViewController.h"
#import "MMImagesBoardView.h"
#import "MMFlickrManager.h"
#import "MMImageView.h"
#import "MMImageDetailsViewController.h"
#import "MMFlickrImage.h"

#import "UIImageView+Networking.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <objectiveflickr/ObjectiveFlickr.h>

@interface MMImageBoardViewController () <OFFlickrAPIRequestDelegate, MMFlickrManagerDelegate, MMImagesBoardViewDelegate, MMImagesBoardViewDataSource>

@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;
@property (strong, nonatomic) OFFlickrAPIRequest *flickrRequest;

@property (strong, nonatomic) MMImagesBoardView *boardView;

@property (strong, nonatomic) MMFlickrManager *manager;

@property (strong, nonatomic) NSArray *images;

@end

@implementation MMImageBoardViewController

#pragma mark - Custom Accessors

- (NSArray *)images {
    if (!_images) {
        _images = [NSArray array];
    }
    
    return _images;
}

#pragma mark - Life Cycle

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Flickr";
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.manager = [MMFlickrManager defaultManager];
    
    self.manager.flickrManagerDelegate = self;
    
    [self.manager firstPage];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.boardView = [[MMImagesBoardView alloc] initWithFrame:self.view.bounds];
    self.boardView.imageBoardDelegate = self;
    self.boardView.imageBoardDataSource = self;

    
    [self.view addSubview:self.boardView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    
    CGRect newFrame = CGRectMake(self.boardView.frame.origin.x, self.boardView.frame.origin.y, size.width, size.height);
    
//    NSLog(@"Rotation %@", NSStringFromCGRect(newFrame));
    
    self.boardView.frame = newFrame;
    
//    [self.boardView reloadImageBoardView];

}

#pragma mark - MMFlickrManagerDelegate 

- (void)flickrManager:(MMFlickrManager *)manager imageURLs:(NSArray *)urls page:(NSUInteger)pageNumber {
    if (urls) {
        self.images = [self.images arrayByAddingObjectsFromArray:urls];
        
        [self.boardView reloadImageBoardViewAndStopLoadingIndicator];
    }
    
}

- (void)flickrManager:(MMFlickrManager *)manager failedToWithError:(NSError *)error {
    [self.boardView reloadImageBoardViewAndStopLoadingIndicator];
}

#pragma mark - MMImageBoardViewDelegate

- (void)requestNextPage {
    [self.manager nextPage];
}

- (void)imageBoardView:(MMImagesBoardView *)imageBoardView didSelectImageViewAtIndex:(NSUInteger)index {
    NSLog(@"%ld", index);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MMImageDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ImageDetails"];
    vc.imageInfo= self.images[index];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - MMImageBoardViewDataSource

- (NSInteger)numberOfImagesInImageBoardView:(MMImagesBoardView *)imageBoardView {
    return self.images.count;
}

- (MMImageView *)imageBoardView:(MMImagesBoardView *)imageBoardView imageViewForIndexPath:(NSInteger)index {
    MMImageView *boardImageView = [imageBoardView dequeueReusableImageView];
    
    if (!boardImageView) {
        boardImageView = [[MMImageView alloc] init];
    }
    
    MMFlickrImage *imageInfo = self.images[index];

    [boardImageView psetImageWithURL:imageInfo.smallImageURL placeholder:[UIImage imageNamed:@"flickr-logo.png"]];
    
    boardImageView.tag = index;
    
    return boardImageView;
}


@end
