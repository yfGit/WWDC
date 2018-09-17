//
//  UIImageView+ClippingRect.m
//  223
//
//  Created by 许毓方 on 2018/9/9.
//  Copyright © 2018 SN. All rights reserved.
//

#import "UIImageView+ClippingRect.h"
#import "UIImage+XXCategory.h"

@implementation UIImageView (ClippingRect)

- (CGRect)contentClippingRect
{
    NSLog(@"%@", NSStringFromCGSize(self.image.size));
//    return self.image.renderRect;
    
    if (self.contentMode != UIViewContentModeScaleAspectFit || self.image == nil) return self.bounds;
    
    // UIViewContentModeScaleAspectFit  是 同时同等放大缩小, 到全包括为止
    // UIViewContentModeScaleAspectFill 是 同时同等放大, 到一边到边界为止
    
    CGFloat imageWidth = self.image.renderRect.size.width;
    CGFloat imageHeight = self.image.renderRect.size.height;
    
    CGFloat scale = 1;
    if (imageWidth > imageHeight) {
        scale = self.bounds.size.width / imageWidth;
    }else {
        scale = self.bounds.size.height / imageHeight;
    }
    
    CGSize clippingSize = CGSizeMake(imageWidth * scale, imageHeight * scale);
    CGFloat x = (self.bounds.size.width - clippingSize.width) / 2.0;
    CGFloat y = (self.bounds.size.height - clippingSize.height) / 2.0;
    
    return CGRectMake(x, y, clippingSize.width, clippingSize.height);
}

@end
