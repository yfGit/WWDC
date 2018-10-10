//
//  ToolView.m
//  Test_Demo
//
//  Created by 许毓方 on 2018/9/29.
//  Copyright © 2018 SN. All rights reserved.
//

#import "ToolView.h"

@interface ToolView ()

@property (nonatomic, strong, readwrite) UISlider *slider;

@end

@implementation ToolView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        
        
        __weak typeof(self) _self = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                
                // slider
                self.slider = [[UISlider alloc] init];
                CGFloat width = self.bounds.size.width / 2.0;
                self.slider.frame = CGRectMake((self.bounds.size.width - width)/2.0, 0, width, self.bounds.size.height);
                self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside ];
                [self addSubview:self.slider];
                
                // playback
                UIImage *back = [UIImage imageNamed:@"playback_forward"];
                UIImage *forward = [UIImage imageNamed:@"playback_back"];
                
                UIButton *backView = [UIButton buttonWithType:UIButtonTypeCustom];
                [backView setImage:back forState:UIControlStateNormal];
                
                UIButton *forwardView = [UIButton buttonWithType:UIButtonTypeCustom];
                [forwardView setImage:forward forState:UIControlStateNormal];
                
                backView.frame = CGRectMake(0, 0, 44, 44);
                forwardView.frame = CGRectMake(0, 0, 44, 44);
                backView.center = CGPointMake(40, self.bounds.size.height/2.0);
                forwardView.center = CGPointMake(self.bounds.size.width-40, self.bounds.size.height/2.0);
                backView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                forwardView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
                
                [backView addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
                [forwardView addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
                
                
                [self addSubview:backView];
                [self addSubview:forwardView];
                
            });
        });
        
        
    }
    return self;
}

- (void)sliderAction:(UISlider *)s
{
    if (self.manualProgressBlock) {
        self.manualProgressBlock(s.value);
    }
}

- (void)backAction:(UIButton *)btn
{
    if (self.backCallback) {
        self.backCallback();
    }
}

- (void)forwardAction:(UIButton *)btn
{
    if (self.forwardCallback) {
        self.forwardCallback();
    }
}

@end
