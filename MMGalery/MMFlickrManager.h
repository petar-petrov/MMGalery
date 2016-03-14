//
//  MMFlickrFetcher.h
//  MMGalery
//
//  Created by Petar Petrov on 07/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMFlickrManagerDelegate;

@interface MMFlickrManager : NSObject

@property (weak, nonatomic) id <MMFlickrManagerDelegate> flickrManagerDelegate;

+ (instancetype)defaultManager;

- (void)firstPage;
- (void)nextPage; // returns nil if there are no more pages
- (void)previousPage; // maybe not required

- (NSUInteger)totalNumberOfPages;
- (NSUInteger)currentPageNumber;

@end

@protocol MMFlickrManagerDelegate <NSObject>

@optional

- (void)flickrManager:(MMFlickrManager *)manager imageURLs:(NSArray *)urls page:(NSUInteger)pageNumber;
- (void)flickrManager:(MMFlickrManager *)manager failedToWithError:(NSError *)error;

@end
