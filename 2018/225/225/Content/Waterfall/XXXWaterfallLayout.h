//
//  WaterfallLayout.h
//  225
//
//  Created by 许毓方 on 2018/8/27.
//  Copyright © 2018 SN. All rights reserved.
//

/*
 ____________________________________________________________________________
 |              sctionInsets.top
 |               _____________                   _____________
 | sctionInsets. |           | minimumRowSpacing |           | sctionInsets.
 |    left       |           |                   |           |     right
 |               |           |                   |           |
 |               |___________|                   |___________|
 |
 |            minimumColumnSpacing
 |               _____________
 |               |           |
 |               |           |
 |               |           |
 |               |___________|
 |
 |             sctionInsets.bottom
 |____________________________________________________________________________
 
 */
#import <UIKit/UIKit.h>
@class XXXWaterfallLayout;

typedef NS_ENUM(NSUInteger, XXXLayoutAntimationType) {
    XXXLayoutAntimationTypeMove,
    XXXLayoutAntimationTypeInsert,
    XXXLayoutAntimationTypeDelete,
};

@protocol XXXWaterfallLayoutDelegate <NSObject>

@required

/// itemSize 用来获取宽高比
- (CGSize)waterfallLayout:(XXXWaterfallLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSUInteger)waterfallLayout:(XXXWaterfallLayout *)layout numberOfItemsInSection:(NSUInteger)section;

/// section colummCount
- (NSInteger)waterfallLayout:(XXXWaterfallLayout *)layout columnCountForSection:(NSUInteger)section;
/// section insets
- (UIEdgeInsets)waterfallLayout:(XXXWaterfallLayout *)layout insetForSection:(NSUInteger)section;
/// minimumColumnSpacing
- (CGFloat)waterfallLayout:(XXXWaterfallLayout *)layout minimumColumnSpacingForSection:(NSUInteger)section;
/// minimumRowSpacing
- (CGFloat)waterfallLayout:(XXXWaterfallLayout *)layout minimumRowSpacingForSection:(NSUInteger)section;
/// header height
- (CGFloat)waterfallLayout:(XXXWaterfallLayout *)layout heightForHeaderInSection:(NSUInteger)section;
/// footer height
- (CGFloat)waterfallLayout:(XXXWaterfallLayout *)layout heightForFooterInSection:(NSUInteger)section;


// animation insert delete move
- (void)waterfallLayout:(XXXWaterfallLayout *)layout animationType:(XXXLayoutAntimationType)animationType forAttributes:(UICollectionViewLayoutAttributes *)attributes;


/// move
- (void)waterfallLayout:(XXXWaterfallLayout *)layout moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

/// move end  看情况刷新数据源
- (void)moveEndWaterfallLayout:(XXXWaterfallLayout *)layout ;

@end

@interface XXXWaterfallLayout : UICollectionViewLayout

/// default self.collectionView.delegate
@property (nonatomic, weak) id<XXXWaterfallLayoutDelegate> delegate;
/// 当前多少列 default 2, 优先代理
@property (nonatomic, assign) NSInteger columnCount;
/// 列间距
@property (nonatomic, assign) CGFloat minimumColumnSpacing;
/// 行间距
@property (nonatomic, assign) CGFloat minimumRowSpacing;
/// section 内边距
@property (nonatomic, assign) UIEdgeInsets sectionInsets;
/// header height, 没实现代理时使用
@property (nonatomic, assign) CGFloat headerHeight;
/// footer height, 没实现代理时使用
@property (nonatomic, assign) CGFloat footerHeight;

/// 是否禁止 section 之间的交换数据
@property (nonatomic, assign) BOOL sectionExchangeForbidden;

@end
