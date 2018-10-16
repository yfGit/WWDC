//
//  QueueLooper.m
//  502
//
//  Created by 许毓方 on 2018/10/15.
//  Copyright © 2018 SN. All rights reserved.
//

#import "QueueLooper.h"
#import <AVFoundation/AVFoundation.h>


@interface QueueLooper ()

@property (nonatomic, assign) NSInteger loopCount;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) AVQueuePlayer *player;

@property (nonatomic, assign) NSInteger numberOfPlayed;

@end

@implementation QueueLooper

- (id)initWithUrl:(NSURL *)url loopCount:(NSInteger)loopCount
{
    self = [super init];
    if (self) {
        _url = url;
        _loopCount = loopCount;
        _numberOfPlayed = 0;
    }
    
    return self;
}

- (void)startInLayer:(CALayer *)layer
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(_playbackFinished:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:nil];
    
    self.player = [AVQueuePlayer new];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = layer.bounds;
    [layer addSublayer:playerLayer];
    

    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.url options:@{}];
    
    [urlAsset loadValuesAsynchronouslyForKeys:@[] completionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSAssert(CMTimeCompare(urlAsset.duration, CMTimeMake(1, 100)) >= 0, @"Can't loop since asset duration too short. Duration is %f", CMTimeGetSeconds(urlAsset.duration));
            
            // 两个以上才能 无间隙 播放
            NSInteger numbersOfPlayerItem = (int)(1.0 / CMTimeGetSeconds(urlAsset.duration)) + 2;
            
            for (NSInteger i = 0; i < numbersOfPlayerItem; i++) {
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:urlAsset];
                [self.player insertItem:item afterItem:nil];
            }
//            NSLog(@"====== %@", self.player.items);
            
            [self _addObserve];
            [self.player play];
        });
    }];
}

- (void)stop
{
    [self.player pause];
    [self _removeObserve];
}


#pragma mark - Private

- (void)_playbackFinished:(NSNotificationCenter *)n
{
    return;
    
    self.numberOfPlayed ++;
    if (self.loopCount > 0 && self.numberOfPlayed >= self.loopCount) {
        [self stop];
    }
    // 不行, 此时 item 还没有被移除, 同一个 item 不能被添加多次
//    [self.player insertItem:item afterItem:nil];
    
}

- (void)_addObserve
{
    [self.player addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)_removeObserve
{
    [self.player removeObserver:self forKeyPath:@"currentItem"];
}

#pragma mark - Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem"]) {
        
        self.numberOfPlayed ++;
//        NSLog(@"%ld", (long)self.numberOfPlayed);
        if (self.loopCount > 0 && self.numberOfPlayed >= self.loopCount) {
            [self.player pause];
            return;
        }
        
        // 被移除的 item, 重新添加进去, 不重新生成
        AVPlayerItem *oldItem = change[NSKeyValueChangeOldKey];
        [oldItem seekToTime:kCMTimeZero];
        
        [self _removeObserve]; // tips: 避免任何递归的可能
        [self.player insertItem:oldItem afterItem:nil];
        [self _addObserve];
    }
}

@end
