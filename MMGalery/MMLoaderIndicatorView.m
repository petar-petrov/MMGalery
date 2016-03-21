//
//  MMLoaderIndicatorView.m
//  MMGalery
//
//  Created by Petar Petrov on 15/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMLoaderIndicatorView.h"

@interface MMLoaderIndicatorView ()

@property (strong, nonatomic, readwrite) UILabel *message;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (assign, nonatomic, getter=isContraintsSet) BOOL constraintsSet;

@end

@implementation MMLoaderIndicatorView

#pragma mark - Custom Accessors

- (void)setActivityIndicatorColor:(UIColor *)activityIndicatorColor {
    if (_activityIndicatorColor != activityIndicatorColor) {
        _activityIndicatorColor = activityIndicatorColor;
        
        self.activityIndicatorView.color = activityIndicatorColor;
    }
}

#pragma mark - Initilizers

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self configureView];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat centerOffset = floor((self.activityIndicatorView.bounds.size.height + self.message.bounds.size.height) / 2.0f);
    CGFloat activityIndicatorCenterY = ceil(centerOffset - CGRectGetMidY(self.activityIndicatorView.bounds));
    
    self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - activityIndicatorCenterY);
    self.message.center = CGPointMake(CGRectGetMidX(self.bounds), self.activityIndicatorView.center.y + centerOffset);
}

#pragma mark - Animationing Activity Indicator

- (void)startAnimating {
    [self.activityIndicatorView startAnimating];
}

- (void)stopAnimating {
    [self.activityIndicatorView stopAnimating];
}


#pragma mark - Subviews Configuration (Private)

- (void)configureView {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.color = self.activityIndicatorColor;
    
    [self addSubview:self.activityIndicatorView];
    
    self.message = [[UILabel alloc] init];
    self.message.textAlignment = NSTextAlignmentCenter;
    self.message.text = NSLocalizedString(@"Loading Images from Flickr", nil);
    [self.message sizeToFit];
    
    [self addSubview:self.message];
    
    CGFloat centerOffset = floor((self.activityIndicatorView.bounds.size.height + self.message.bounds.size.height) / 2.0f);
    CGFloat activityIndicatorCenterY = ceil(centerOffset - CGRectGetMidY(self.activityIndicatorView.bounds));
    
    self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - activityIndicatorCenterY);
    self.message.center = CGPointMake(CGRectGetMidX(self.bounds), self.activityIndicatorView.center.y + centerOffset);

}

@end
