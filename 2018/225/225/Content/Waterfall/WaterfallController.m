//
//  WaterfallController.m
//  225
//
//  Created by 许毓方 on 2018/8/27.
//  Copyright © 2018 SN. All rights reserved.
//

#import "WaterfallController.h"
#import "WaterfallCell.h"
#import "XXXWaterfallLayout.h"
#import "WaterfallHeaderView.h"
#import "WaterfallFooterView.h"

@interface WaterfallController ()<UICollectionViewDelegate, UICollectionViewDataSource, XXXWaterfallLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@end

@implementation WaterfallController

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self orientationChanged:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"瀑布流";
    
    XXXWaterfallLayout *layout = [XXXWaterfallLayout new];
//    layout.sectionExchangeForbidden = YES;
    
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    self.collectionView = view;
//    view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    
    view.delegate = self;
    view.dataSource = self;
    
    [view registerNib:[UINib nibWithNibName:WaterfallCell.description bundle:nil] forCellWithReuseIdentifier:WaterfallCell.identifier];
    [view registerNib:[UINib nibWithNibName:WaterfallHeaderView.description bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:WaterfallHeaderView.identifier];
    [view registerNib:[UINib nibWithNibName:WaterfallFooterView.description bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:WaterfallFooterView.identifier];
    
    
    // navi
    UIButton *edit = [UIButton buttonWithType:UIButtonTypeCustom];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = item;
    
    edit.frame = CGRectMake(0, 0, 110, 36);
    edit.titleLabel.font = [UIFont systemFontOfSize:15];
    edit.backgroundColor = [UIColor orangeColor];
    edit.layer.cornerRadius = 18;

    [edit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [edit setTitle:@"长按移动交换" forState:UIControlStateSelected];
    [edit setTitle:@"长按编辑" forState:UIControlStateNormal];
    [edit addTarget:self action:@selector(rightBarButtonItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    
    [self rightBarButtonItemAction:edit];
}

#pragma mark - Action

- (void)rightBarButtonItemAction:(UIButton *)btn
{
    if (btn.isSelected) {
        [self.collectionView removeGestureRecognizer:self.longGesture];
        self.editMode = YES;
    }else {
        [self.collectionView addGestureRecognizer:self.longGesture];
        self.editMode = NO;
    }
    btn.selected = !btn.isSelected;
}

#pragma mark 设备旋转 横屏个数
- (void)orientationChanged:(NSNotification *)n
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark 手势
- (void)longGesture:(UILongPressGestureRecognizer *)g
{
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[g locationInView:g.view]];
            if (indexPath) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            [self.collectionView updateInteractiveMovementTargetPosition:[g locationInView:g.view]];
        } break;
        case UIGestureRecognizerStateEnded: {
            [self.collectionView endInteractiveMovement];
        } break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

#pragma mark - CollectionView Delegate DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSLog(@"numberOfItems %ld - %lu", section, [self.dataSource[section] count]);
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    WaterfallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WaterfallCell.identifier forIndexPath:indexPath];
    [cell configData:self.dataSource[indexPath.section][indexPath.item] indexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:WaterfallHeaderView.identifier forIndexPath:indexPath];
    }else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:WaterfallFooterView.identifier forIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath);
}

#pragma mark Move

/*
 必须实现, 自定义时layout时空实现, 否则无效果
 
 自定义layout: 不实现上方法 invalidationContextForInteractivelyMovingItems 不会调用
              写上代码会有显示问题
    自定义时空方法实现
 
 可能:
    if respondsToSelector: 此方法 {
        走 layout override   invalidationContextForInteractivelyMovingItems
        再调用此方法实现 (但是自定义时可能数据交换逻辑顺序不一样)
    }
 */
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(9_0)
{
//    if (![sourceIndexPath isEqual:destinationIndexPath]) {
//        NSString *item = self.dataSource[sourceIndexPath.section][sourceIndexPath.item];
//        [self.dataSource[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
//        [self.dataSource[destinationIndexPath.section] insertObject:item atIndex:destinationIndexPath.item];
//
//        NSLog(@"from: {%lu - %lu}      to: {%lu - %lu}", sourceIndexPath.section, sourceIndexPath.item, destinationIndexPath.section, destinationIndexPath.item);
//    }
}

#pragma mark - Layout Delegate
//- (NSUInteger)waterfallLayout:(XXXWaterfallLayout *)layout numberOfItemsInSection:(NSUInteger)section
//{
//    return [self.dataSource[section] count];
//}

- (CGSize)waterfallLayout:(XXXWaterfallLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 不要随机......
    // 用图片自身的宽高比
    NSString *imageName = self.dataSource[indexPath.section][indexPath.item];
    UIImage *image = [UIImage imageNamed:imageName];
    
    return [image size];
}

- (UIEdgeInsets)waterfallLayout:(XXXWaterfallLayout *)layout insetForSection:(NSUInteger)section
{
    if (section == 0) {
        return UIEdgeInsetsMake(15, 15, 15, 15);
    }else {
        return UIEdgeInsetsMake(5, 5, 5, 5);
    }
}

- (NSInteger)waterfallLayout:(XXXWaterfallLayout *)layout columnCountForSection:(NSUInteger)section
{
    // FaceUp FaceDown 存在的原因, 还是上个界面传过来第一次显示的方向准一点
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    BOOL isProtrait = UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown;
    
    return section == 0 ? isProtrait ? 3 : 4 : isProtrait ? 4 : 5;
}

- (CGFloat)waterfallLayout:(XXXWaterfallLayout *)layout heightForHeaderInSection:(NSUInteger)section
{
    return section == 0 ? 100 : 50;
}

- (CGFloat)waterfallLayout:(XXXWaterfallLayout *)layout heightForFooterInSection:(NSUInteger)section
{
    return 70;
}

#pragma mark Animation

- (void)waterfallLayout:(XXXWaterfallLayout *)layout animationType:(XXXLayoutAntimationType)animationType forAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    switch (animationType) {
        case XXXLayoutAntimationTypeMove: {
            
            attributes.transform3D = CATransform3DScale(attributes.transform3D, 0.8, 0.7, 0.7);
            attributes.alpha = .7;
        } break;
        case XXXLayoutAntimationTypeDelete: {
            
            attributes.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.3, 0.3), 3*M_PI);
            attributes.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
            attributes.alpha = 0.5;
        } break;
        case XXXLayoutAntimationTypeInsert: {
            
            attributes.transform = CGAffineTransformRotate(attributes.transform, M_PI);
            attributes.alpha = 0.5;
        } break;
        default:
            break;
    }
}

#pragma mark Move

- (void)waterfallLayout:(XXXWaterfallLayout *)layout moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (![sourceIndexPath isEqual:destinationIndexPath]) {

        NSString *item = self.dataSource[sourceIndexPath.section][sourceIndexPath.item];
        
        [self.dataSource[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
        [self.dataSource[destinationIndexPath.section] insertObject:item atIndex:destinationIndexPath.item];
        
        NSLog(@"from: {%lu - %lu}      to: {%lu - %lu}", sourceIndexPath.section, sourceIndexPath.item, destinationIndexPath.section, destinationIndexPath.item);
    }
}

/**
 * 结束后刷新数据, 如 demo 上的 cell label,
 * 不过 IndexPath 还是正常的, 只是没有调 - collectionView: cellForItemAtIndexPath:
 */
- (void)moveEndWaterfallLayout:(XXXWaterfallLayout *)layout
{
    // 拖动时停顿一秒左右, 还是会闪.
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
    }];
}

#pragma mark pasteboard

// 以下三个方法实现 Menu 功能时, 都需要实现
/// 是否显示 Menu
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editMode;
}

/// 哪些 (UIResponderStandardEditActions)item 允许显示,  默认只能实现  cut, copy, paste, 可自定义 UIMenuItem
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return YES;
    
    NSString *actionName = NSStringFromSelector(action);
    return [@[@"cut:", @"copy:", @"paste:"] containsObject:actionName];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    static NSString *PasteboardName = @"board";
    
    NSString *actionName = NSStringFromSelector(action);
    NSLog(@"点击了事件: %@", actionName);
    
    if ([actionName isEqualToString:@"cut:"]) {
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:PasteboardName create:YES];
        NSString *item = self.dataSource[indexPath.section][indexPath.item];
        [pasteboard setString:item];
        
        [self.dataSource[indexPath.section] removeObjectAtIndex:indexPath.item];
        [self.collectionView performBatchUpdates:^{
            // - finalLayoutAttributesForDisappearingItemAtIndexPath:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            
        } completion:^(BOOL finished) {
            
            NSArray *reloadIndexPaths = [self _reloadIndexPathsFromOperationalIndexPath:indexPath];
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadItemsAtIndexPaths:reloadIndexPaths];
            }];
        }];
        
    }else if ([actionName isEqualToString:@"copy:"]) {
        
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:PasteboardName create:YES];
        NSString *item = self.dataSource[indexPath.section][indexPath.item];
        [pasteboard setString:item];
        
    }else if ([actionName isEqualToString:@"paste:"]) { // copy or cut first, insert indexPath
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:PasteboardName create:NO];
        NSString *item = [pasteboard string];
        if (![item containsString:@"waterfall_"]) return;
        
        [self.collectionView performBatchUpdates:^{

            [self.dataSource[indexPath.section] insertObject:item atIndex:indexPath.item];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
            
        } completion:^(BOOL finished) {
            
            NSArray *reloadIndexPaths = [self _reloadIndexPathsFromOperationalIndexPath:indexPath];
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadItemsAtIndexPaths:reloadIndexPaths];
            }];
        }];
    }
}

- (NSArray<NSIndexPath *> *)_reloadIndexPathsFromOperationalIndexPath:(NSIndexPath *)indexPath
{
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    
    NSMutableArray *reloadIndexPaths = [NSMutableArray array];
    [visibleIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *index, NSUInteger idx, BOOL * _Nonnull stop) {
        if (index.section == indexPath.section && index.item >= indexPath.item) {
            [reloadIndexPaths addObject:index];
        }
    }];
    
    return reloadIndexPaths;
}

#pragma mark - Getter
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
        for (NSUInteger i = 0; i < 10; i++) {
            NSMutableArray *sections = [NSMutableArray array];
            for (NSUInteger j = 0; j < 18; j++) {
                NSString *imageName = [NSString stringWithFormat:@"waterfall_%lu",(j%18)];
                [sections addObject:imageName];
            }
            [_dataSource addObject:sections];
        }
    }
    return _dataSource;
}


@end
