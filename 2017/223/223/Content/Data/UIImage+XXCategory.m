//
//  UIImage+XXCategory.m
//  Category
//
//  Created by 许毓方 on 2018/6/10.
//  Copyright © 2018 许毓方. All rights reserved.
//

#import "UIImage+XXCategory.h"
#import <objc/runtime.h>

@implementation UIImage (XXCategory)

- (void)setRenderRect:(CGRect)renderRect {
    objc_setAssociatedObject(self, @selector(renderRect), [NSValue valueWithCGRect:renderRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)renderRect {
    CGRect rect = [objc_getAssociatedObject(self, _cmd) CGRectValue];
    return CGRectEqualToRect(CGRectZero, rect) ? (CGRect){{0, 0}, self.size} : rect;
}

#pragma mark - 圆角

- (UIImage *)xx_addCornerRadius:(CGFloat)radius size:(CGSize)size
{
    return [self xx_addCornerRadius:radius size:size byRoundingCorners:UIRectCornerAllCorners];
}

- (UIImage *)xx_addCornerRadius:(CGFloat)radius size:(CGSize)size byRoundingCorners:(UIRectCorner)corners
{
    NSAssert(!CGSizeEqualToSize(size, CGSizeZero), @"imageView size 不能为空");
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIImage *image = nil;
    
    __weak typeof(self) wSelf = self;
    if (@available(iOS 10, *)) {
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
        format.opaque = NO;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:rect.size format:format];
        image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull ctx) {

            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
            CGContextAddPath(ctx.CGContext, path.CGPath);
            CGContextClip(ctx.CGContext);
            [wSelf drawInRect:rect];
            CGContextDrawPath(ctx.CGContext, kCGPathFillStroke);
        }];
    }
    else {
        UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
        CGContextAddPath(ctx, path.CGPath);
        CGContextClip(ctx);
        
        [self drawInRect:rect];
        CGContextDrawPath(ctx, kCGPathFillStroke);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

#pragma mark - 截图
+ (UIImage *)xx_screenshotFromView:(UIView *)view
{
    NSAssert(!CGSizeEqualToSize(view.bounds.size, CGSizeZero), @"view size 不能为空");
    NSAssert([NSThread isMainThread], @"主线程");
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)xx_screenshotFromWindow
{
    return [self xx_screenshotFromView:[UIApplication sharedApplication].delegate.window];
}


#pragma mark - 大小 size

- (CGFloat)xx_size
{
    CGFloat height = CGImageGetHeight(self.CGImage);
    CGFloat row    = CGImageGetBytesPerRow(self.CGImage);
    
    return height * row;
}


#pragma mark - 解码

- (UIImage *)xx_decoder
{
    return [self xx_thumbnailImageWithSize:self.size];
}

- (UIImage *)xx_thumbnailImageWithSize:(CGSize)thumbnailSize
{
    // 注释代码会都会等比缩放, UIViewContentMode 也没用
//    CGFloat widthRatio = thumbnailSize.width / self.size.width;
//    CGFloat heightRatio = thumbnailSize.height / self.size.height;
//    CGFloat scaleFactor = widthRatio < heightRatio ? widthRatio : heightRatio;
//    scaleFactor = widthRatio > heightRatio ? widthRatio : heightRatio;
//    CGFloat width = self.size.width * scaleFactor;
//    CGFloat height = self.size.height * scaleFactor;
    
    CGImageRef imageRef = self.CGImage;
    
    CGFloat width  = thumbnailSize.width;
    CGFloat height = thumbnailSize.height;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
    if (!context) return nil;
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CFRelease(context);
    
    if (!newImage) return nil;
    
    return [[UIImage alloc] initWithCGImage:newImage scale:self.scale orientation:self.imageOrientation];
}

/*
 1. 要有 size 且 确定等比方式: aspectFit(没填充上的地方透明) 或 aspectFill  和 UIViewContentMode 一样
 2. rect 就是最终效果, UIViewContentMode 不起作用
 3. 返回的图片是个矩形, size 就是图片真实的 self.size
 */
/// 速度快于  CGImageSourceCreateThumbnailAtIndex
- (UIImage *)xx_generateThumbnaiWithSize:(CGSize)thumbnailSize
{
    return [self xx_generateThumbnaiWithSize:thumbnailSize isFill:NO];
}

- (UIImage *)xx_generateThumbnaiWithSize:(CGSize)thumbnailSize isFill:(BOOL)isFill
{
    CGSize imageSize = self.size;
    CGFloat widthRatio = thumbnailSize.width / imageSize.width;
    CGFloat heightRatio = thumbnailSize.height / imageSize.height;
    
    CGFloat scaleFactor;
    if (isFill) {
        scaleFactor = widthRatio > heightRatio ? widthRatio : heightRatio; // fill
    }else {
        scaleFactor = widthRatio < heightRatio ? widthRatio : heightRatio; // fit
    }
    
    UIImage *thumbnail = nil;
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:thumbnailSize];
        
        __block CGRect rect;
        thumbnail = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            
            CGSize size = CGSizeMake(imageSize.width * scaleFactor, imageSize.height *scaleFactor);
            CGFloat x = (thumbnailSize.width - size.width) / 2.0;
            CGFloat y = (thumbnailSize.height - size.height) / 2.0;
            rect = CGRectMake(x, y, size.width, size.height);
            
//            NSLog(@"==== >  %@", NSStringFromCGRect(rect));
            [self drawInRect:rect];
        }];
        thumbnail.renderRect = rect;
        
    } else {
        NSLog(@"UIGraphicsImageRenderer needs iOS 10");
    }
//    NSLog(@"==== >  %@", NSStringFromCGRect(self.renderRect));
    return thumbnail;
}

// https://developer.apple.com/videos/play/wwdc2018/219/?time=670
// 速度不理想, 且 第三方SDK都是 async data->image->xx_decoder
+ (UIImage *)xx_thumbnailWithImageUrl:(NSURL *)url size:(CGSize)size
{
    // For 64-bit default ture, false 生成CGImageSourceRef 时，不需要先解码(不要立即解码这个图像)
    NSDictionary *option = @{(__bridge id)kCGImageSourceShouldCache : @NO};
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, (__bridge CFDictionaryRef)option);
    // 水平和垂直轴上计算, 该计算基于期望的图片大小以及我们要渲染的像素和点大小
    CGFloat maxDimensionInPixels = MAX(size.height, size.width);
    
    NSDictionary *downsampleOpt = @{(__bridge id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                    (__bridge id)kCGImageSourceShouldCacheImmediately : @YES,
                                    (__bridge id)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                    (__bridge id)kCGImageSourceThumbnailMaxPixelSize : @(maxDimensionInPixels)
                                    };
    
    // kCGImageSourceShouldCacheImmediately设为true，以此控制系统以计算出的size创建Image Buffer并解压。
    // 在创建Thumbnail时直接解码，这样就把解码的时机控制在这个函数内
    CGImageRef downsampleImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)downsampleOpt);
    return [UIImage imageWithCGImage:downsampleImage];
}
/*
 kCGImageSourceShouldCacheImmediately: 告诉 Core graphics 解码时机
 */

@end
