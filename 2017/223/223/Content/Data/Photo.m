//
//  Photo.m
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import "Photo.h"
#import "UIImage+XXCategory.h"

@interface Photo () {
    NSItemProvider *_itemProvider;
}

@end

@implementation Photo

static CGFloat max = 0;
static CGFloat min = CGFLOAT_MAX;
- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [self init]) {
        _identifier = [NSUUID UUID].UUIDString;
        _image = image;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval befor = CACurrentMediaTime();
        CGSize size = CGSizeMake(200, 200);
        self.thumbnail = [image xx_thumbnailImageWithSize:size];
//        self.thumbnail = [image xx_generateThumbnaiWithSize:size isFill:YES];
        
        NSTimeInterval after = CACurrentMediaTime();
        NSTimeInterval interval = after - befor;
        if (interval > max) {
            max = interval;
        }
        if (interval < min) {
            min = interval;
        }
        NSLog(@"%f - %f", min, max);
//        });
    }
    return self;
}

- (UIImage *)thumbnail
{
    if (!_thumbnail) {
        _thumbnail = [self _generateThumbnaiForImage:self.image thumbnailSize:CGSizeMake(50, 50)];
    }
    return _thumbnail;
}

- (NSItemProvider *)itemProvider
{
    if (!_itemProvider) {
        _itemProvider = [[NSItemProvider alloc] initWithObject:self.image];
    }
    return _itemProvider;
}

/// 不作固定, 可变样式
- (UIDragPreview * _Nullable (^)(void))dragPreview
{NSLog(@"before"); // tips: 有时调用的次数不对
    __weak typeof(self) _self = self;
    
    UIDragPreview * _Nullable (^dragPreview)(void) = ^(){
        __strong typeof(_self) self = _self;
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:self.image];
        imgView.frame = CGRectMake(0, 0, 100, 100); // 控制大小, 否则显示速度慢, 内存高(ipad都400M的 ??)
        UIDragPreview *preview = [[UIDragPreview alloc] initWithView:imgView];
        NSLog(@"1111"); // tips: 有时调用的次数不对
        return preview;
    };
    
    return dragPreview;
}

- (UIImage *)_generateThumbnaiForImage:(UIImage *)image thumbnailSize:(CGSize)thumbnailSize
{
    if (!image || CGSizeEqualToSize(thumbnailSize, CGSizeZero)) return nil;

    CGSize imageSize = image.size;
    CGFloat widthRatio = thumbnailSize.width / imageSize.width;
    CGFloat heightRatio = thumbnailSize.height / imageSize.height;
    CGFloat scaleFactor = widthRatio > heightRatio ? widthRatio : heightRatio;

    // iOS 10
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:thumbnailSize];
    UIImage *thumbnail = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGSize size = CGSizeMake(imageSize.width * scaleFactor, imageSize.height *scaleFactor);
        CGFloat x = (thumbnailSize.width - size.width) / 2.0;
        CGFloat y = (thumbnailSize.height - size.height) / 2.0;
        [image drawInRect:CGRectMake(x, y, size.width, size.height)];
    }];

    return thumbnail;
}

// 速度慢
- (UIImage *)_2generateThumbnaiForImage:(UIImage *)image thumbnailSize:(CGSize)thumbnailSize
{
    NSDictionary *option = @{(__bridge id)kCGImageSourceShouldCache : @NO};
    NSData *data = UIImagePNGRepresentation(image);
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)option);
    CGFloat maxDimensionInPixels = MAX(thumbnailSize.height, thumbnailSize.width);
    
    NSDictionary *thumbnailOpt = @{(__bridge id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                   (__bridge id)kCGImageSourceShouldCacheImmediately : @YES,
                                   (__bridge id)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                   (__bridge id)kCGImageSourceThumbnailMaxPixelSize : @(maxDimensionInPixels)
                                   };
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOpt);
    return [UIImage imageWithCGImage:imageRef];
}

@end
