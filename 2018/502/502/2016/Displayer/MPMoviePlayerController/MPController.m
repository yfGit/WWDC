//
//  MPController.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/28.
//  Copyright © 2018 SN. All rights reserved.
//

#import "MPController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MPController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePC;

@end

@implementation MPController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setup];
}

- (void)setup
{
    NSURL *url = [NSURL URLWithString:@"http://www.w3school.com.cn/example/html5/mov_bbb.mp4"];
    MPMoviePlayerController *pc = [[MPMoviePlayerController alloc] initWithContentURL:url];
    pc.view.frame = CGRectMake(0, 0, 300, 280);
    pc.view.center = self.view.center;
    pc.controlStyle = MPMovieControlStyleFullscreen;
    [pc play];
    self.moviePC = pc;
    
    [self.view addSubview:pc.view];
}

- (IBAction)showAction:(UIButton *)sender {
    // crash 此控制器不是视图控制器, 不能直接弹出  [MPMoviePlayerController _defaultAnimationController]
    [self presentViewController:self.moviePC animated:YES completion:nil];
}

- (IBAction)playAction:(UIButton *)sender {
    [self.moviePC play];
}

@end
