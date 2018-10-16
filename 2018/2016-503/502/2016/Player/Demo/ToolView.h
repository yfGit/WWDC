//
//  ToolView.h
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/29.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ManualProgressBlock)(CGFloat progress);

@interface ToolView : UIView

@property (nonatomic, strong, readonly) UISlider *slider;

@property (nonatomic, copy) ManualProgressBlock manualProgressBlock;

@property (nonatomic, copy) dispatch_block_t backCallback;
@property (nonatomic, copy) dispatch_block_t forwardCallback;

@end

NS_ASSUME_NONNULL_END
