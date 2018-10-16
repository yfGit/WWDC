//
//  PlayerLooper.m
//  502
//
//  Created by 许毓方 on 2018/10/15.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PlayerLooper.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerLooper ()

@property (nonatomic, assign) NSInteger loopCount;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) AVQueuePlayer *player;

@property (nonatomic, strong) AVPlayerLooper *playerLooper;

@end

@implementation PlayerLooper

- (id)initWithUrl:(NSURL *)url loopCount:(NSInteger)loopCount
{
    self = [super init];
    if (self) {
        _url = url;
        _loopCount = loopCount;
    }
    
    return self;
}

- (void)startInLayer:(CALayer *)layer
{
    AVQueuePlayer *player = [AVQueuePlayer new];
    self.player = player;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = layer.bounds;
    [layer addSublayer:playerLayer];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.url];
    [item.asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        NSLog(@"%@", [NSThread currentThread]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSError *error = nil;
            AVKeyValueStatus status = [item.asset statusOfValueForKey:@"tracks" error:&error];
            
            if (status == AVKeyValueStatusLoaded) {
                
                NSLog(@"%@", item.asset.tracks);
                
                // 无限循环, 次数还得自己写逻辑
                if (@available(iOS 10.0, *)) {
                    self.playerLooper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:item];
                }
                
                [player play];
                [self _addObserve];
            }
        });
    }];
}

- (void)stop
{
    [self.player pause];
    [self _removeObserve];
}

#pragma mark - Private

- (void)_addObserve
{
    [self.playerLooper addObserver:self forKeyPath:@"loopCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)_removeObserve
{
    [self.playerLooper removeObserver:self forKeyPath:@"loopCount"];
}

#pragma mark - Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loopCount"]) {
        
        if (self.loopCount > 0 && self.playerLooper.loopCount >= self.loopCount-1) {
            [self.playerLooper disableLooping];
        }
    }
}


/*
 由于音视频媒体的时间相关的特性，在成功初始化的时候，asset的一些或者全部属性可能你不会立刻可用。
 对于任何key的value，可以在任何时刻请求，然后asset会以同步的方式返回value，所以会阻塞当前调用的线程。
 为了避免阻塞，可以注册感兴趣的key，然后当value可用时会有通知，具体可以查看AVAsynchronousKeyValueLoading。
 
 
 @protocol AVAsynchronousKeyValueLoading
 
 - loadValuesAsynchronouslyForKeys:completionHandler:
 
 异步: 当加载所有指定键值时，如果在处理的后期出现加载错误，或者在AVAsset实例上调用cancelLoading，则异步进行加载。
 回调将在任意后台队列上调用。在执行任何与用户接口相关的操作之前，您应该将其分派回主队列。
 
 同步: 如果所有指定的键之前都已加载(AVKeyValueStatusLoaded的状态)，或者立即发生I/O错误或其他与格式相关的错误。
 
 
 -(AVKeyValueStatus) statusOfValueForKey:
 您在键中指定的键的完成状态不一定相同——有些可能已经加载，有些可能已经失败。您必须使用此方法分别检查每个键的状态
 
 */


@end
