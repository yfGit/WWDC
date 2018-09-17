//
//  ViewController.m
//  203-Source
//
//  Created by 许毓方 on 2018/9/5.
//  Copyright © 2018 SN. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIDragInteractionDelegate>

@property (nonatomic, strong) NSMutableArray *dragImages;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *dragViews;

@property (nonatomic, strong) NSMutableArray *views;

/// 追踪, 当前只对于 drag view
@property (nonatomic, assign) CGPoint dragPoint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addInteraction:[[UIDragInteraction alloc] initWithDelegate:self]];
    
    self.views = [NSMutableArray array];
    self.dragImages = [NSMutableArray array];
    [self.dragImages addObject:[UIImage imageNamed:@"0"]];
    [self.dragImages addObject:[UIImage imageNamed:@"Timeline"]];
}


#pragma mark - Drag

 /* 一般实现
    itemsForBeginningSession:
    previewForLiftingItem:
    itemsForAddingToSession: withTouchAtPoint:
  
    三个方法就可以了
 */

/**

 需要被拖拽的 UIDragItem 数组, 将被系统填充到 session 的 items
 see Timeline.png - begin
 
 @return nil 可被拖动目标
 */
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session
{
    CGPoint point = [session locationInView:interaction.view];
    self.dragPoint = point;
    NSUInteger index = [self _indexOfDragViewsAtPoint:point];
    if (index != NSNotFound) {
        UIImage *img = self.dragImages[index];
        NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:img]; // 用于传输
        UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
        
        // tips: 附加信息, 仅对 drag 的 app 有用 (如 Destation获取为nil, 也存不了)
        item.localObject = @(index);
        return @[item];
    }else {
        return nil;
    }
}

/**
 预览视图: 默认为整个视图的快照 (哪怕你是拖拽了其中一个view, 也会显示全部)  或  使用 dragItem.previewProvider
 
 提供:
    1. 拖拽预览部分
    2. 目标部分: 独立, 不存在于 View Hierarchy, 你需要告诉她在哪
 
 tips: 多个预览图呢, target 和 imageView 显示效果是反的? ??
 */
- (UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session
{
    NSUInteger idx = [item.localObject intValue];
    
    // 最简单的
//    return [[UITargetedDragPreview alloc] initWithView:self.dragViews[idx]];
    
    
    
    CGPoint point = [session locationInView:interaction.view];
    
    // 预览
    UIImage *image = self.dragImages[idx];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.frame = (CGRect) {{0, 0}, {100, 70}}; // 按需缩放
    imgView.center = point;
    
    // targeted
    UIDragPreviewTarget *target = [[UIDragPreviewTarget alloc] initWithContainer:interaction.view
                                                                          center:point
                                                                       transform:CGAffineTransformIdentity];

    /*
     initWithView: view 默认为 interaction.view, 显示屏幕快照
     自定义 view 必须是已经显示在窗口上的
     */
    UIDragPreviewParameters *param = [[UIDragPreviewParameters alloc] init];
//    param.visiblePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 50, 50)];  // collectionView 默认是以cell为view
    UITargetedDragPreview *preview = [[UITargetedDragPreview alloc] initWithView:self.dragViews[idx] parameters:param target:target];
    
    return preview;
    
}

/// Lift 过程中的动画
- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session
{
    [animator addAnimations:^{
        self.view.backgroundColor = [UIColor grayColor];
    }];

    // 如果不写要在 end cancel 中恢复, 看需求
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self.view.backgroundColor = [UIColor whiteColor];
        switch (finalPosition) {
            case UIViewAnimatingPositionStart: // 原地放手是 start, 因为这是 Position
                NSLog(@"Start");
                break;
            case UIViewAnimatingPositionCurrent: // 没试过来. 可能是多个dragItem
                NSLog(@"Current");
                break;
            case UIViewAnimatingPositionEnd: // move
                NSLog(@"End");
                break;

            default:
                break;
        }
    }];
}


/**
 是否允许 move UIDropProposal, 只能在当前app中使用, 到其他app 都是copy
 默认yes
 yes: -dragInteraction:session:willEndWithOperation: and -dragInteraction:session:didEndWithOperation:
 */
- (BOOL)dragInteraction:(UIDragInteraction *)interaction sessionAllowsMoveOperation:(id<UIDragSession>)session {
    return YES;
}

// dragItem move, get new location
- (void)dragInteraction:(UIDragInteraction *)interaction sessionDidMove:(id<UIDragSession>)session
{
    self.dragPoint = [session locationInView:interaction.view];
//    NSLog(@"%@", NSStringFromCGPoint([session locationInView:interaction.view]));
}

#pragma mark add
/// 同 itemsForBeginningSession 之后还会掉 previewForLiftingItem
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForAddingToSession:(id<UIDragSession>)session withTouchAtPoint:(CGPoint)point
{
    NSUInteger index = [self _indexOfDragViewsAtPoint:point];
    if (index != NSNotFound) {
        UIImage *img = self.dragImages[index];
        NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:img]; // 用于传输
        UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
        item.localObject = YES; // tips: makes it faster to drag and drop content within the same app 
        // tips: 附加信息, 仅对 drag 的 app 有用 (如 Destation获取为nil)
        item.localObject = @(index);
        
        return @[item];
    }else {
        return nil;
    }
}

/*
 YES: 限制drop到其它app, 会成 cancel
 NO:  不限制, default
 */
- (BOOL)dragInteraction:(UIDragInteraction *)interaction sessionIsRestrictedToDraggingApplication:(id<UIDragSession>)session
{
    return NO;
}
#pragma mark end
/**

 @param operation   cancel, forbidden时, 请在取消动画开始之前更新视图，使其具有相应的外观。 tips:
 */
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session willEndWithOperation:(UIDropOperation)operation
{
    NSLog(@"willEnd - %lu", operation);
}

/**
 相关动画完成后
 由于会话已经结束，您的应用程序应该恢复到正常的外观。

 @param operation   move, copy时, 开始数据传输
 */
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation
{
    NSLog(@"didEnd");
}

#pragma mark cancel


/**
 cancel 动画

 * You may return:
 * - defaultPreview, to use it as-is, which would move the current preview back to where it came from.
 * - nil, to fade the drag item in place ; = defalut
 * - [defaultPreview retargetedPreviewWithTarget:] to move the preview to a different target
 * - a UITargetedDragPreview that you create however you like
 */
- (UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForCancellingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview
{
    return nil;
}

- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator
{
    NSLog(@"Cancel");
}

#pragma mark 数据传输完成

/**
 目标已经接收到数据
 如果需要清理与 drag items 或 其 item provider objects 相关的 resources，则实现此方法。
 */
- (void)dragInteraction:(UIDragInteraction *)interaction sessionDidTransferItems:(id<UIDragSession>)session
{
    NSLog(@"transfer completion");
}

#pragma mark - Private Method

- (NSUInteger)_indexOfDragViewsAtPoint:(CGPoint)point
{
    UIView *hitTestView = [self.view hitTest:point withEvent:nil];
    NSUInteger index = [self.dragViews indexOfObject:hitTestView];
    return index;
}



@end

