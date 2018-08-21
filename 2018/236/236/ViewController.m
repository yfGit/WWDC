//
//  ViewController.m
//  236
//
//  Created by 许毓方 on 2018/8/17.
//  Copyright © 2018 SN. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

// https://developer.apple.com/videos/play/wwdc2018/236/

@interface ViewController ()<AVSpeechSynthesizerDelegate> {
    AVSpeechSynthesizer *_synthesizer;
    AVSpeechUtterance *_utterance;
}
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UITextField *text;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    _synthesizer = [AVSpeechSynthesizer new];
    _synthesizer.delegate = self;
    
    _utterance = [AVSpeechUtterance speechUtteranceWithString:@"iphone Hello, My name is Vincent. Nice to meet you! 大家好, 现在我说的是中文!"];
    _utterance.rate = 0.5;
    // 英文单英语, 中文双语(但语速不一样..台湾..)
    _utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    
}

#pragma mark - Method
/// 所有支持的语言, 每个语言一种声音
- (void)printAllLanguage
{
    for (AVSpeechSynthesisVoice *voice in [AVSpeechSynthesisVoice speechVoices]) {
        NSLog(@"voiceLanguage: %@", voice.language);
    }
}

/* 替换发音或单词
   本机设置 Settings>General>Accessibility>Speech>Pronunciations
   设置了 UIAccessibilitySpeechAttributeIPANotation 才会改变, 不影响其它
 */
- (void)replaceVoice
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"The iphone, The iphone, The iphone, The iphone"];
    [attString addAttribute:UIAccessibilitySpeechAttributeIPANotation value:@"en-US" range:NSMakeRange(3, 6)]; // 有bug吧. 全改了. = =#
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithAttributedString:attString];
    [_synthesizer speakUtterance:utterance];
}

#pragma mark - Action
- (IBAction)startSpeckAction:(UIButton *)sender {
    
    if (sender.isSelected) {
        [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        NSLog(@"2");
    }else {
        [_synthesizer speakUtterance:_utterance];
        NSLog(@"1");
    }
    
    sender.selected = !sender.isSelected;
}

- (IBAction)pauseAction:(UIButton *)sender {
    
    if (sender.isSelected) {
        [_synthesizer continueSpeaking];
        NSLog(@"2");
    }else {
        [_synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];
        NSLog(@"1");
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)changeAction:(UIButton *)sender {
    [self replaceVoice];
}

#pragma mark - Delegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"%s", __func__);
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"%s", __func__);
    self.startBtn.selected = YES;
    _text.text = nil;
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"%s", __func__);
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"%s", __func__);
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"%s", __func__);
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"%s", __func__);
    NSString *text = [utterance.speechString substringWithRange:characterRange];
//    NSLog(@"%@", text);
    _text.text = text;
}


@end
