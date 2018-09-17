//
//  ViewController.m
//  203-Destination
//
//  Created by 许毓方 on 2018/9/5.
//  Copyright © 2018 SN. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UIDropInteractionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addInteraction:[[UIDropInteraction alloc] initWithDelegate:self]];
}



#pragma mark - Drop

/**
 调用时机  see Timeline.png - Move
 - session 进入drop交互视图的区域
 - session 在drop交互视图内移动
 - 用户将 drag item 添加到 drop交互视图 区域内的 session 中
 
 不实现此方法将不接受任何 drop 活动, 如果程序只需要 drag 可以不实现
 
 调用顺序 - dropInteraction: canHandleSession:
        - dropInteraction: sessionDidEnter:
        - dropInteraction: sessionDidUpdate:
 
 @return 放置建议
 
 operation: cancel, copy, move, forbidden
 move: 同一应用程序, drag代理要allow moves, drop 代理检查 allowsMoveOperation
 forbidden: 同cancel, 多了一个标志
 
 只有在 session 的 allowsMoveOperation为YES(drag 代理设置) 时，才可以返回包含 UIDropOperationMove 操作的建议。
 */
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session
{
    UIDropOperation operation;
    if (session.localDragSession) {
        operation = UIDropOperationMove; // 重新排序
    }else { // drap 在其它 app, 为nil
        operation = UIDropOperationCopy;
    }
    return [[UIDropProposal alloc] initWithDropOperation:operation];
}



/**
 之前的 建议Proposal了一项操作  move, copy 会调用, 也是最终唯一加载数据的地方
 see Timeline.png - End

 顺序与将拖拽项添加到拖拽会话的顺序相同, 松开手指时调用
 
 NSProgress: 数据传输进度, 可以cancel传输
 
 session.localDragSession 区分move copy
 */
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session
{
//    NSLog(@"%@", [NSThread currentThread]);
    
    //    if (session.localDragSession == nil) { 不用数据传输了 return;}
    
//    // mainQueue 为 session 中的每个 拖动项items 创建并加载指定类的新实例。
//    [session loadObjectsOfClass:[UIImage class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
//
//        for (UIImage *image in objects) {
//            UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
//            imgView.frame = (CGRect) {{0, 0}, CGSizeMake(100, 70)};
//            imgView.center = [session locationInView:interaction.view];
//            [self.view addSubview:imgView];
//        }
//    }];
//    
    // background queue 异步
    for (UIDragItem *item in session.items) {
        NSProgress *progresss = [item.itemProvider loadObjectOfClass:[UIImage class]
                                                   completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
            
            if (object != nil) {
                // 主队列
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImageView *imgView = [[UIImageView alloc] initWithImage:(UIImage *)object];
                    imgView.frame = (CGRect) {{0, 0}, CGSizeMake(100, 70)};
                    imgView.center = [session locationInView:interaction.view];
                    [self.view addSubview:imgView];
                });
            }
        }];
    }
}

#pragma mark - life

/**
 是否可以处理 session 的 dragItem, 进入到可以drop区域时就调用(同时drag, drop时, timeline move阶段就会调用)

 YES不意味着将接受 drop, 代表感兴趣, 能够处理
 
 你不能检查拖拽中item的实际数据(没公开), 只能检查他们的类型
 */
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session
{
//    NSLog(@"%s", __func__);
    // session itmes 任何一个符合就YES
    BOOL result = [session canLoadObjectsOfClass:UIImage.class];
    
    // 更具体, 对 PNG 感兴趣, session itmes 任何一个符合就YES, 但是session和dash上说的都是 only. UTCoreTypes.h
//    result = [session hasItemsConformingToTypeIdentifiers:@[(NSString *)kUTTypePNG]];
    return result;
}

- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnter:(id<UIDropSession>)session
{
    NSLog(@"%s", __func__);
}

/// 离开可drop区域时调用
- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidExit:(id<UIDropSession>)session
{
    NSLog(@"%s", __func__);
}

// drop交互结束, 处理或不处理都调用
- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnd:(id<UIDropSession>)session
{
    NSLog(@"%s", __func__);
}

#pragma mark - Anim
/*
 // item.localObject 区分move copy
- (UITargetedDragPreview *)dropInteraction:(UIDropInteraction *)interaction previewForDroppingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview
{
 
}

- (void)dropInteraction:(UIDropInteraction *)interaction item:(UIDragItem *)item willAnimateDropWithAnimator:(id<UIDragAnimating>)animator
{
    
}

/// 相关动画完成
- (void)dropInteraction:(UIDropInteraction *)interaction concludeDrop:(id<UIDropSession>)session
{
    
}
 */
@end
