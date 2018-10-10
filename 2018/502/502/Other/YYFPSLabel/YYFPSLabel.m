//
//  YYFPSLabel.m
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYFPSLabel.h"
#import "YYWeakProxy.h"
#import <objc/runtime.h>

#define kSize CGSizeMake(55, 20)

@interface UIEvent (XXXGesture)

@property (nonatomic, assign) BOOL notRecognize;

@end

@implementation UIEvent (XXXGesture)

- (void)setNotRecognize:(BOOL)notRecognize {
    objc_setAssociatedObject(self, @selector(notRecognize), @(notRecognize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)notRecognize {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

@implementation YYFPSLabel {
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    UIFont *_font;
    UIFont *_subFont;
    
    NSTimeInterval _llll;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size = kSize;
    }
    self = [super initWithFrame:frame];
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.textAlignment = NSTextAlignmentCenter;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
    
    _font = [UIFont fontWithName:@"Menlo" size:14];
    if (_font) {
        _subFont = [UIFont fontWithName:@"Menlo" size:4];
    } else {
        _font = [UIFont fontWithName:@"Courier" size:14];
        _subFont = [UIFont fontWithName:@"Courier" size:4];
    }
    
    // 如果直接用 self 或者 weakSelf，都不能解决循环引用问题
    
    // 将 timer 的 target 从 self ，变成了中间人 NSProxy
    // timer 调用 target 的 selector 时，会被 NSProxy 内部转调用 self 的 selector
    _link = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
//    __weak typeof(self) weakSelf = self;
//    _link = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(tick:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:gesture];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//    [self addGestureRecognizer:tap];
    
    return self;
}

static UIEvent *_lastEvent;

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    _lastEvent = event;
//    NSLog(@"%d", event.notRecognize);
//    if (event.notRecognize) {
//        event.notRecognize = NO;
//        return nil;
//    }
//    return [super hitTest:point withEvent:event];
//}

- (void)tapAction:(UIPanGestureRecognizer *)g
{
    NSLog(@"tap");
    
    CGPoint point = [g locationInView:self];
    _lastEvent.notRecognize = YES;
    
    [self _hitTest:point withEvent:_lastEvent];
}

- (void)_hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window hitTest:point withEvent:_lastEvent]; // 调 hitTest:event: 但是没用
    return;
    
    SEL sel = NSSelectorFromString(@"_hitTest:withEvent:windowServerHitTestWindow:"); // 没调 hitTest:event:
    NSMethodSignature *signature = [[UIView class] instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:NSClassFromString(@"UIView(Geometry)")];
    [invocation setSelector:sel];
    
    // 0: target   1: _cmd
    [invocation setArgument:&point atIndex:2];
    [invocation setArgument:&event atIndex:3];
    [invocation setArgument:&window atIndex:4];
    [invocation retainArguments];
    
    [invocation invoke];
}

- (void)panAction:(UIPanGestureRecognizer *)g
{
//    NSLog(@"pan");
    UIView *superView = g.view.superview;
    if (!superView) return;
    
    CGPoint point = [g locationInView:superView];
    
    switch (g.state) {
        case UIGestureRecognizerStateEnded:
            point = [self _boundaryMeasure:point];
            break;
        case UIGestureRecognizerStateCancelled:
            point = [self _boundaryMeasure:point];
            break;
            
        default:
            break;
    }
    
    self.center = point;
}

// 边界计算
- (CGPoint)_boundaryMeasure:(CGPoint)point
{
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 5, 5, 5);
    CGRect frame = CGRectMake(point.x-width/2.0, point.y-height/2.0, width, height);
    
    point.x = CGRectGetMinX(frame) < padding.left ? width/2.0 + padding.left : point.x;
    point.x = CGRectGetMaxX(frame) > screenWidth - padding.right ? screenWidth - width/2.0 - padding.right : point.x;
    
    point.y = CGRectGetMinY(frame) < padding.top ? height/2.0 + padding.top : point.y;
    point.y = CGRectGetMaxY(frame) > screenHeight - padding.bottom ? screenHeight - height/2.0 - padding.bottom : point.y;
    
    return point;
}

- (void)dealloc {
    [_link invalidate];
    NSLog(@"timer release");
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
//    NSString *text1 = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];
//    NSLog(@"%@", text1);

    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:_subFont range:NSMakeRange(text.length - 4, 1)];
    self.attributedText = text;
}

@end
