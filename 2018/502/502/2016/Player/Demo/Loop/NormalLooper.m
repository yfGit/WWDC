//
//  NormalLooper.m
//  502
//
//  Created by 许毓方 on 2018/10/15.
//  Copyright © 2018 SN. All rights reserved.
//

#import "NormalLooper.h"
#import <AVFoundation/AVFoundation.h>

@interface NormalLooper ()

@property (nonatomic, assign) NSInteger loopCount;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) NSInteger numberOfPlayed;

@end

@implementation NormalLooper

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startInLayer:(CALayer *)layer
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_playbackFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    self.player = [AVPlayer new];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = layer.bounds;
    [layer addSublayer:playerLayer];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.url];
    
    [item.asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([item.asset statusOfValueForKey:@"playable" error:nil] == AVKeyValueStatusLoaded) {
                [self.player play];
                [self.player replaceCurrentItemWithPlayerItem:item];
            }
        });
    }];
}

- (void)stop
{
    [self.player pause];
}

- (void)_playbackFinished:(NSNotification *)n
{
    self.numberOfPlayed ++;
    if (self.loopCount > 0 && self.numberOfPlayed >= self.loopCount) {
        [self.player pause];
        
    }else {
        [self.player.currentItem seekToTime:kCMTimeZero];
        [self.player play];
    }
}


@end
