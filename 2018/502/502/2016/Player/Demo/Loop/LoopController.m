//
//  LoopController.m
//  502
//
//  Created by 许毓方 on 2018/10/15.
//  Copyright © 2018 SN. All rights reserved.
//

#import "LoopController.h"

@interface LoopController ()

@end

@implementation LoopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.looper startInLayer:self.view.layer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.looper stop];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
