//
//  PlaceholderCell.m
//  223
//
//  Created by 许毓方 on 2018/9/10.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PlaceholderCell.h"

@interface PlaceholderCell ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) NSProgress *progress;

@end

@implementation PlaceholderCell

+ (NSString *)identifier {
    return @"PlaceholderCellId";
}

- (void)dealloc
{
    [_progress removeObserver:self forKeyPath:@"fractionCompleted"];
    _progress = nil;
}

- (void)setProgress:(NSProgress *)progress
{
    [_progress removeObserver:self forKeyPath:@"fractionCompleted"];
    _progress = progress;
    [self.progressView setProgress:_progress.fractionCompleted animated:NO];
    [_progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)configureWithProgress:(NSProgress *)progress
{
    self.progress = progress;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isEqual:self.progress] && [keyPath isEqualToString:@"c"]) {
        double fractionCompleted = [change[NSKeyValueChangeNewKey] doubleValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:fractionCompleted animated:YES];
        });
    }
}

@end
