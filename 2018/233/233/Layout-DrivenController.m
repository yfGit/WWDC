//
//  Layout-DrivenController.m
//  233
//
//  Created by 许毓方 on 2018/8/20.
//  Copyright © 2018 SN. All rights reserved.
//

#import "Layout-DrivenController.h"

@interface Layout_DrivenController ()

@property (weak, nonatomic) IBOutlet UIImageView *coolView;
@property (nonatomic, assign) BOOL feelingCool;

@end

@implementation Layout_DrivenController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)coolAction:(UIButton *)sender {
    self.feelingCool = !self.feelingCool; // 0.
    sender.selected = !sender.isSelected;
}

- (void)setFeelingCool:(BOOL)feelingCool
{
    _feelingCool = feelingCool;
    [self.view setNeedsLayout]; // 1.
    
}

// 2.
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.coolView.hidden = !self.feelingCool;
}

@end
