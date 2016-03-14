//
//  ImagesBoardView.m
//  MMGalery
//
//  Created by Petar Petrov on 26/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMImagesBoardView.h"
#import "UIImageView+Networking.h"
#import "MMImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MMImagesBoardView () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableSet *imageViewPool;

@property (assign, nonatomic) NSInteger maxNumberOfImageViewOnScreen;

@property (assign, nonatomic) NSInteger imageViewSideSize;

@property (assign, nonatomic, getter=isLoadingNextPage) BOOL loadingNextPage;
@property (assign, nonatomic, getter=isShowingLoadingIndicatorView) BOOL showingLoadingIndicator;

@property (assign, nonatomic) NSInteger leftMargin;

@property (strong, nonatomic) UIView *loadingIndicator;

@end

@implementation MMImagesBoardView

static NSInteger kImageBoardViewPadding = 1.0f;
static NSInteger kImageBoardViewTopMargin = 10.0f;
static NSInteger kImageBoardViewBottomMargin = 1.0f;
static NSInteger kImageBoardViewLeftMargin = 0.0f;
static NSInteger kImageBoardRightMargin = 0.0f;

static NSInteger kLoadingIndicatorViewHeight = 100.0f;

static NSUInteger kDefaultNumberOfImagesPerRow = 4;

#pragma mark - Custom Accessors

- (NSMutableSet *)imageViewPool {
    if (!_imageViewPool) {
        _imageViewPool = [[NSMutableSet alloc] init];
    }
    
    return _imageViewPool;
}

- (void)setLoadingNextPage:(BOOL)loadingNextPage {
    
    if (_loadingNextPage != loadingNextPage) {
        _loadingNextPage = loadingNextPage;
        
        if (!_loadingNextPage) {
            [self.loadingIndicator removeFromSuperview];
        }
    }
}

#pragma mark - Initilizers

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _numberOfImagesPerRow = kDefaultNumberOfImagesPerRow;
        
        _leftMargin = kImageBoardViewLeftMargin;
        
        self.contentSize = frame.size;
        self.delegate = self;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        
        [self addGestureRecognizer:tapGestureRecognizer];
        
        [self calculateViewParameters];
        
        [self configureLoadingIndicatorView];
        
        [self loadImageViews];
    }
    
    return self;
}

#pragma mark - Manipulate View Frame

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    for (MMImageView *imageView in self.subviews) {
        if ([imageView isKindOfClass:[MMImageView class]]) {
            [self removeImageViewFromScrollViewImageView:imageView];
        }
    }
    
    self.numberOfImagesPerRow = (NSUInteger)floor(frame.size.width / self.imageViewSideSize);
    
    self.leftMargin = ceil(frame.size.width - (self.numberOfImagesPerRow * self.imageViewSideSize) - ((self.numberOfImagesPerRow - 1) * kImageBoardViewPadding)) / 2;
    
    [self calculateMaximumNumberOfImageViewOnScreen];
}

#pragma mark - Creating Image Board View Image Views

- (MMImageView *)dequeueReusableImageView {
    MMImageView *imageView = [self.imageViewPool anyObject];
    
    if (imageView) {
        [self.imageViewPool removeObject:imageView];
    }
    
    return imageView;
}

- (void)registerClassForImageView:(Class)imageViewClass {
    
}

#pragma mark - Accessing Image Views



- (NSArray *)visibleViews {
    
    return [self imageViews];
}

#pragma mark - Reloading Image Board View

- (void)reloadImageBoardView {
    [self loadImageViews];
}

- (void)reloadImageBoardViewAndStopLoadingIndicator {
    [self reloadImageBoardView];
    
    self.loadingNextPage = NO;
}

#pragma mark - Subviews Configuration (Private)

- (void)configureLoadingIndicatorView {
    self.loadingIndicator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height - kLoadingIndicatorViewHeight, self.bounds.size.width, kLoadingIndicatorViewHeight)];
    
    // configure and add an activity indicator to loading indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.loadingIndicator.bounds), CGRectGetMidY(self.loadingIndicator.bounds));
    activityIndicatorView.color = [[UIColor alloc]initWithRed: 0.219034 green: 0.598590 blue: 0.815217 alpha: 1 ];
    
    [self.loadingIndicator addSubview:activityIndicatorView];
   
    [activityIndicatorView startAnimating];
    
    // configure and add a message label to loading indicator
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"Loading Images from Flickr", nil) ;
    [label sizeToFit];
    [self.loadingIndicator addSubview:label];
    label.center = CGPointMake(CGRectGetMidX(self.loadingIndicator.bounds), CGRectGetMidY(self.loadingIndicator.bounds) + activityIndicatorView.bounds.size.height);
}

#pragma mark - Private

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    
    CGPoint location = [gesture locationInView:self];
    
    CGFloat y = location.y - kImageBoardViewTopMargin;
    
    NSUInteger a = y / (self.imageViewSideSize + kImageBoardViewPadding);
    
    CGFloat x = location.x - self.leftMargin;
    
    NSUInteger b = x / (self.imageViewSideSize + kImageBoardViewPadding);
    
    NSUInteger index = (a * self.numberOfImagesPerRow) + b;
    
    if (index >= [self.imageBoardDataSource numberOfImagesInImageBoardView:self]) {
        return;
    }
    
    if ([self.imageBoardDelegate respondsToSelector:@selector(imageBoardView:didSelectImageViewAtIndex:)]) {
        [self.imageBoardDelegate imageBoardView:self didSelectImageViewAtIndex:index];
    }
}

- (NSArray *)imageViews {
    NSMutableArray *imageViews = [NSMutableArray array];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[MMImageView class]]) {
            [imageViews addObject:view];
        }
    }
    
    return [imageViews copy];
}

#pragma mark - Adding and Removing Views to Image Board View (Private)

- (void)loadImageViews {
    [self updateContentSize];
    
    [self removeOffscreenImageView];
    
    // calculate the first and last indexes
    NSInteger firstVisibleIndex = MAX(0, floor((self.contentOffset.y - kImageBoardViewTopMargin) / (self.imageViewSideSize + kImageBoardViewPadding)) * self.numberOfImagesPerRow);
    NSInteger lastVisibleIndex = MIN([self.imageBoardDataSource numberOfImagesInImageBoardView:self], firstVisibleIndex + self.maxNumberOfImageViewOnScreen);
    
    // add only new image views to the scrollView
    for (NSInteger index = firstVisibleIndex; index < lastVisibleIndex; index++) {
        UIView *cell = [self cellForRow:index];
        if (!cell) {
            
            [self addImageViewToScrollViewAtIndex:index];
        }
    }
}

- (void)removeOffscreenImageView {
    // remove all image views that are offscreen
    for (MMImageView *cell in [self imageViews]) {
        // is the cell off the top of the scrollview?
        if (cell.frame.origin.y + cell.frame.size.height < self.contentOffset.y) {
            [self removeImageViewFromScrollViewImageView:cell];
        }
        // is the cell off the bottom of the scrollview
        if (cell.frame.origin.y > self.contentOffset.y + self.frame.size.height) {
            [self removeImageViewFromScrollViewImageView:cell];
        }
    }
}

- (void)addImageViewToPoolForReuse:(MMImageView *)imageView {
    [imageView removeFromSuperview];
    
    [self.imageViewPool addObject:imageView];
}

- (void)removeImageViewFromScrollViewImageView:(MMImageView *)imageView {
    
    [self addImageViewToPoolForReuse:imageView];
}

- (void)addImageViewToScrollViewAtIndex:(NSInteger)index {
    MMImageView *imageView = [self.imageBoardDataSource imageBoardView:self imageViewForIndexPath:index];
    
    imageView.frame = [self calculateFrameForImageViewAtIndex:index];
    
    [self addSubview:imageView];
}

#pragma mark - Image Board View Calculations (Private)

- (CGRect)calculateFrameForImageViewAtIndex:(NSInteger)index {
    
    NSInteger row = index / self.numberOfImagesPerRow;
    NSInteger column = index % self.numberOfImagesPerRow;
    
    CGFloat x = self.leftMargin + (self.imageViewSideSize * column) + kImageBoardViewPadding * column;
    
    CGFloat y = kImageBoardViewTopMargin + (self.imageViewSideSize * row) + kImageBoardViewPadding * row;
    
    return CGRectMake(x, y, self.imageViewSideSize, self.imageViewSideSize);
}

- (void)calculateViewParameters {
    
    CGFloat sideSize = ceil((self.bounds.size.width - (kImageBoardViewPadding * (self.numberOfImagesPerRow - 1) + self.leftMargin + kImageBoardRightMargin)) / self.numberOfImagesPerRow);
    
    self.imageViewSideSize = sideSize;
    
    [self calculateMaximumNumberOfImageViewOnScreen];
}

- (void)calculateMaximumNumberOfImageViewOnScreen {
    
    CGFloat viewHeight = self.bounds.size.height;
    
    NSInteger number = viewHeight / (self.imageViewSideSize + kImageBoardViewPadding);
    
    if (((int)viewHeight % (int)(self.imageViewSideSize + kImageBoardViewPadding)) > kImageBoardViewTopMargin) {
        number++;
    }
    
    self.maxNumberOfImageViewOnScreen = (number * self.numberOfImagesPerRow) + self.numberOfImagesPerRow;
}

- (void)updateContentSize {
    CGFloat loadingIndicatorHeight = (self.isLoadingNextPage) ? kLoadingIndicatorViewHeight : 0.0f;
    
    CGFloat contentSizeHeight = (ceil((double)[self.imageBoardDataSource numberOfImagesInImageBoardView:self] / self.numberOfImagesPerRow) * self.imageViewSideSize) + ((ceil((double)[self.imageBoardDataSource numberOfImagesInImageBoardView:self] / self.numberOfImagesPerRow) - 1)  * kImageBoardViewPadding) + kImageBoardViewTopMargin + kImageBoardViewBottomMargin + loadingIndicatorHeight;
    
    self.contentSize = CGSizeMake(self.bounds.size.width, contentSizeHeight);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self reloadImageBoardView];
    
    if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height + kLoadingIndicatorViewHeight && !self.loadingNextPage) {
        NSLog(@"load next page");
        self.loadingNextPage = YES;
        
        self.loadingIndicator.frame = CGRectMake(self.loadingIndicator.frame.origin.x, self.contentSize.height, self.loadingIndicator.frame.size.width, self.loadingIndicator.frame.size.height);
        
        [self addSubview:self.loadingIndicator];
        
        if ([self.imageBoardDelegate respondsToSelector:@selector(requestNextPage)]) {
            [self.imageBoardDelegate requestNextPage];
        }
    }
}

- (MMImageView *)cellForRow:(NSInteger)index {
    NSInteger row =  index / self.numberOfImagesPerRow;
    NSInteger column = index % self.numberOfImagesPerRow;
    
    CGFloat topEdgeForRow = kImageBoardViewTopMargin + (self.imageViewSideSize * row) + kImageBoardViewPadding * row;
    CGFloat leftEdgeForColumn = self.leftMargin + (self.imageViewSideSize * column) + kImageBoardViewPadding * column;

    
    for (MMImageView *cell in [self imageViews]) {
        
        if (cell.frame.origin.y == topEdgeForRow && cell.frame.origin.x == leftEdgeForColumn)
            return cell;
    }
    
    return nil;
}

@end
