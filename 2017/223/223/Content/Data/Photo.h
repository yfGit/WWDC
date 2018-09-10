//
//  Photo.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Photo : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIImage *thumbnail;


@property (nonatomic, strong, readonly) NSItemProvider *itemProvider;
/// 预览图
@property (nonatomic, copy, readonly) UIDragPreview * _Nullable (^dragPreview)(void);


- (instancetype)initWithImage:(UIImage *)image;



@end
