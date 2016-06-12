//
//  FlickrClient.h
//  ImageDownloaderInObjC
//
//  Created by Michael Miller on 6/10/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageCollectionViewCell.h"

@interface FlickrClient : NSObject

@property (nonatomic) NSMutableArray *images;

- (void)loadImages:(void (^)(BOOL success, NSArray *imageURLs, NSString *error))completionHandler;
- (void)retrieveImageFromURL:(NSString *)urlOfImage completionHandler:(void (^)(BOOL success, UIImage *image, NSString *error))completionHandler;

@end