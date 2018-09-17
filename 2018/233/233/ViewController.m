//
//  ViewController.m
//  233
//
//  Created by 许毓方 on 2018/8/20.
//  Copyright © 2018 SN. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIWindow *exteranlWindow;
@property (nonatomic, strong) UIView *coolView;
@property (nonatomic, assign) BOOL feelingCool;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenConnect:) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDisconnect:) name:UIScreenDidDisconnectNotification object:nil];

}

- (void)screenConnect:(NSNotificationCenter *)n
{
    NSLog(@"%s", __func__);
}

- (void)screenDisconnect:(NSNotificationCenter *)n
{
    NSLog(@"%s", __func__);
}

/*
 1. 通知获取新window
 2. 改变 iPhone 默认行为; iPhone可交互 显示Private, 外接不可交互, 显示Public
 */

@end
