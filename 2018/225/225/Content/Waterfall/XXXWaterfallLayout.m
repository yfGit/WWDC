//
//  WaterfallLayout.m
//  225
//
//  Created by 许毓方 on 2018/8/27.
//  Copyright © 2018 SN. All rights reserved.
//

#import "XXXWaterfallLayout.h"

@interface XXXWaterfallLayout ()

// 缓存的布局

@property (nonatomic, strong, readonly) NSMutableArray<UICollectionViewLayoutAttributes *> *allItemAttributes;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *headerAttributes;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *footerAttributes;
@property (nonatomic, strong, readonly) NSMutableArray *cellAttributes; /// @[@[section0], @[cellAttributes...] ... ]

@property (nonatomic, assign) CGSize contentSize;

// move
/// 需要移动的item
@property (nonatomic, strong) NSMutableArray *animatedIndexPaths;

/// 是否需要刷新数据源, 0-0 move 0-0 不需要, 否则都需要 (不同section必须, 否则会显示错误)
@property (nonatomic, assign) BOOL needReload;
/// move 初始 indexPath
@property (nonatomic, strong) NSIndexPath *initiatoryIndexPath;

@end

@implementation XXXWaterfallLayout

#pragma mark - Override

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initParameter];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initParameter];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
//    NSLog(@"prepareLayout");
    // 清空布局
    [self.allItemAttributes removeAllObjects];
    [self.cellAttributes removeAllObjects];
    [self.headerAttributes removeAllObjects];
    [self.footerAttributes removeAllObjects];
    self.contentSize = CGSizeZero;
    
    NSUInteger sectionCount = [self.collectionView numberOfSections];
    if (sectionCount == 0) return;
    
    // 遵守 protocol 实现 @required
    NSAssert([self.delegate conformsToProtocol:@protocol(XXXWaterfallLayoutDelegate)], @"UICollectionView's delegate should conform to XXXWaterfallLayoutDelegate protocol");
    NSAssert(self.columnCount > 0 || [self.delegate respondsToSelector:@selector(waterfallLayout:sizeForItemAtIndexPath:)], @"XXXWaterfallLayoutDelegate's columnCount should be greater than 0, or delegate must implement sizeForItemAtIndexPath:");
    
    
    CGFloat bottom = 0;
    NSMutableArray *columnsBottom = [NSMutableArray array];
    
    for (NSUInteger section = 0; section < sectionCount; section++) {
        
        [columnsBottom removeAllObjects];
        
        NSUInteger columnCount;
        if ([self.delegate respondsToSelector:@selector(waterfallLayout:columnCountForSection:)]) {
            columnCount = [self.delegate waterfallLayout:self columnCountForSection:section];
        }else {
            columnCount = self.columnCount;
        }
    
        
        // 1. header
        CGFloat headerHeight;
        if ([self.delegate respondsToSelector:@selector(waterfallLayout:heightForHeaderInSection:)]) {
            headerHeight = [self.delegate waterfallLayout:self heightForHeaderInSection:section];
        }else {
            headerHeight = self.headerHeight;
        }

        if (headerHeight > 0) {
            UICollectionViewLayoutAttributes * attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            attribute.frame = CGRectMake(0, bottom, self.collectionView.bounds.size.width, headerHeight);
            self.headerAttributes[@(section)] = attribute;
            [self.allItemAttributes addObject:attribute];
        }
        bottom += headerHeight;
        
        
        // 2. sectionInsets itemWidth
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
        
        availableWidth = self.collectionView.bounds.size.width - (sectionInsets.left + sectionInsets.right);
        itemWidth = ((availableWidth - (columnCount-1) * columnSpacing) / columnCount);
        
        for (NSUInteger i = 0; i < columnCount; i++) {
            [columnsBottom addObject:@(bottom)]; // 初始化每一列的起点Y
        }
        
        
        // 3. item
        NSUInteger itemCount ;
        if ([self.delegate respondsToSelector:@selector(waterfallLayout:numberOfItemsInSection:)]) {
            itemCount = [self.delegate waterfallLayout:self numberOfItemsInSection:section];
        }else {
            itemCount = [self.collectionView numberOfItemsInSection:section]; // 不同 section 之间交换时会有问题
        }
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];

        for (NSUInteger item = 0; item < itemCount; item++) {

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            NSUInteger shortestIndex = [self _shortestColumnIndexInSection:indexPath.section data:columnsBottom];
            
            CGFloat x = sectionInsets.left + (itemWidth + columnSpacing) * shortestIndex;
            CGFloat y = [columnsBottom[shortestIndex] floatValue];
            CGSize size = [self.delegate waterfallLayout:self sizeForItemAtIndexPath:indexPath];
            // 等比缩放
            CGFloat height = (size.height / size.width * itemWidth);
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attribute.frame = CGRectMake(x, y, itemWidth, height);
            
            [itemAttributes addObject:attribute];
            [self.allItemAttributes addObject:attribute];
            columnsBottom[shortestIndex] = @(CGRectGetMaxY(attribute.frame) + rowSpacing);
        }
        [self.cellAttributes addObject:itemAttributes];
        
        
        // 4. footer
        // 重新获取bottom
        NSUInteger longestIndex = [self _longestColumnIndexInSection:section data:columnsBottom];
        CGFloat itemBottom = [columnsBottom[longestIndex] floatValue] - rowSpacing; // 最后一行不需要 rowSpacing
        bottom = itemBottom;
        bottom += sectionInsets.bottom;

        CGFloat footerHeight;
        if ([self.delegate respondsToSelector:@selector(waterfallLayout:heightForFooterInSection:)]) {
            footerHeight = [self.delegate waterfallLayout:self heightForFooterInSection:section];
        }else {
            footerHeight = self.headerHeight;
        }

        if (footerHeight > 0) {
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attribute.frame = CGRectMake(0, bottom, self.collectionView.bounds.size.width, footerHeight);
            self.footerAttributes[@(section)] = attribute;
            [self.allItemAttributes addObject:attribute];
        }
        bottom += footerHeight;
    }
    
    self.contentSize = CGSizeMake(self.collectionView.bounds.size.width, bottom);
}

/// 是否需要重新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return !CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size);
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}


/**
 出现以下情况, 平常显示二分查找没有问题; move移动时会出现 当前移动目标 上面的item会动, 如第0个 (正常只会动当前item以下的)
 
 1. self.allItemAttributes 是顺序装入 y值越来越大
 但是不代表 item 的 maxY 越来越大;
 所以  maxY >= minY  可能会少
 minY <= maxY  正常
 
 2. {xx, xx}, {1, 1} 有可能会出现这种 rect, 二分查找会很大机率错过
 */
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    // cell 布局
    [self.cellAttributes enumerateObjectsUsingBlock:^(NSArray *index , NSUInteger idx, BOOL * _Nonnull stop) {
        [index enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx2, BOOL * _Nonnull stop2) {
            if (CGRectIntersectsRect(rect, attribute.frame)) {
                [allAttributes addObject:attribute];
            }
        }];
    }];
    
    // header 布局
    [self.headerAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    // footer 布局
    [self.footerAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    return allAttributes;
    
    NSMutableArray *searchArray = [NSMutableArray array];
    if (CGSizeEqualToSize(rect.size, CGSizeMake(1, 1))) {
        
    }
    NSInteger index = [self _binarySearchAttributes:self.allItemAttributes searchRect:rect];
    NSUInteger count = self.allItemAttributes.count;
    
    
    if (index < 0) {
        if (allAttributes.count > 0) {
            NSLog(@"-1 <<<>>> %@", NSStringFromCGRect(rect));
        }
        return searchArray;
    }
    
    // see  binarySearch@2x1.jpg
    // (index, 0]   MaxY >= MinY 有问题, 第4个item 不定会比第3个item maxY 大, 数组是按 minY 排的
    for (NSInteger i = index-1; i >= 0; i--) {
        UICollectionViewLayoutAttributes *attribute = self.allItemAttributes[i];
//        if (CGRectGetMaxY(attribute.frame) >= CGRectGetMinY(rect)) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [searchArray addObject:attribute];
        }else {
            break;
        }
    }
    
    // [index, count)  MinY <= MaxY
    for (NSUInteger i = index; i < count; i++) {
        UICollectionViewLayoutAttributes *attribute = self.allItemAttributes[i];
        if (CGRectGetMinY(attribute.frame) <= CGRectGetMaxY(rect)) {
//        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [searchArray addObject:attribute];
        }else {
            break;
        }
    }

//    return allAttributes;
    return searchArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return self.headerAttributes[@(indexPath.section)];
    }else {
        return self.footerAttributes[@(indexPath.section)];
    }
}

#pragma mark Move

/// 必须实现(要不没移动效果): 查询 item 的布局信息
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellAttributes[indexPath.section][indexPath.item];
}

/// 移动 初始到最后, 动画反复调用
- (UICollectionViewLayoutAttributes *)layoutAttributesForInteractivelyMovingItemAtIndexPath:(NSIndexPath *)indexPath withTargetPosition:(CGPoint)position
{
    // 是否需要刷新数据源
    if (self.initiatoryIndexPath == nil) {
        self.initiatoryIndexPath = indexPath;
    }else {
        self.needReload = ![self.initiatoryIndexPath isEqual:indexPath];
    }
    
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForInteractivelyMovingItemAtIndexPath:indexPath withTargetPosition:position];
    
//    NSIndexPath *targetIndex = [self.collectionView indexPathForItemAtPoint:position];
//    if (targetIndex && ![targetIndex isEqual:indexPath] &&
//        [self.delegate respondsToSelector:@selector(waterfallLayout:animationType:forAttributes:)]) {
//        [self.delegate waterfallLayout:self animationType:XXXLayoutAntimationTypeMove forAttributes:attr];
//    }
//    NSLog(@"%@", indexPath);
//    NSLog(@"%@", targetIndex);
//    NSLog(@"===================");
    if ([self.delegate respondsToSelector:@selector(waterfallLayout:animationType:forAttributes:)]) {
        [self.delegate waterfallLayout:self animationType:XXXLayoutAntimationTypeMove forAttributes:attr];
    }
    
    return attr;
}

/// 移动目标点
- (NSIndexPath *)targetIndexPathForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath withPosition:(CGPoint)position
{
    // 禁止不同 section 之间交换
    if (self.sectionExchangeForbidden) {
        NSIndexPath *targetIndex = [self.collectionView indexPathForItemAtPoint:position];
        if (targetIndex.section != previousIndexPath.section) {
            return previousIndexPath;
            
            return self.initiatoryIndexPath; // tips: 哪来回哪去  不同section会卡住(跨一个屏幕, 可交换时这时会crash. 是不是同一个原因)
        }
    }

    NSIndexPath *indexPath = [super targetIndexPathForInteractivelyMovingItem:previousIndexPath withPosition:position];
    
    return indexPath;
}

/// updateInteractiveMovementTargetPosition: 调用
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForInteractivelyMovingItems:(NSArray<NSIndexPath *> *)targetIndexPaths withTargetPosition:(CGPoint)targetPosition previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths previousPosition:(CGPoint)previousPosition NS_AVAILABLE_IOS(9_0)
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForInteractivelyMovingItems:targetIndexPaths withTargetPosition:targetPosition previousIndexPaths:previousIndexPaths previousPosition:previousPosition];
    
    if ([self.delegate respondsToSelector:@selector(waterfallLayout:moveItemAtIndexPath:toIndexPath:)]) {
        [self.delegate waterfallLayout:self moveItemAtIndexPath:previousIndexPaths[0] toIndexPath:targetIndexPaths[0]];
    }
//    if ([self.collectionView.dataSource respondsToSelector:@selector(collectionView:moveItemAtIndexPath:toIndexPath:)]) {
//        [self.collectionView.dataSource collectionView:self.collectionView moveItemAtIndexPath:previousIndexPaths[0] toIndexPath:targetIndexPaths[0]];
//    }
    return context;
}

/**
 移动完成或取消  section0 -> section1  发现没有section0了... 变成 section1 -> section1
 
 move 时: 两个indexPaths 都是 1 个一样的 indexPath 的数组
 */
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths movementCancelled:(BOOL)movementCancelled NS_AVAILABLE_IOS(9_0)
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:indexPaths previousIndexPaths:previousIndexPaths movementCancelled:movementCancelled];
    
    if(movementCancelled){
        NSLog(@"cancel");
    }
    NSLog(@"ending");
    
    self.initiatoryIndexPath = nil;
    if (self.needReload && [self.delegate respondsToSelector:@selector(moveEndWaterfallLayout:)]) {
        [self.delegate moveEndWaterfallLayout:self];
    }
    
    return context;
}
#pragma mark inserted, deleted
///  inserted, deleted, or moved 前调用  获取需要动画的indexPath
- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems]; // super

    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewUpdateItem *item in updateItems) {
        
        switch (item.updateAction) {
            case UICollectionUpdateActionMove: {
//                [indexPaths addObject:item.indexPathBeforeUpdate];
//                [indexPaths addObject:item.indexPathAfterUpdate];
            } break;
            case UICollectionUpdateActionInsert: {
                [indexPaths addObject:item.indexPathAfterUpdate]; // see collectionView_anim@2x.png
            } break;
            case UICollectionUpdateActionDelete: {
                [indexPaths addObject:item.indexPathBeforeUpdate];
            } break;

            default:
                // UICollectionUpdateActionNone, UICollectionUpdateActionReload
                break;
        }
    }
    self.animatedIndexPaths = indexPaths;
}

// override super 什么都不做原效果也会消失, 按自定义动画执行, 如 - collectionView: willDisplayCell: forItemAtIndexPath:
/// 将被 insert 的 item 开始状态LayoutAttributes (返回nil，布局会使用item的最终属性作为动画的起点和终点)
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if ([self.animatedIndexPaths containsObject:itemIndexPath]) {
    
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
        if ([self.delegate respondsToSelector:@selector(waterfallLayout:animationType:forAttributes:)]) {
            [self.delegate waterfallLayout:self animationType:XXXLayoutAntimationTypeInsert forAttributes:attr];
        }
        [self.animatedIndexPaths removeObject:itemIndexPath];
        
        return attr;
    }
    return nil;
}

/// 将被 delete 的 item 结束状态LayoutAttributes
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if ([self.animatedIndexPaths containsObject:itemIndexPath]) {

        // 最后一个给不了动画... 设计问题?  动画是在 数据源改变了, 但是UI没改变 的状态下执行的
        // collectionView deleteItemsAtIndexPaths:    =>  - prepareLayout(还没刷新UI)   =>   此方法  => 自定义刷新UI
        if (itemIndexPath.item >= [self.cellAttributes[itemIndexPath.section] count]) {
            return nil; // 用 字典 不会Crash
        }
        
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];

        if ([self.delegate respondsToSelector:@selector(waterfallLayout:animationType:forAttributes:)]) {
            [self.delegate waterfallLayout:self animationType:XXXLayoutAntimationTypeDelete forAttributes:attr];
        }
        [self.animatedIndexPaths removeObject:itemIndexPath];

        return attr;
    }
    return nil;
}



/**
 上面两个方法循环调用后
 inserted, deleted, or moved 后所需的步骤
 */
- (void)finalizeCollectionViewUpdates
{
    self.animatedIndexPaths = nil;
}

#pragma mark - Private Method

- (void)_initParameter
{
    _columnCount = 2;
    _minimumRowSpacing = 10;
    _minimumColumnSpacing = 10;
    _sectionInsets = UIEdgeInsetsZero;
    
    _allItemAttributes = [NSMutableArray array];
    _cellAttributes    = [NSMutableArray array];
    _headerAttributes  = [NSMutableDictionary dictionary];
    _footerAttributes  = [NSMutableDictionary dictionary];
}

/// 找到最短的item column index
- (NSUInteger)_shortestColumnIndexInSection:(NSUInteger)section data:(NSArray *)data
{
    __block NSUInteger index = 0;
    __block CGFloat shortestBottom = CGFLOAT_MAX;
    [data enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL * _Nonnull stop) {
        if (num.floatValue < shortestBottom) {
            shortestBottom = num.floatValue;
            index = idx;
        }
    }];
    return index;
}

/// 找到最长的item column index
- (NSUInteger)_longestColumnIndexInSection:(NSUInteger)section data:(NSArray *)data
{
    __block NSUInteger index = 0;
    __block CGFloat longestBottom = 0;
    [data enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL * _Nonnull stop) {
        if (num.floatValue > longestBottom) {
            longestBottom = num.floatValue;
            index = idx;
        }
    }];
    return index;
}

/// 自定义二分查找
- (NSInteger)_binarySearchAttributes:(NSArray<UICollectionViewLayoutAttributes *> *)array searchRect:(CGRect)rect
{
    NSUInteger min = 0;
    NSUInteger max = array.count - 1;
    NSUInteger mid = 0;
    
    BOOL found = NO;
    
    while (min <= max) {
        mid = (min + max) / 2;
        
        CGRect midRect = array[mid].frame;
        if (CGRectIntersectsRect(rect, midRect)) {
            found = YES;
            break;
        }else if (CGRectGetMaxY(rect) < CGRectGetMinY(midRect)) {
            max = mid - 1;
        }else {
            if (CGRectGetMaxY(rect) == CGRectGetMinY(midRect) &&
                CGRectGetMinX(rect) < CGRectGetMinX(midRect)) {
                max = mid - 1;
            }else {
                min = mid + 1;
            }
        }
    }
    
    return found ? mid : -1;
}

#pragma mark - Getter && Setter

- (id<XXXWaterfallLayoutDelegate>)delegate
{
    return _delegate ?: (id <XXXWaterfallLayoutDelegate>) self.collectionView.delegate;
}

- (void)setColumnCount:(NSInteger)columnCount
{
    if (_columnCount != columnCount) {
        _columnCount = columnCount;
        [self invalidateLayout];
    }
}

- (void)setMinimumColumnSpacing:(CGFloat)minimumColumnSpacing
{
    if (_minimumColumnSpacing != minimumColumnSpacing) {
        _minimumColumnSpacing = minimumColumnSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumRowSpacing:(CGFloat)minimumRowSpacing
{
    if (_minimumRowSpacing != minimumRowSpacing) {
        _minimumRowSpacing = minimumRowSpacing;
        [self invalidateLayout];
    }
}

- (void)setSectionInsets:(UIEdgeInsets)sectionInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInsets, sectionInsets)) {
        _sectionInsets = sectionInsets;
        [self invalidateLayout];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

- (void)setFooterHeight:(CGFloat)footerHeight
{
    if (_footerHeight != footerHeight) {
        _footerHeight = footerHeight;
        [self invalidateLayout];
    }
}

@end
