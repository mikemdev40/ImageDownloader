//
//  FlickrClient.m
//  ImageDownloaderInObjC
//
//  Created by Michael Miller on 6/10/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrClient.h"

@interface FlickrClient ()


@end

@implementation FlickrClient

//custom getter with lazy initialization
- (NSMutableArray *)images {
    if (!_images) {
        NSLog(@"loaded");
        self.images = [NSMutableArray array];
    }
    return _images;
}

- (void)loadImages:(void (^)(BOOL success, NSArray *imageURLs, NSString *error))completionHandler {
    
    NSURL *imageURL = [[NSURL alloc] initWithString: self.getFlickrURL];
    
    NSURLSession *mySession = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [mySession dataTaskWithURL:imageURL completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error == nil) {
          NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
          NSInteger statusCode = status.statusCode;
          if (statusCode >= 200 && statusCode < 300) {
              
              NSDictionary *parsedData = [self parseJSONData:data];
              if (parsedData) {
                  NSDictionary *photos = parsedData[@"photos"];
                  if (photos) {
                      NSArray *photoArray = photos[@"photo"];
                      completionHandler(YES, photoArray, nil);
                  } else {
                      completionHandler(NO, nil, @"problem parsing photoarray");
                  }
              } else {
                  completionHandler(NO, nil, @"problem parsing photo");
              }
          } else {
              completionHandler(NO, nil, [NSString stringWithFormat:@"bad status code: %ld", (long)statusCode]);
          }
      } else {
          completionHandler(NO, nil, error.localizedDescription);
      }
    }];
    [task resume];
}

- (void)retrieveImageFromURL:(NSString *)urlOfImage completionHandler:(void (^)(BOOL success, UIImage *image, NSString *error))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlOfImage]];
    
    NSCachedURLResponse *cachedImage = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (cachedImage.data) {
        NSLog(@"cached");
        UIImage *image = [UIImage imageWithData:cachedImage.data];
        completionHandler(YES, image, nil);
    } else {
        NSLog(@"downloading");
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
                NSInteger statusCode = status.statusCode;
                if (statusCode >= 200 && statusCode < 300) {
                    
                    UIImage *image = [UIImage imageWithData:data];
                    completionHandler(YES, image, nil);
                    
                } else {
                    completionHandler(NO, nil, [NSString stringWithFormat:@"bad status code: %ld", (long)statusCode]);
                }
            } else {
                completionHandler(NO, nil, error.localizedDescription);
            }
        }];
        [task resume];
    }
}

- (NSString *)getFlickrURL {
    
    return @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=d6f61e38264b168dca93e3d4f2fbc8f5&tags=cat&extras=url_s&per_page=200&format=json&nojsoncallback=1";
    
}

- (NSDictionary *)parseJSONData:(NSData *)dataToParse {
    
    id JSONData;
    NSError *error;
    
    JSONData = [NSJSONSerialization JSONObjectWithData:dataToParse options:NSJSONReadingAllowFragments error:&error];
    
    if (error == nil) {
        return (NSDictionary *)JSONData;
    } else {
        NSLog(@"%@", error);
        return nil;
    }
}

@end

