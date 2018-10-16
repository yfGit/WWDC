//
//  PlayerController.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/29.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PlayerDemoController.h"
#import "AVPlayerView_Code.h"
@import AVFoundation;

@interface PlayerDemoController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PlayerDemoController

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 外放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)detailAction:(UIButton *)sender {
    
}

@end
