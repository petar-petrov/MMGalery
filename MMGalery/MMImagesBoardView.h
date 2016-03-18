//
//  ImagesBoardView.h
//  MMGalery
//
//  Created by Petar Petrov on 26/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMImagesBoardViewDelegate;
@protocol MMImagesBoardViewDataSource;

@class MMImageView;

typedef NS_ENUM(NSInteger, MMImagesBoardViewScrollPosition) {
    MMImagesBoardViewScrollPositionTop,
    MMImagesBoardViewScrollPositionMiddle,
    MMImagesBoardViewScrollPositionBottom
};

@interface MMImagesBoardView : UIScrollView

@property (weak, nonatomic) id <MMImagesBoardViewDelegate> imageBoardDelegate;
@property (weak, nonatomic) id <MMImagesBoardViewDataSource> imageBoardDataSource;

@property (assign, nonatomic) NSUInteger numberOfImagesPerRow;
@property (nonatomic, readonly) NSArray <__kindof MMImageView*> *visibleViews;

@property (strong, nonatomic, readonly) NSArray *images;

- (MMImageView *)dequeueReusableImageView;
- (void)registerClassForImageView:(Class)imageViewClass;

- (void)reloadImageBoardView;
- (void)reloadImageBoardViewAndStopLoadingIndicator;

- (void)scrollToRowAtIndex:(NSInteger)index atScrollPosistion:(MMImagesBoardViewScrollPosition)position animated:(BOOL)animated;

@end

@protocol MMImagesBoardViewDelegate <NSObject>

@optional

- (void)requestNextPage;
- (void)imageBoardView:(MMImagesBoardView *)imageBoardView didSelectImageViewAtIndex:(NSUInteger)index;
//- (void)numberOfImageVeiwsPerRow; // default is 3

@end

@protocol MMImagesBoardViewDataSource <NSObject>

@required

- (NSInteger)numberOfImagesInImageBoardView:(MMImagesBoardView *)imageBoardView;
- (MMImageView *)imageBoardView:(MMImagesBoardView *)imageBoardView imageViewForIndexPath:(NSInteger)index;

@end
