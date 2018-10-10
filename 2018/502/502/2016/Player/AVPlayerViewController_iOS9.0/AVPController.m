//
//  AVPController.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/28.
//  Copyright © 2018 SN. All rights reserved.
//

#import "AVPController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AVPController ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerViewController *pViewController; // 也要强引用

@end

@implementation AVPController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPlayer];
    
    [self showView];
    
//    [self showVC];
    
    [self.player play];
}


- (void)setupPlayer
{
    NSURL *url = [NSURL URLWithString:@"https://media.w3.org/2010/05/sintel/trailer.mp4"];
    self.player = [AVPlayer playerWithURL:url];
    
    
    AVPlayerViewController *vc = [AVPlayerViewController new];
    vc.player = self.player;
    self.pViewController = vc;
}

- (void)showView
{
    self.pViewController.view.frame = CGRectMake(0, 0, 300, 280);
    self.pViewController.view.center = self.view.center;
    [self.view addSubview:self.pViewController.view];
}

- (IBAction)showAction:(UIButton *)sender {
    AVPlayerViewController *vc = [AVPlayerViewController new];
    NSURL *url = [NSURL URLWithString:@"https://media.w3.org/2010/05/sintel/trailer.mp4"];
    self.player = [AVPlayer playerWithURL:url];
    vc.player = self.player; // 用之前的搬动进度条自动播放有问题
    
    [self presentViewController:vc animated:YES completion:nil];
}

@end
