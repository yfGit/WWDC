//
//  YYFPSLabel.h
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YYLabel_APPDELEGATE_CONFIG  \
\
self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]; \
self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController]; \
[self.window makeKeyAndVisible]; \
\
YYFPSLabel *fpsLabel = [[YYFPSLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)]; \
fpsLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, 100); \
fpsLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; \
[self.window addSubview:fpsLabel];

/**
 Show Screen FPS...
 
 The maximum fps in OSX/iOS Simulator is 60.00.
 The maximum fps on iPhone is 59.97.
 The maxmium fps on iPad is 60.0.
 */
@interface YYFPSLabel : UILabel

@end
