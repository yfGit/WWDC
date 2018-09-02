//
//  FeedViewController.m
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import "FeedViewController.h"
#import "MosaicLayout.h"
#import "MosaicCell.h"


@interface FeedViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    MosaicLayout *layout = [MosaicLayout new];
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView = view;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
//    view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    
    [self.view addSubview:view];
    [view registerNib:[UINib nibWithNibName:MosaicCell.description bundle:nil] forCellWithReuseIdentifier:MosaicCell.identifier];
    
    view.delegate = self;
    view.dataSource = self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10000;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MosaicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MosaicCell.identifier forIndexPath:indexPath];
    cell.indexPath = indexPath;
    
    return cell;
}

@end
