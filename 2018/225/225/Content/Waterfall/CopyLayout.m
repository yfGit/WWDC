//
//  CopyLayout.m
//  225
//
//  Created by 许毓方 on 2018/8/30.
//  Copyright © 2018 SN. All rights reserved.
//

#import "CopyLayout.h"

@implementation CopyLayout



@end


/*
 // 缓存的布局
 
 @property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *allItemAttributes;
 @property (nonatomic, strong) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *headerAttributes;
 @property (nonatomic, strong) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *footerAttributes;
 @property (nonatomic, strong) NSMutableArray *cellAttributes; /// @[@[section0], @[cellAttributes...] ... ]
 
 /// 计算每section每列item bottom @[@[section0], @[section1], @[colum0Bottom, colum1Bottom ...]]
 @property (nonatomic, strong) NSMutableArray *columnsBottom;
 @property (nonatomic, assign) CGSize contentSize;
 
 
 // move
 /// 需要移动的item
 @property (nonatomic, strong) NSMutableArray *animatedIndexPaths;

 */

/*
 // 清空布局
 [self.allItemAttributes removeAllObjects];
 [self.cellAttributes removeAllObjects];
 [self.headerAttributes removeAllObjects];
 [self.footerAttributes removeAllObjects];
 [self.columnsBottom removeAllObjects];
 self.contentSize = CGSizeZero;
 
 UICollectionView *collectionView = self.collectionView;
 NSUInteger sectionCount = [collectionView numberOfSections];
 if (sectionCount == 0) return;
 
 // 遵守 protocol 实现 @required
 NSAssert([self.delegate conformsToProtocol:@protocol(XXXWaterfallLayoutDelegate)], @"UICollectionView's delegate should conform to XXXWaterfallLayoutDelegate protocol");
 NSAssert(self.columnCount > 0 || [self.delegate respondsToSelector:@selector(waterfallLayout:sizeForItemAtIndexPath:)], @"XXXWaterfallLayoutDelegate's columnCount should be greater than 0, or delegate must implement sizeForItemAtIndexPath:");
 
 
 CGFloat bottom = 0;
 UICollectionViewLayoutAttributes *attribute;
 
 for (NSUInteger section = 0; section < sectionCount; section++) {
 
 // 1. 初始化 columnsBottom
 NSUInteger columnCount;
 if ([self.delegate respondsToSelector:@selector(waterfallLayout:columnCountForSection:)]) {
 columnCount = [self.delegate waterfallLayout:self columnCountForSection:section];
 }else {
 columnCount = self.columnCount;
 }
 
 NSMutableArray *columns = [NSMutableArray array];
 for (NSUInteger i = 0; i < columnCount; i++) {
 [columns addObject:@(0)];
 }
 [self.columnsBottom addObject:columns];
 
 
 // 2. header
 CGFloat headerHeight;
 if ([self.delegate respondsToSelector:@selector(waterfallLayout:heightForHeaderInSection:)]) {
 headerHeight = [self.delegate waterfallLayout:self heightForHeaderInSection:section];
 }else {
 headerHeight = self.headerHeight;
 }
 
 if (headerHeight > 0) {
 attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
 attribute.frame = CGRectMake(0, bottom, collectionView.bounds.size.width, headerHeight);
 self.headerAttributes[@(section)] = attribute;
 [self.allItemAttributes addObject:attribute];
 }
 bottom += headerHeight;
 
 // 3. sectionInsets itemWidth
 CGFloat availableWidth, itemWidth, columnSpacing, rowSpacing;
 UIEdgeInsets sectionInsets;
 if ([self.delegate respondsToSelector:@selector(waterfallLayout:insetForSection:)]) {
 sectionInsets = [self.delegate waterfallLayout:self insetForSection:section];
 }else {
 sectionInsets = self.sectionInsets;
 }
 bottom += sectionInsets.top;
 
 if ([self.delegate respondsToSelector:@selector(waterfallLayout:minimumColumnSpacingForSection:)]) {
 columnSpacing = [self.delegate waterfallLayout:self minimumColumnSpacingForSection:section];
 }else {
 columnSpacing = self.minimumColumnSpacing;
 }
 
 if ([self.delegate respondsToSelector:@selector(waterfallLayout:minimumRowSpacingForSection:)]) {
 rowSpacing = [self.delegate waterfallLayout:self minimumRowSpacingForSection:section];
 }else {
 rowSpacing = self.minimumRowSpacing;
 }
 
 availableWidth = collectionView.bounds.size.width - (sectionInsets.left + sectionInsets.right);
 itemWidth = floor((availableWidth - (columnCount-1) * columnSpacing) / columnCount);
 
 for (NSUInteger i = 0; i < columnCount; i++) {
 self.columnsBottom[section][i] = @(bottom); // 每一列的起点Y
 }
 
 
 // 4. item
 NSUInteger itemCount = [collectionView numberOfItemsInSection:section];
 NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
 
 for (NSUInteger item = 0; item < itemCount; item++) {
 
 NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
 NSUInteger columnIndex = [self _shortestColumnIndexInSection:indexPath.section];
 
 CGFloat x = sectionInsets.left + (itemWidth + columnSpacing) * columnIndex;
 CGFloat y = [self.columnsBottom[section][columnIndex] floatValue];
 CGSize size = [self.delegate waterfallLayout:self sizeForItemAtIndexPath:indexPath];
 // 等比缩放
 CGFloat height = floor(size.height / size.width * itemWidth);
 attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
 attribute.frame = CGRectMake(x, y, itemWidth, height);
 
 [itemAttributes addObject:attribute];
 [self.allItemAttributes addObject:attribute];
 self.columnsBottom[section][columnIndex] = @(CGRectGetMaxY(attribute.frame) + rowSpacing);
 }
 [self.cellAttributes addObject:itemAttributes];
 
 
 // 5. footer
 NSUInteger longestIndex = [self _longestColumnIndexInSection:section];
 CGFloat itemBottom = [self.columnsBottom[section][longestIndex] floatValue];
 bottom = itemBottom;
 
 CGFloat footerHeight;
 if ([self.delegate respondsToSelector:@selector(waterfallLayout:heightForFooterInSection:)]) {
 footerHeight = [self.delegate waterfallLayout:self heightForFooterInSection:section];
 }else {
 footerHeight = self.headerHeight;
 }
 
 if (footerHeight > 0) {
 attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
 attribute.frame = CGRectMake(0, bottom, collectionView.bounds.size.width, footerHeight);
 self.footerAttributes[@(section)] = attribute;
 [self.allItemAttributes addObject:attribute];
 }
 bottom += footerHeight;
 
 for (NSUInteger i = 0; i < columnCount; i++) {
 self.columnsBottom[section][i] = @(bottom);
 }
 }
 
 self.contentSize = CGSizeMake(collectionView.bounds.size.width, bottom);
 */
