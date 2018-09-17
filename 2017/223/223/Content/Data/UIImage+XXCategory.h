//
//  UIImage+XXCategory.h
//  Category
//
//  Created by 许毓方 on 2018/6/10.
//  Copyright © 2018 许毓方. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XXCategory)

/// 不包括透明
@property (nonatomic, assign) CGRect renderRect;

#pragma mark - 圆角

- (UIImage *)xx_addCornerRadius:(CGFloat)radius size:(CGSize)size;

- (UIImage *)xx_addCornerRadius:(CGFloat)radius size:(CGSize)size byRoundingCorners:(UIRectCorner)corners;

#pragma mark - 截图

/// 截图
+ (UIImage *)xx_screenshotFromView:(UIView *)view;
/// 截图
+ (UIImage *)xx_screenshotFromWindow;

#pragma mark - 解码, 缩略图

- (UIImage *)xx_decoder;
- (UIImage *)xx_thumbnailImageWithSize:(CGSize)thumbnailSize; // 不等比

// iOS 10
- (UIImage *)xx_generateThumbnaiWithSize:(CGSize)thumbnailSize; // fit
- (UIImage *)xx_generateThumbnaiWithSize:(CGSize)thumbnailSize isFill:(BOOL)isFill;


#pragma mark - 大小

/// 图片大小: Bytes
- (CGFloat)xx_size;

@end
