//
//  DebugFunc.h
//  233
//
//  Created by 许毓方 on 2018/8/21.
//  Copyright © 2018 SN. All rights reserved.
//
//  不能提交到app, 会被拒

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DebugFunc : NSObject

+ (NSArray *)debugForSubView:(UIView *)view;
+ (NSArray *)debugForParentView:(UIView *)view;
+ (NSArray *)debugViewController;

@end
