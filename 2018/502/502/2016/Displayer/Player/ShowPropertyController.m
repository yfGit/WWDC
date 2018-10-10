//
//  DetailController.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/29.
//  Copyright © 2018 SN. All rights reserved.
//

#import "ShowPropertyController.h"
#import "AVPlayerView_Xib.h"
@import AVFoundation;

#define AutoPlayTimeInterval 0.99

@interface ShowPropertyController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) CADisplayLink *link;

@property (nonatomic, copy) NSArray *playerObserverKeys;
@property (nonatomic, copy) NSArray *playerItemObserverKeys;

@property (weak, nonatomic) IBOutlet AVPlayerView_Xib *playerView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timebaseRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeRangesLabel;
@property (weak, nonatomic) IBOutlet UILabel *keepupLabel;
@property (weak, nonatomic) IBOutlet UILabel *bufferFullLabel;
@property (weak, nonatomic) IBOutlet UILabel *bufferEmptyLabel;
@property (weak, nonatomic) IBOutlet UILabel *controlStatusLabel;

@property (nonatomic, assign) BOOL pausedByManual; // 自动暂停
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewHeightConstraint;



/*
 Todo
 
 播放前显示第一帧图像
 加载动画
 前进后退时cache的数据是怎么样的Z
 */
@end

@implementation ShowPropertyController

- (void)dealloc
{
    NSLog(@"%s", __func__);
    for (NSString *key in self.playerObserverKeys) {
        [self.player removeObserver:self forKeyPath:key];
    }
    
    for (NSString *key in self.playerItemObserverKeys) {
        [self.player.currentItem removeObserver:self forKeyPath:key];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.link invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configure];
    
//    [self observeStatus];
}

- (void)configure
{
    AVPlayer *player = [AVPlayer new];
    self.player = player;
    
    if (@available(iOS 10.0, *)) {
        /* NO
            不等待缓冲
            reasonForWaitingToPlay 无效
            timeControlStatus 不会再出现 AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate
         */
//        player.automaticallyWaitsToMinimizeStalling = NO;
    } else {
        // Fallback on earlier versions
    }
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playerView.layer;
    
    if ([layer isKindOfClass:[AVPlayerLayer class]]) {
        [layer setPlayer:player];
    }
    
    NSURL *url = [NSURL URLWithString:@"https://media.w3.org/2010/05/sintel/trailer.mp4"];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (asset.playable) {
                
                NSArray *array = asset.tracks;
                CGSize videoSize = CGSizeZero;
                for (AVAssetTrack *track in array) {
                    if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                        videoSize = track.naturalSize;
                        
                        float ratio = videoSize.width / videoSize.height;
                        self.playViewHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width / ratio;
                    }
                }
                NSLog(@"==== %@", NSStringFromCGSize(videoSize));
                [player replaceCurrentItemWithPlayerItem:item];
                
                [player play];
                [self observeStatus];
            }
        });
    }];
    

}

- (void)observeStatus
{
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkAction)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.link = link;
    
    
    self.playerObserverKeys = @[@"status", @"reasonForWaitingToPlay", @"currentTime", @"timeControlStatus"];
    self.playerItemObserverKeys = @[@"loadedTimeRanges",  @"timebase", @"currentTime", @"playbackLikelyToKeepUp", @"playbackBufferFull", @"playbackBufferEmpty"];
    
    for (NSString *key in self.playerObserverKeys) {
        [self.player addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
    }
    
    for (NSString *key in self.playerItemObserverKeys) {
        [self.player.currentItem addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timebase_EffectiveRateChanged:) name:(NSString *)kCMTimebaseNotification_EffectiveRateChanged object:nil];
}

// 实时播放状态: 0, 停止; 1, 播放
// 点击播放到AVPlayer.timeControlStatus == .playing或者CMTimebaseGetRate(AVPlayerItem.timebase) > 0的间隔即是播放启动时长。
- (void)timebase_EffectiveRateChanged:(NSNotification *)n
{
    CGFloat rate = CMTimebaseGetRate(self.player.currentItem.timebase);
    NSLog(@"EffectiveRateChanged: %.2f", rate);
//    NSLog(@"%@", [NSThread currentThread]);
    NSInteger status = rate == 0 ? 4 : 1;
    if (self.player.rate != 0 && CMTimebaseGetRate(self.player.currentItem.timebase) == 0.0) {
        status = 3;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeStatusLabel:status];
    });
}


/**
 plyer.rate: 请求希望回放的播放速率  0.0 暂停, 1.0 希望当前项目的自然速度播放
 player.currentItem.timebase  rate: 当前的播放速率
 
 
 pasued  play() -> waiting  likelyToKeepUp -> playing
    |                   `- - <-  bufferEmpty  - |
     `- - <- pause()  - - - - - - - - - - - - - |
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isEqual:self.player]) {
        
        // 准确: AVPlayerTimeControlStatusPaused, StatusWaitingToPlayAtSpecifiedRate, StatusPlaying
        if ([keyPath isEqualToString:@"timeControlStatus"]) {
            NSInteger status = [change[NSKeyValueChangeNewKey] integerValue];
//            NSLog(@"timeControlStatus: %@", change[NSKeyValueChangeNewKey]);
            [self changeControlStatus:status];
            
        }else if ([keyPath isEqualToString:@"reasonForWaitingToPlay"]) {
            id obj = change[NSKeyValueChangeNewKey];
//            NSLog(@"reasonForWaitingToPlay: %@", change[NSK   eyValueChangeNewKey]);
            [self changeReason:obj];
        }
        else if ([keyPath isEqualToString:@"currentTime"]) { // 当前播放时间
            CMTime time = [change[NSKeyValueChangeNewKey] CMTimeValue];
            [self changeCurrentTime:time];
        }
        else if ([keyPath isEqualToString:@"status"]) { // 当前播放时间
            NSInteger status = [change[NSKeyValueChangeNewKey] integerValue];

        }
        
    }else {
        
        if ([keyPath isEqualToString:@"status"]) { // 状态
            NSInteger status = [change[NSKeyValueChangeNewKey] integerValue];
            [self changeStatusLabel:status];
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]) { // 加载状态
            NSArray *rangs = change[NSKeyValueChangeNewKey];
            
            for (NSValue *value in rangs) { // 基本上count都为1
                CMTimeRange range = [value CMTimeRangeValue];
                [self changeTimeRange:range];
                
                NSTimeInterval time = [self timeIntervalForLoadedTimeRanges:range];
                if (@available(iOS 10.0, *)) {
                    if (time > AutoPlayTimeInterval && !self.pausedByManual && self.player.automaticallyWaitsToMinimizeStalling == NO) {
                        [self.player play];
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            

        }
//        else if ([keyPath isEqualToString:@"timebase"]) { // 是否正在播放
//
//            CMTimebaseRef timebase =  (__bridge CMTimebaseRef)change[NSKeyValueChangeNewKey];
//            float rate = CMTimebaseGetRate(timebase);
////            NSLog(@"rate: %f", rate);
//            if (rate == 0) {
//                [self changeStatusLabel:3];
//            }else {
//                [self changeStatusLabel:1];
//            }
//        }
        else if ([keyPath isEqualToString:@"currentTime"]) { // 当前播放时间
            CMTime time = [change[NSKeyValueChangeNewKey] CMTimeValue];
            [self changeCurrentTime:time];
        }
        else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            BOOL keepup = [change[NSKeyValueChangeNewKey] boolValue];
            self.keepupLabel.text = keepup ? @"true" : @"false";
            if (keepup) {
                [self changeStatusLabel:5];
            }
        }
        else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
            BOOL bufferFull = [change[NSKeyValueChangeNewKey] boolValue];
            self.bufferFullLabel.text = bufferFull ? @"true" : @"false";
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            BOOL bufferEmpty = [change[NSKeyValueChangeNewKey] boolValue];
            self.bufferEmptyLabel.text = bufferEmpty ? @"true" : @"false";
        }
    }
}

- (NSTimeInterval)timeIntervalForLoadedTimeRanges:(CMTimeRange)timeRange
{
    NSTimeInterval start = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval end   = CMTimeGetSeconds(timeRange.duration);
    
    return end;
}

#pragma Action

- (IBAction)pauseAction:(UIButton *)sender {
    [self.player pause];
    self.pausedByManual = YES;
//    [self changeStatusLabel:4];
}

- (IBAction)playAction:(UIButton *)sender {
    [self.player play];
    [self changeStatusLabel:3];
    self.pausedByManual = NO;
}

- (IBAction)playImAction:(UIButton *)sender {
    if (@available(iOS 10.0, *)) {
//        [self pauseAction:nil]; // 得先停止, 如果和player.automaticallyWaitsToMinimizeStalling = NO全用;
        [self.player playImmediatelyAtRate:0.5];
    } else {
        // Fallback on earlier versions
    }
}

- (void)linkAction
{
    if (!self.player.currentItem) {
        return;
    }
    
    float rate = self.player.rate;
    float timeRate = CMTimebaseGetRate(self.player.currentItem.timebase);
    self.rateLabel.text = [NSString stringWithFormat:@"%.2f", rate];
    self.timebaseRateLabel.text = [NSString stringWithFormat:@"%.2f", timeRate];
    
    float currentTime = self.player.currentItem.currentTime.value / self.player.currentItem.currentTime.timescale;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%.2f", currentTime];
}


- (void)changeStatusLabel:(NSUInteger)status
{
    NSString *text;
    UIColor *color;
    if (status == 0) { // unknow
        text = @"Unknow";
        color = [UIColor redColor];
    }
    else if (status == 1) { // playing
        text = @"Playing";
        color = [UIColor greenColor];
    }
    else if (status == 2) { // faild
        text = @"Faild";
        color = [UIColor redColor];
    }
    else if (status == 3) { // wait
        text = @"Wait";
        color = [UIColor greenColor];
    }
    else  if (status == 4){ // pause
        text = @"Paused";
        color = [UIColor greenColor];
    }
    else  if (status == 5){ // readToPlay
        text = @"ReadToPlay";
        color = [UIColor greenColor];
    }
    
    self.statusLabel.text = text;
    self.statusLabel.backgroundColor = color;
}

- (void)changeTimeRange:(CMTimeRange)timeRange
{
    CMTime start  = timeRange.start;
    CMTime duration = timeRange.duration;
    
    NSAssert(start.timescale != 0, @"start.timescale == 0");
    NSAssert(duration.timescale != 0, @"duration.timescale == 0");
    
    CGFloat startTime = start.value / start.timescale; // 默认0, 暂停过则为暂停时间
    CGFloat loadTime = duration.value / duration.timescale;
    
    NSString *text = [NSString stringWithFormat:@"[%.2fs, %.2fs]", startTime, loadTime];
    self.timeRangesLabel.text = text;
}

- (void)changeCurrentTime:(CMTime)time
{
    CGFloat second = time.value / time.timescale;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%.2fs", second];
}

- (void)changeControlStatus:(NSInteger)status
{
    NSString *str = status == 0 ? @"Paused" : status == 1 ? @"WaitingToPlayAtSpecifiedRate" : @"Playing";
    self.controlStatusLabel.text = str;
}

- (void)changeReason:(id)obj
{
    // NSNull
    NSString *reason = [obj isKindOfClass:[NSString class]] ? (NSString *)obj : @"-";
    self.reasonLabel.text = reason;
}

@end
