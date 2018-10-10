//
//  AVPlayerView_xib.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/30.
//  Copyright © 2018 SN. All rights reserved.
//

#import "AVPlayerView_Xib.h"
@import AVFoundation;

@implementation AVPlayerView_Xib

// code 和 xib 不能同用? 
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
