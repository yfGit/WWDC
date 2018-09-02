//
//  ViewController.m
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import "ViewController.h"
#import "FlowLayout.h"
#import "PersonCell.h"
#import "FeedViewController.h"
#import "WaterfallController.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    

}

- (void)setupUI
{
    FlowLayout *layout = [FlowLayout new];
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView = view;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:view];
    [view registerNib:[UINib nibWithNibName:PersonCell.description bundle:nil] forCellWithReuseIdentifier:PersonCell.identifier];
    
    view.delegate = self;
    view.dataSource = self;
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [view addGestureRecognizer:longGesture];
}

- (void)longGesture:(UILongPressGestureRecognizer *)g
{
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint point = [g locationInView:g.view];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
            if (indexPath) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            [self.collectionView updateInteractiveMovementTargetPosition:[g locationInView:g.view]];
        } break;
        case UIGestureRecognizerStateEnded: {
            [self.collectionView endInteractiveMovement];
            //            [self.collectionView reloadData];
        } break;
            
        default:
            break;
    }
}

#pragma mark - Action
/**
 - (void)performBatchUpdates: completion:
 
 批量动画操作
 触发 -prepareLayout
 这个方法可以用来对 collectionView 中的元素进行批量的新增、删除、刷新、插入等操作，同时将触发collectionView 的 layout 的对应动画:
 */
- (IBAction)animAction:(id)sender
{
    [UIView animateWithDuration:2 animations:^{
        
        if (self.dataSource.count < 4) return ;
        
        
        [UIView performWithoutAnimation:^{
            // 1. 确保 performBatchUpdates 之前布局是最新的, 会自动调用 (-prepareLayout)
            [self.collectionView performBatchUpdates:^{
                // 2. 更新数据源. (如对应0,3 更新了数据, 放到第一个)
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:3 inSection:0]]];
            } completion:nil];
        }];
        
        
        [self.collectionView performBatchUpdates:^{
            /*
             1. 将 移动 操作 拆分 成 删除和插入
             2. 将所有的删除操作合并到一起, 同理将所有的插入操作也合并到一起
             3. 先 降序处理删除操作
             4. 再 升序处理插入操作
             5. 先删除或先插入根据实际需求
             */
            // 数据源更新, 注意顺序, 最终数据
            NSString *moveName = self.dataSource[3];
            
            [self.dataSource removeObjectAtIndex:3];
            [self.dataSource removeObjectAtIndex:2];
            [self.dataSource insertObject:moveName atIndex:0];

            // UICollectionView Item 更新
            // 只关注动画效果, 不关心顺序(顺序不一样, 效果还是一样的, see collectionView_anim@2x.png(内部规范了顺序))
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:0]]];
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0] toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

        } completion:^(BOOL finished) {
            NSLog(@"%@", finished ? @"成功" : @"中断");
        }];
    }];
}

- (IBAction)reloadAction:(id)sender
{
    self.dataSource = nil;
    [self.collectionView reloadData];
}


#pragma mark - Delegate DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PersonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PersonCell.identifier forIndexPath:indexPath];
    
    [cell configData:self.dataSource[indexPath.row]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = self.dataSource[indexPath.row];
    BOOL isWaterfall = [name isEqualToString:@"瀑布流"];
    UIViewController *vc = isWaterfall ? [WaterfallController new] : [FeedViewController new];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (![sourceIndexPath isEqual:destinationIndexPath]) {
        NSLog(@"from:%@      to:%@", sourceIndexPath, destinationIndexPath);
        
        NSString *item = self.dataSource[sourceIndexPath.item];
        [self.dataSource removeObjectAtIndex:sourceIndexPath.item];
        [self.dataSource insertObject:item atIndex:destinationIndexPath.item];
    }
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@"John", @"Tom", @"Rose", @"Michael", @"Vito", @"Sonny", @"瀑布流"].mutableCopy;
    }
    return _dataSource;
}

@end
