//
//  DebugViewController.m
//  233
//
//  Created by 许毓方 on 2018/8/21.
//  Copyright © 2018 SN. All rights reserved.
//

#import "DebugViewController.h"
#import "DebugFunc.h"

@interface DebugViewController ()
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@end

@implementation DebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)debugVCAction:(UIButton *)sender {
    NSArray *arr = [DebugFunc debugViewController];
    NSLog(@"%@", arr);
}

- (IBAction)debugSubView:(UIButton *)sender {
    NSArray *arr = [DebugFunc debugForSubView:self.view1];
    NSLog(@"%@", arr);
}

- (IBAction)debugParentView:(UIButton *)sender {
    NSArray *arr = [DebugFunc debugForParentView:self.view1];
    NSLog(@"%@", arr);
}

@end
