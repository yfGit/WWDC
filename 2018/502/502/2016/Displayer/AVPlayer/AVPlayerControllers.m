//
//  AVPlayerController.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/28.
//  Copyright © 2018 SN. All rights reserved.
//

#import "AVPlayerControllers.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerControllers ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) NSMutableArray *movieUrls;

@end

@implementation AVPlayerControllers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.movieUrls = @[@"http://www.w3school.com.cn/example/html5/mov_bbb.mp4",
                       @"https://media.w3.org/2010/05/sintel/trailer.mp4",
                       @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
                       ].mutableCopy;
    
    
    [self setup2];
    
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)configurePlayer
{    
    NSURL *url = [NSURL URLWithString:self.movieUrls[0]];
    self.player  = [AVPlayer playerWithURL:url];
}

// replaceCurrentItemWithPlayerItem: 可切换视频源
- (void)configurePlayer2
{
    NSURL *url = [NSURL URLWithString:self.movieUrls[0]];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.player  = [AVPlayer playerWithPlayerItem:item]; // 开始设置回放管道 (音频)
}

- (void)setup
{
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player]; // 开始设置回放管道 (音频+视频)解码视频, AVPlayer 载体, 否则只有声音
    layer.frame = CGRectMake(0, 0, 200, 180);
    layer.position = self.view.center;
    [self.view.layer addSublayer:layer];
    layer.borderColor = [UIColor blackColor].CGColor;
    layer.borderWidth = 2;

    
//    [self.player play]; // 播放
    
    /*
     回放管道更好的方法
     
     AVPlayer *player = [AVPlayer new];
     AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
     AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@""]];
     [player play]; // first
     [player replaceCurrentItemWithPlayerItem:item]; // 才开始设置回放管道(音频+视频)
     */
}

- (void)setup2
{
    AVPlayer *player = [AVPlayer new];
    self.player = player;
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.movieUrls[1]]];
    [player play]; // first
    [player replaceCurrentItemWithPlayerItem:item]; // 才开始设置回放管道(音频+视频)
    
    
    layer.frame = CGRectMake(0, 0, 200, 180);
    layer.position = self.view.center;
    [self.view.layer addSublayer:layer];
    layer.borderColor = [UIColor blackColor].CGColor;
    layer.borderWidth = 2;
    

}

- (IBAction)playAction:(UIButton *)sender {
    
//    NSURL *url = [NSURL URLWithString:self.movieUrls[1]];
//    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
//    [self.player replaceCurrentItemWithPlayerItem:item];
    
    if (self.player.rate != 0) {
        [self.player pause];
    }else {
        [self.player play];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"status: %@", change[NSKeyValueChangeNewKey]);
//        [self logMethod];
    }
}

- (void)logMethod
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%lld - %d - %u - %lld", self.player.currentItem.duration.value, self.player.currentItem.duration.timescale, self.player.currentItem.duration.flags, self.player.currentItem.duration.epoch);
        [self logMethod];
    });
}

- (void)dealloc
{
    [self.player removeObserver:self forKeyPath:@"status"];
}
@end
