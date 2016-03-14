//
//  MMFlickrImage.h
//  MMGalery
//
//  Created by Petar Petrov on 09/03/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMFlickrImage : NSObject

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *smallImageURL;
@property (strong, nonatomic) NSURL *largeImageURL;

@end
