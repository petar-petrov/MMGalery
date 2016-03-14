//
//  MMFlickrFetcher.m
//  MMGalery
//
//  Created by Petar Petrov on 07/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMFlickrManager.h"
#import "MMFlickrImage.h"

#import <objectiveflickr/ObjectiveFlickr.h>

@interface MMFlickrManager () <OFFlickrAPIRequestDelegate>

@property (assign, nonatomic) NSUInteger numberOfPages;

@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;
@property (strong, nonatomic) OFFlickrAPIRequest *flickrRequest;

@property (assign, nonatomic) NSUInteger currentPage;

@end

@implementation MMFlickrManager

static NSUInteger kNumberOfImagesPerPage = 30;

+ (instancetype)defaultManager {
    static MMFlickrManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[MMFlickrManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self configureManager];
    }
    
    return self;
}

- (void)firstPage {
    [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:@{@"per_page": @(kNumberOfImagesPerPage), @"page": @1}];
}

- (void)nextPage {
    
    if (self.currentPage + 1 < self.numberOfPages) {
        [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:@{@"per_page": @(kNumberOfImagesPerPage), @"page": @(self.currentPage + 1)}];
    }
}

- (void)previousPage {

}

- (NSUInteger)totalNumberOfPages {
    
    return self.numberOfPages;
}

- (NSUInteger)currentPageNumber {
    
    return self.currentPage;
}

#pragma mark - Private Methods

- (void)configureManager {
    self.flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:@"0b5a44c1ef22066c417ff95397e0de89" sharedSecret:@"f26b71873d292260"];
    
    self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
    self.flickrRequest.delegate = self;
}

#pragma mark - OFFlickrAPIRequestDelegate

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)request didCompleteWithResponse:(NSDictionary *)response
{
//    NSLog(@"%@", response);
    
    NSArray *photos = [response valueForKeyPath:@"photos.photo"];
    
    self.currentPage = ((NSString *)[response valueForKeyPath:@"photos.page"]).integerValue;
    self.numberOfPages = ((NSString *)[response valueForKeyPath:@"photos.pages"]).integerValue;
    
    NSMutableArray *photosInfo = [NSMutableArray array];
    
    //self.flickrRequest = nil;
    @autoreleasepool {
        for (NSDictionary *photoDic in photos) {
            MMFlickrImage *imageInfo = [[MMFlickrImage alloc] init];
            
            NSString *title = [photoDic objectForKey:@"title"];
            if (![title length]) {
                title = NSLocalizedString(@"No Title", nil);
            }
            
            imageInfo.title = title;
            imageInfo.smallImageURL = [self.flickrContext photoSourceURLFromDictionary:photoDic size:OFFlickrSmallSquareSize];
            imageInfo.largeImageURL = [self.flickrContext photoSourceURLFromDictionary:photoDic size:OFFlickrLargeSize];
            
            [photosInfo addObject:imageInfo];
        }
    }
    
    
    if ([self.flickrManagerDelegate respondsToSelector:@selector(flickrManager:imageURLs:page:)]) {
        [self.flickrManagerDelegate flickrManager:self imageURLs:[photosInfo copy] page:self.currentPage];
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)request didFailWithError:(NSError *)error
{
    if ([self.flickrManagerDelegate respondsToSelector:@selector(flickrManager:failedToWithError:)]) {
        [self.flickrManagerDelegate flickrManager:self failedToWithError:error];
    }
    
    NSLog(@"error %@", error);
}


@end
