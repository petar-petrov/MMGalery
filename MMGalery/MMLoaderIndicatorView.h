//
//  MMLoaderIndicatorView.h
//  MMGalery
//
//  Created by Petar Petrov on 15/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMLoaderIndicatorView : UIView

@property (strong, nonatomic, readonly) UILabel *message;

@property (strong, nonatomic) UIColor *activityIndicatorColor;

- (void)startAnimating;
- (void)stopAnimating;

@end
