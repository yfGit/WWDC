//
//  MPViewController.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/28.
//  Copyright © 2018 SN. All rights reserved.
//

#import "MPViewControllers.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MPViewControllers ()

@property (nonatomic, strong) MPMoviePlayerViewController *playerVC;

@end

@implementation MPViewControllers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showAction:nil];
    
    // 当播放时突然进入后台,播放vc会被系统dismiss,避免这种情况.最简单做法:移除系统进入后台通知.
    // 无效
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (IBAction)showAction:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.w3school.com.cn/example/html5/mov_bbb.mp4"];
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentViewController:vc animated:YES completion:^{
        [vc.moviePlayer play];
    }];
}

@end
