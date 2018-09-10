//
//  ToDoList.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#ifndef ToDoList_h
#define ToDoList_h


2. 写个遵守 NSItemProviderWriting 的类 PhotoAlbum

3. add 不同albums crash, 进入其它 album 时是 重新排序状态; 还有不同section

4. prepareForSegue 载入第一次有点延迟
    [PhotoCollectionController new], 图片第一次没有还没有解码到全局缓存中

5. @property (nonatomic, copy, readonly) UIDragPreview * _Nullable (^dragPreview)(void); 调用次数有问题, 官方demo也有这问题

6. collectionView reordering 时 preview 大小应该正常   proposal.prefersFullSizePreview 同一app



discussion:
A: prepareForSegue 载入第一次有点延迟
Q: 因为 [PhotoCollectionController new], 图片第一次没有还没有解码到全局缓存中


/* tips:
 https://www.jianshu.com/p/92d21cc6de99
 
 tableView.hasActiveDrag
 tableView.hasActiveDrop   // tableView
 
 dragItem.localObject // 区分app, 得先赋值, 适当时不需要用 NSItemProvider
 session.localDragSession // nil diff app
 
 tableView reload 类似方法会取消选中
 
 dragItem.previewProvider 是可以自己描述预览图的block
 
 - (NSArray<UIDragItem *> *)tableView: itemsForBeginningDragSession: atIndexPath:
 多个数时, 数组中的最后一个元素会成为Lift 操作中的最上面的一个元素，
 按需求看是倒序加入, drop时 顺序也一样改变, 同样还有add的顺序(这样的话add时倒序反而不好), 看需要不需要重视插入数据的顺序
 
 - (UITableViewDropProposal *)tableView: dropSessionDidUpdate: withDestinationIndexPath:destinationIndexPath
 Proposal: another app => copy, native => move
 destinationIndexPath == nil; 拖在tableView所在区域没有cell的地方
 
 */

#endif /* ToDoList_h */
