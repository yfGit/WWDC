//
//  PlayerController.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/29.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PlayerDemoController.h"
@import AVFoundation;
#import "ToolView.h"
#import "AVPlayerView.h"

@interface PlayerDemoController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;

@property (nonatomic, strong) ToolView *toolView;

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
    
//    [self configure];
    
    [self.view bringSubviewToFront:self.detailBtn];
    
    [self toolAction];

    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    self.playerLayer.frame = self.view.bounds; // 没有动画, 用View容器
}

- (void)configure
{
    AVPlayer *player = [AVPlayer playerWithPlayerItem:nil];
    self.player = player;
    
    
    // 解决横屏动画问题
    AVPlayerView *containView = [AVPlayerView new];
    containView.frame = self.view.bounds;
    containView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    AVPlayerLayer *layer = (AVPlayerLayer *)containView.layer; // 不用设置Frame
    [layer setPlayer:player];
    [self.view addSubview:containView];
    
    
    NSURL *url = [NSURL URLWithString:@"http://113.105.248.47/12/p/q/q/q/pqqqejcztuivctyaajwfxqhquhpqdr/hc.yinyuetai.com/9F53016108F308CBD739B4B37BC6DCAF.mp4"];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    
    [player replaceCurrentItemWithPlayerItem:item];
    
    [self.player.currentItem addObserver:self forKeyPath:@"timebase" options:NSKeyValueObservingOptionNew context:nil];
//    [player play];
}
- (IBAction)detailAction:(UIButton *)sender {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
            if ([keyPath isEqualToString:@"timebase"]) { // 是否正在播放
    
                CMTimebaseRef timebase =  (__bridge CMTimebaseRef)change[NSKeyValueChangeNewKey];
                float rate = CMTimebaseGetRate(timebase);
                NSLog(@">>>>>>>>>> rate: %f", rate);
            }
}

- (void)toolAction
{
    // 进度条
    __weak typeof(self) _self = self;
    
    self.toolView.manualProgressBlock = ^(CGFloat progress) {
        __strong typeof(_self) self = _self;
        if (self.player.currentItem.status == 0) return ;
        // 共多少秒
        CGFloat seconds = self.player.currentItem.duration.value / self.player.currentItem.duration.timescale;
        seconds *= progress;
        CMTime time = CMTimeMakeWithSeconds(seconds, self.player.currentTime.timescale);
        [self.player seekToTime:time completionHandler:^(BOOL finished) {
            __strong typeof(_self) self = _self;
            NSLog(@"finish: %@", finished ? @"YES": @"NO");
            if (finished) {
                [self.player play];
            }
        }];
    };
    
    
    // 后退 15
    self.toolView.backCallback = ^{
        __strong typeof(_self) self = _self;
        CGFloat seconds = self.player.currentItem.duration.value / self.player.currentItem.duration.timescale;
    };
    
    // 前进 15
    self.toolView.forwardCallback = ^{
        __strong typeof(_self) self = _self;
        CGFloat seconds = self.player.currentItem.duration.value / self.player.currentItem.duration.timescale;
    };
}

- (void)timerAction
{
    CGFloat second = self.player.currentTime.value / self.player.currentTime.timescale;
    if (self.player.currentItem.duration.timescale == 0) return;
    CGFloat sum = (self.player.currentItem.duration.value / self.player.currentItem.duration.timescale);
    
    self.toolView.slider.value = second / sum;
}

- (ToolView *)toolView
{
    if (!_toolView) {
        _toolView = [ToolView new];
        CGFloat height = 60;
        CGFloat bottom = CGRectGetHeight(self.tabBarController.tabBar.frame) + 34;
        _toolView.frame = CGRectMake(0, self.view.bounds.size.height-height-bottom, self.view.bounds.size.width, height);
        _toolView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:_toolView];
    }
    return _toolView;
}

@end
