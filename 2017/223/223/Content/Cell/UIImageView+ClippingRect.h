//
//  UIImageView+ClippingRect.h
//  223
//
//  Created by 许毓方 on 2018/9/9.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ClippingRect)

/// UIViewContentModeScaleAspectFit 图片内容大小, 根据图片改变
- (CGRect)contentClippingRect;

@end
