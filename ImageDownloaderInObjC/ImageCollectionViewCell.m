//
//  ImageCollectionViewCell.m
//  ImageDownloaderInObjC
//
//  Created by Michael Miller on 6/10/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

@synthesize imageView = _imageView;

- (void)setImageView:(UIImageView *)imageView {
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView = imageView;
}

- (UIImageView *)imageView {
    return _imageView;
}

@end
