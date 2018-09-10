//
//  AlbumTableController.m
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import "AlbumTableController.h"
#import "PhotoLibrary.h"
#import "AlbumCell.h"
#import "PhotoCollectionController.h"


@interface AlbumTableController ()<UITableViewDragDelegate, UITableViewDropDelegate>

@property (nonatomic, strong) NSMutableArray *albums;

@end

@implementation AlbumTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.albums = [PhotoLibrary sharedInstance].albums;
//    self.tableView.tableFooterView = [UIView new];

    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self performSegueWithIdentifier:@"ShowPhotos" sender:self];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
#pragma mark - Drag Drop
    self.tableView.dragDelegate = self;
    self.tableView.dropDelegate = self;
    // YES: UITableViewDropIntentInsertAtDestinationIndexPath 才有效果(弹簧 和 调用didSelectRow)
    self.tableView.springLoaded = YES;
    self.tableView.dragInteractionEnabled = YES; // default YES on iPad, NO on iPhone
#pragma mark -
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedRowInex = self.tableView.indexPathForSelectedRow;
    PhotoAlbum *album = self.albums[selectedRowInex.row];
    
    UINavigationController *detailNaviController = segue.destinationViewController;
    
    PhotoCollectionController *vc = (PhotoCollectionController *)detailNaviController.topViewController;
    
    [vc loadAlbum:album fromAlbumController:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumCell.identifier forIndexPath:indexPath];
    
    [cell configureData:self.albums[indexPath.row] indexPath:indexPath];
    
    return cell;
}

#pragma mark - Drag
- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath
{
    
    // tips: 自定义遵守协议 NSItemProviderWriting
//    PhotoAlbum *album = self.albums[indexPath.row];
//    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:album.photos[0].image];
//    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
//
//    return @[item];
    
    // 提示把对应的图片放到其它地方, 一次性抓起对应张数的图片
    if (tableView.isEditing) {
        return @[];
    }else {
        return [self _dragItemsForIndexPath:indexPath];
    }
}



#pragma mark - Drop

- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    // tableView.hasActiveDrag   tableview "lift" 后, 是 tableView 本身在 drag
    // 重新排序 reordering
    if (tableView.isEditing && tableView.hasActiveDrag) {
        
        return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertAtDestinationIndexPath];
        
    } // edit 状态下, 其它app不能拖过来; 非edit状态下, 本地(tableview)不能交换
    else if (tableView.isEditing || tableView.hasActiveDrag) {

        return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden];
        
    } // 非MasterController drop
    else if (destinationIndexPath && destinationIndexPath.row < self.albums.count){
        // native
        if (session.localDragSession != nil) {
            return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertIntoDestinationIndexPath];
            
        } // another app
        else {
            return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UITableViewDropIntentInsertIntoDestinationIndexPath];
        }
    }
    
    return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCancel];
}

- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator
{
    NSIndexPath *indexPath = coordinator.destinationIndexPath;
    
    if (coordinator.proposal.operation == UIDropOperationCopy) { // another app
        [self _loadAndInsertItemsWithIndexPath:indexPath coordinator:coordinator];
        
    }else if (coordinator.proposal.operation == UIDropOperationMove) { // native
        [self _moveItemsWithIndexPath:indexPath coordinator:coordinator];
    }
}

#pragma mark - Private

/// 获取对应 indexPath 的 dragItems
- (NSArray *)_dragItemsForIndexPath:(NSIndexPath *)indexPath
{
    PhotoAlbum *album = self.albums[indexPath.row];
    NSMutableArray *dragItems = [NSMutableArray array];
    
    NSUInteger count = album.photos.count;
    for (NSUInteger i = 0; i < count; i++) {
        
        Photo *photo = album.photos[i];
        NSItemProvider *provider = photo.itemProvider; // 自解释 NSItemProvider
        UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:provider];
        item.localObject = photo;
        item.previewProvider = photo.dragPreview; // 自解释 previewProvider
        
        [dragItems addObject:item];
    }
    
    return [[dragItems reverseObjectEnumerator] allObjects]; // 数组中的最后一个元素会成为Lift 操作中的最上面的一个元素，
}

- (void)_loadAndInsertItemsWithIndexPath:(NSIndexPath *)indexPath coordinator:(id<UITableViewDropCoordinator>)coordinator
{
    PhotoAlbum *album = self.albums[indexPath.row];
    
    for (id<UITableViewDropItem> item in coordinator.items) {
        UIDragItem *dragItem = item.dragItem;
        
        if (![dragItem.itemProvider canLoadObjectOfClass:[UIImage class]]) continue;
        
        [dragItem.itemProvider loadObjectOfClass:UIImage.class completionHandler:^(id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                UIImage *image = (UIImage *)object;
                Photo *photo = [[Photo alloc] initWithImage:image];
                
                // 更新数据源  photo -> album -> library 更新 -> self.albums
                [self _updateDataSource:^{
                    [[PhotoLibrary sharedInstance] addPhoto:photo toAlbum:album];
                }];
                
                // 更新UI
                [self _updateUIForIndexPath:indexPath];
            });
        }];
        
    }
}

- (void)_moveItemsWithIndexPath:(NSIndexPath *)indexPath coordinator:(id<UITableViewDropCoordinator>)coordinator
{
    // 同album用slave移动
    
    // 只能一个个来 ?
    for (id<UITableViewDropItem> item in coordinator.items) {
        UIDragItem *dragItem = item.dragItem;
        Photo *photo = dragItem.localObject; // 只能用在native
        
        [self _updateDataSource:^{
            [[PhotoLibrary sharedInstance] movePhoto:photo toIndex:indexPath.row];
        }];
        
        // 移动动画单独dragItem
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [coordinator dropItem:dragItem intoRowAtIndexPath:indexPath rect:cell.imageView.frame];
    }
    [self _updateUIForIndexPath:indexPath];
}

- (void)_updateDataSource:(void(^)(void))_update
{
    _update();
    [self _updateAlbum];
}

- (void)_updateAlbum
{
    self.albums = [PhotoLibrary sharedInstance].albums;
}

- (void)_reloadItemForIndexPath:(NSIndexPath *)indexPath
{
    AlbumCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell configureData:self.albums[indexPath.row] indexPath:indexPath];
    [cell setNeedsLayout];
}

- (void)_updateUIForIndexPath:(NSIndexPath *)indexPath
{
    // Master每个album cell 的图片显示的是第一张
    [self _reloadItemForIndexPath:indexPath];
    
    NSIndexPath *selectedIdx = self.tableView.indexPathForSelectedRow;
    if (![selectedIdx isEqual:indexPath]) {
        [self _reloadItemForIndexPath:selectedIdx];
    }
    
    // 1. 让slave更新图片
    if (selectedIdx && self.splitViewController.viewControllers.count > 1) {
        UINavigationController *slaveNavi = self.splitViewController.viewControllers[1];
        PhotoCollectionController *vc = (PhotoCollectionController *)slaveNavi.topViewController;
        [vc loadAlbum:self.albums[selectedIdx.row] fromAlbumController:self];
    }
    
//    // selectedRow会nil且选中效果也会没有
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}




@end
