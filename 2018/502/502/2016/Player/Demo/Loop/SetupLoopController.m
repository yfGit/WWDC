//
//  LoopController.m
//  502
//
//  Created by 许毓方 on 2018/10/15.
//  Copyright © 2018 SN. All rights reserved.
//

#import "SetupLoopController.h"
#import "LoopController.h"
#import "QueueLooper.h"
#import "PlayerLooper.h"
#import "NormalLooper.h"

@interface SetupLoopController ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *filePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *countPickerView;

@property (nonatomic, copy) NSArray *mediaFileArr;
@property (nonatomic, copy) NSArray *mediaUrlArr;
@property (nonatomic, copy) NSArray *loopCountStringArr;
@property (nonatomic, copy) NSArray *loopCountValueArr;

@property (nonatomic, assign) NSInteger fileSelectedIndex;
@property (nonatomic, assign) NSInteger loopSelectedIndex;

@end

@implementation SetupLoopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup
{
    self.mediaFileArr = @[@"Sweep", @"BipBop"];
    self.mediaUrlArr  = @[[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"maskOff" ofType:@"mov"]],
                          [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ChoppedBipBop" ofType:@"m4v"]]];
    self.loopCountStringArr = @[@"Infinite", @"2", @"5"];
    self.loopCountValueArr  = @[@(-1), @2, @5];
    
    self.filePickerView.delegate    = self;
    self.filePickerView.dataSource  = self;
    self.countPickerView.delegate   = self;
    self.countPickerView.dataSource = self;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LoopController *vc = segue.destinationViewController;
    vc.title = segue.identifier;
    
    NSURL *url = self.mediaUrlArr[self.fileSelectedIndex];
    NSInteger count = [self.loopCountValueArr[self.loopSelectedIndex] integerValue];
    
    id<Looper> looper = [[NSClassFromString(segue.identifier) alloc] initWithUrl:url loopCount:count];
    vc.looper = looper;
}


#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.filePickerView) {
        return self.mediaFileArr.count;
    }else {
        return self.loopCountStringArr.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.filePickerView) {
        return self.mediaFileArr[row];
    }else {
        return self.loopCountStringArr[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.filePickerView) {
        self.fileSelectedIndex = row;
    }else {
        self.loopSelectedIndex = row;
    }
}

@end
