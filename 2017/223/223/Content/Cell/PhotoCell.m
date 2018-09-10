//
//  PhotoCell.m
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PhotoCell.h"
#import "Photo.h"
#import "UIImageView+ClippingRect.h"

@interface PhotoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;

@end

@implementation PhotoCell

+ (NSString *)identifier {
    return @"PhotoCellId";
}


- (void)configureWithPhoto:(Photo *)photo
{
    self.photoImgView.image = photo.image;
}

- (CGRect)clippingRectForPhoto
{
    return [self.photoImgView contentClippingRect];
}

@end
