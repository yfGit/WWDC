//
//  DebugFunc.m
//  233
//
//  Created by 许毓方 on 2018/8/21.
//  Copyright © 2018 SN. All rights reserved.
//

#import "DebugFunc.h"

@implementation DebugFunc

+ (id)resultWithObject:(id)object selector:(SEL)sel
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [object performSelector:sel];
#pragma clang diagnostic pop
}


+ (NSArray *)debugForSubView:(UIView *)view
{
    SEL sel = NSSelectorFromString(@"recursiveDescription");

    return [self resultWithObject:view selector:sel];

}
+ (NSArray *)debugForParentView:(UIView *)view
{
    SEL sel = NSSelectorFromString(@"_parentDescription");
    
    return [self resultWithObject:view selector:sel];
}
+ (NSArray *)debugViewController
{
    SEL sel = NSSelectorFromString(@"_printHierarchy");

    return [self resultWithObject:UIViewController.class selector:sel];
}

@end
