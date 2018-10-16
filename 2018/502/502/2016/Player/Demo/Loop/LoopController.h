//
//  LoopController.h
//  502
//
//  Created by 许毓方 on 2018/10/15.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Looper.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoopController : UIViewController

@property (nonatomic, strong) id<Looper> looper;

@end

NS_ASSUME_NONNULL_END
