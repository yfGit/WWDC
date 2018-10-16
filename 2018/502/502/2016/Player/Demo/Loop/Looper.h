//
//  Looper.h
//  502
//
//  Created by 许毓方 on 2018/10/15.
//  Copyright © 2018 SN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Looper <NSObject>

- (id)initWithUrl:(NSURL *)url loopCount:(NSInteger)loopCount;

- (void)startInLayer:(CALayer *)layer;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
