//
//  PhotoCollectionController.m
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PhotoCollectionController.h"
#import "PhotoCell.h"
#import "PlaceholderCell.h"
#import "AlbumTableController.h"
#import "PhotoLibrary.h"
#import "PhotoAlbum.h"



@interface PhotoCollectionController ()<UICollectionViewDragDelegate, UICollectionViewDropDelegate>

@property (nonatomic, strong) PhotoAlbum *album;

@property (nonatomic, weak) AlbumTableController *albumController;

@end

@implementation PhotoCollectionController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dragDelegate = self;
    self.collectionView.dropDelegate = self;
    self.collectionView.springLoaded = YES;
    self.collectionView.dragInteractionEnabled = YES;
    // iOS 11, collectionView 独有, 重新排序速度
    self.collectionView.reorderingCadence = UICollectionViewReorderingCadenceFast;
}

- (void)loadAlbum:(PhotoAlbum *)album fromAlbumController:(AlbumTableController *)albumController
{
    self.album = album;
    self.title = album.title;
    self.albumController = albumController;
    
    [self.collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.album.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCell.identifier forIndexPath:indexPath];
    
    [cell configureWithPhoto:self.album.photos[indexPath.item]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
#pragma mark - Drag

- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath
{
    return [self _dragItemsForIndexPath:indexPath];
}

- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point
{
    return [self _dragItemsForIndexPath:indexPath];
}

/// drag 预览图 外观, 默认 cell 可见 bounds; 作一些裁剪, 背景之类的
- (UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIDragPreviewParameters *previewParameters = [[UIDragPreviewParameters alloc] init];
    previewParameters.visiblePath = [UIBezierPath bezierPathWithRect:[cell clippingRectForPhoto]];
    
    return previewParameters;
}

#pragma mark - Drop

- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (session.localDragSession) {
        UICollectionViewDropProposal *proposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
        proposal.prefersFullSizePreview = YES;
        return proposal;
    }else {
        UICollectionViewDropProposal *proposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
        proposal.prefersFullSizePreview = YES;
        return proposal;
    }
}

- (void)collectionView:(nonnull UICollectionView *)collectionView performDropWithCoordinator:(nonnull id<UICollectionViewDropCoordinator>)coordinator
{
    if (coordinator.proposal.operation == UIDropOperationMove) {
        
        for (id<UICollectionViewDropItem> item in coordinator.items) {
            
            NSIndexPath *sourceIndexPath = item.sourceIndexPath;
            Photo *photo = item.dragItem.localObject;
            
            if ([self.album containsPhoto:photo]) { // 同一个 album
                [self _reorderingItem:item fromSourceIndexPath:sourceIndexPath coordinator:coordinator];
                
            }else { // 不同 album
                [self _reorderingAnotherItem:item fromSourceIndexPath:sourceIndexPath coordinator:coordinator];
            }
        }
    }else if (coordinator.proposal.operation == UIDropOperationCopy) {
        // 其它 app, 如果需要异步, 加个Placeholder
        
        for (id<UICollectionViewDropItem> item in coordinator.items) {
            
            UIDragItem *dragItem = item.dragItem;
            
            if (![dragItem.itemProvider canLoadObjectOfClass:[UIImage class]]) return;
            
            // 包含了PlaceholderCell的信息, 不应该自己创建, 通过 coordinator 创建
            id<UICollectionViewDropPlaceholderContext> placeholderContext;
            
            NSInteger count = self.album.photos.count;
            NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath ?: [NSIndexPath indexPathForItem:(count-1) >= 0 ? count : 0 inSection:0];
            
            UICollectionViewDropPlaceholder *placeholder = [[UICollectionViewDropPlaceholder alloc] initWithInsertionIndexPath:destinationIndexPath reuseIdentifier:PlaceholderCell.identifier];
            
            placeholderContext = [coordinator dropItem:dragItem toPlaceholder:placeholder];
            
            NSProgress *progress = [dragItem.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = (UIImage *)object;
                    if (image) {
                        // 数据传输完成, 将PlaceholderCell替换会最终的内容cell, 更新数据源
                        // 不要reloadData 会删除所有PlaceholderCell
                        [placeholderContext commitInsertionWithDataSourceUpdates:^(NSIndexPath * _Nonnull insertionIndexPath) {
                            NSUInteger index = insertionIndexPath.item;
                            [[PhotoLibrary sharedInstance] insertPhoto:[[Photo alloc] initWithImage:image] toAlbum:self.album atIndex:index];
                            [self _updateMaster:nil];
                        }];
                    }else {
                        [placeholderContext deletePlaceholder]; // 没见调用过
                        NSLog(@"====>>> placeholderContext deleted");
                    }
                });
            }];
            
            [placeholder setCellUpdateHandler:^(__kindof UICollectionViewCell * _Nonnull cell) {
                PlaceholderCell *placeholderCell = (PlaceholderCell *)cell;
                [placeholderCell configureWithProgress:progress];
            }];
        }
    }
}

- (UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dropPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIDragPreviewParameters *previewParameters = [[UIDragPreviewParameters alloc] init];
    previewParameters.visiblePath = [UIBezierPath bezierPathWithRect:[cell clippingRectForPhoto]];
    
    return previewParameters;
}

#pragma mark - Private Method

- (NSArray *)_dragItemsForIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = self.album.photos[indexPath.row];
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:photo.image];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvider];
//    dragItem.previewProvider = photo.dragPreview;
    dragItem.localObject = photo;
    
    return @[dragItem];
}

/// 重新排序, 同 album
- (void)_reorderingItem:(id<UICollectionViewDropItem>)item fromSourceIndexPath:(NSIndexPath *)sourceIndexPath coordinator:(id<UICollectionViewDropCoordinator>)coordinator
{
    [self.collectionView performBatchUpdates:^{
        Photo *photo = [self.album.photos objectAtIndex:sourceIndexPath.item];
        [self.album.photos removeObjectAtIndex:sourceIndexPath.item];
        [self.album.photos insertObject:photo atIndex:coordinator.destinationIndexPath.item];
        
        [self.collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:coordinator.destinationIndexPath];
    } completion:nil];
    
    [coordinator dropItem:item.dragItem toItemAtIndexPath:coordinator.destinationIndexPath];
    
    [self _updateMaster:nil];
}

/// 重新排序, 不同 album
- (void)_reorderingAnotherItem:(id<UICollectionViewDropItem>)item fromSourceIndexPath:(NSIndexPath *)sourceIndexPath coordinator:(id<UICollectionViewDropCoordinator>)coordinator
{
    Photo *photo = item.dragItem.localObject;
    __block NSIndexPath *sourceIndex;
    [self.collectionView performBatchUpdates:^{
        
        sourceIndex = [[PhotoLibrary sharedInstance] sourceIndexFromPhoto:photo moveToAlbum:self.album index:coordinator.destinationIndexPath.item];
        [self.collectionView insertItemsAtIndexPaths:@[coordinator.destinationIndexPath ?: [NSIndexPath indexPathForItem:0 inSection:0]]];
    } completion:nil];
    
    [coordinator dropItem:item.dragItem toItemAtIndexPath:coordinator.destinationIndexPath];
    
    [self _updateMaster:sourceIndex];
    [self _updateMaster:nil];
}

/// 更新Master的缩略图
- (void)_updateMaster:(NSIndexPath *)indexPath
{
    if (indexPath == nil) {
        indexPath = [NSIndexPath indexPathForItem:[[PhotoLibrary sharedInstance].albums indexOfObject:self.album] inSection:0];
    }
    [self.albumController _updateAlbum];
    [self.albumController _reloadItemForIndexPath:indexPath];
}



@end
