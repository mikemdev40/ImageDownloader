//
//  ViewController.m
//  ImageDownloaderInObjC
//
//  Created by Michael Miller on 6/10/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

#import "CollectionViewController.h"
#import "ImageCollectionViewCell.h"
#import "FlickrClient.h"

@interface CollectionViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *getNewImagesButton;
//@property (nonatomic) FlickrClient *flickrClient;
@property (nonatomic) NSMutableArray *arrayOfImages;

@end

@implementation CollectionViewController {
    FlickrClient *flickrClient;
}

//custom setter
- (void)setImageCollectionView:(UICollectionView *)imageCollectionView {
    imageCollectionView.dataSource = self;
    imageCollectionView.delegate = self;
    _imageCollectionView = imageCollectionView;
}

//custom getter (lazy init)
- (NSMutableArray *)arrayOfImages {
    if (!_arrayOfImages) {
        self.arrayOfImages = [NSMutableArray array];
    }
    return _arrayOfImages;
}

//methods
- (IBAction)getNewImages:(UIButton *)sender {
    
    //weak pointer to ensure no strong reference cycles
    CollectionViewController * __weak weakSelf = self;
    
    //get 20 URLS from Flickr
    [flickrClient loadImages:^(BOOL success, NSArray *imageURLs, NSString *error) {
        if (success) {
            NSLog(@"SUCCESS!! %ld results", (long)[imageURLs count]);
            [weakSelf.arrayOfImages addObjectsFromArray:imageURLs];
            NSLog(@"items: %ld", (long)[weakSelf.arrayOfImages count]);
//            for (NSDictionary *item in weakSelf.arrayOfImages) {
//                NSLog(@"%@", item[@"url_s"]);
//            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.imageCollectionView reloadData];
            });
        }
//        if (!imageURLs) {
//            NSLog(@"nil value for images");
//        }
//        if (!error) {
//            NSLog(@"nil value for error");
//        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    flickrClient = [[FlickrClient alloc] init];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.arrayOfImages count] == 0) {
        NSLog(@"zero!!!");
    }
    return [self.arrayOfImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell"
                                                                              forIndexPath:indexPath];
    
    
    //if (cell.imageView.image == nil) {
        NSDictionary *imageInfo = self.arrayOfImages[indexPath.row];
        NSString *urlForImage = imageInfo[@"url_s"];
        [flickrClient retrieveImageFromURL:urlForImage
                              completionHandler:^(BOOL success, UIImage *image, NSString *error) {
                                  if (success) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          cell.imageView.image = image;
                                      });
                                  }
                              }];
   // }
    
    return cell;
}

@end
