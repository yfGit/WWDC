//
//  MosaicLayout.m
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import "MosaicLayout.h"

@interface MosaicLayout ()

/// 内容rect
@property (nonatomic, assign) CGRect contentBounds;
/// 缓存的布局
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *cachedAttributes;

/// union 优化
@property (nonatomic, strong) NSMutableArray<NSValue *> *unionRects;

@end

static int const unionRangeCount = 20;
@implementation MosaicLayout


/**
 called when
    invalidateLayout   shouldInvalidateLayoutForBoundsChange:
    cache UICollectionViewLayoutAttributes
    compute collectionViewContentSize
 */
- (void)prepareLayout
{
    [super prepareLayout];
    UIView *cv = self.collectionView;
    
    self.contentBounds = (CGRect) {CGPointZero, cv.bounds.size};
    [self.cachedAttributes removeAllObjects];
    
    [self prepareAttributes];
}

- (void)prepareAttributes
{
    UIView *cv = self.collectionView;
//    CGFloat availableWidth = UIEdgeInsetsInsetRect(cv.bounds, cv.layoutMargins).size.width;
    CGFloat availableWidth = cv.bounds.size.width;
    
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:index];
        CGRect frame = CGRectZero;
        CGFloat width, height;
        CGPoint origin = CGPointZero;
        
        width = floor(availableWidth / 3.0 * 2);
        height =  width * 0.5;
        if (i % 3 == 0) {
            origin = CGPointMake(0, i/3 * height);
        }else if (i % 3 == 1) {
            origin = CGPointMake(width, i/3 * height);
            width = availableWidth - width;
            height = height / 2.0;
        }else {
            origin = CGPointMake(width, i/3 * height + height*0.5);
            width = availableWidth - width;
            height = height / 2.0;
        }
        frame = (CGRect) {origin, CGSizeMake(width, height)};
        attribute.frame = frame;
        [self.cachedAttributes addObject:attribute];
    }
    
    self.contentBounds = (CGRect) {CGPointZero, CGSizeMake(cv.bounds.size.width, floor(availableWidth / 3.0 * 2) * 0.5 *(count/3 + count%3))};
    
    
    // union
    NSUInteger index = 0;
    NSUInteger itemCount = self.cachedAttributes.count;
    
    while (index < itemCount) {
        CGRect unionRect = self.cachedAttributes[index].frame;
        NSUInteger endIndex = MIN(index + unionRangeCount, itemCount);
        
        for (NSUInteger i = index+1; i < endIndex; i++) {
            unionRect = CGRectUnion(unionRect, self.cachedAttributes[i].frame);
        }
        
        index = endIndex;
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}


- (CGSize)collectionViewContentSize {
    return self.contentBounds.size;
}

/**
 called when
    every bounds change
        - Size change
        - Origin change
    during scrolling
 Default NO
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    return !(CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size));
    return (CGRectGetWidth(newBounds) != CGRectGetWidth(self.collectionView.bounds));
}

// 根据indexPath去对应的 UICollectionViewLayoutAttributes 这个是取值的，要重写，
// 在移动删除的时候系统会调用该方法重新取 UICollectionViewLayoutAttributes 然后布局
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cachedAttributes[indexPath.item];
}

/// 此方法应该返回 当前屏幕正在显示的视图（cell 头尾视图）的布局属性集合
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    static NSTimeInterval min = CGFLOAT_MAX;
    static NSTimeInterval max = 0;
    static NSTimeInterval sum = 0;
    static NSUInteger count = 0;
    count++;
    
    NSTimeInterval now = CACurrentMediaTime();
    NSArray *array;
    
//    array = self.cachedAttributes; // 数量1000 倒也没什么影响, 再多会掉帧

    // 未优化
//    array = [self _normal_layoutAttributesForElementsInRect:rect];

    // unionRect
//    array = [self _unionRect_layoutAttributesForElementsInRect:rect];
    
    // 优化 二分查找    /* 数量越多, 优化越好, 但是帧数差不多(一帧时间内足够计算好,  CPU+GPU一帧完成内就不会掉帧) */
    array = [self _binarySearch_layoutAttributesForElementsInRect:rect];

    NSTimeInterval after = CACurrentMediaTime();
    NSTimeInterval diff  = after - now;
    if (diff < min) min = diff;
    if (diff > max) max = diff;
    
    sum += diff;
    
    NSLog(@"%f <==> min:%f <==> max:%f <==> avg:%f", diff, min, max, sum/count);
    
    return array;
}

/*
 还是曲线图好很多. 最低最高不能代表太多, 还好数据差的挺多的; 不过帧数大都是60, 个别至少58
 union 是没把 -prepareLayout 里面的循环计算进去
 
 
 对应的 内部方法计算
 
 6s/11.4      normal        union         binary

 min         0.000013      0.000087      0.000006
   100
 max         0.000038      0.000144      0.000111
 
 
 min         0.000080      0.000093      0.000006
   1000
 max         0.001464      0.000732      0.000332
 
 
 min         0.000978      0.000193      0.000011
   10000
 max         0.008514      0.001842      0.000448
 
 */

#pragma mark - Private Method
- (NSArray *)_normal_layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *searchArray = [NSMutableArray array];
    [self.cachedAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [searchArray addObject:attribute];
        }
    }];

    return searchArray;
}

/* Union 优化
 1. CGRectUnion 分割成几个几个rect,
 2. 再通过 CGRectIntersectsRect 找到头尾相交的 rect
 3. 最后 CGRectIntersectsRect 找到对应的attribute
 cell数量越大, 效率越低. 但还是比 normal 好上不少
 */
- (NSArray *)_unionRect_layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *searchArray = [NSMutableArray array];
    
    __block NSUInteger startIdx = 0;
    __block NSUInteger endIdx = 0;
    [self.unionRects enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect unionRect = [obj CGRectValue];
        if (CGRectIntersectsRect(rect, unionRect)) {
            startIdx = MIN(idx * unionRangeCount, self.cachedAttributes.count);
            *stop = YES;
        }
    }];
    
    [self.unionRects enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect unionRect = [obj CGRectValue];
        if (CGRectIntersectsRect(rect, unionRect)) {
            endIdx = MIN((idx+1) * unionRangeCount, self.cachedAttributes.count);
            *stop = YES;
        }
    }];
    
    for (NSUInteger i = startIdx; i < endIdx ; i++) {
        UICollectionViewLayoutAttributes *att = self.cachedAttributes[i];
        if (CGRectIntersectsRect(rect, att.frame)) {
            [searchArray addObject:att];
        }
        // tips: attr.representedElementCategory  可区分 Header, Footer, Cell, Decoration
    }
    
    return searchArray;
}

- (NSArray *)_binarySearch_layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *searchArray = [NSMutableArray array];
    
    NSInteger index = [self _binarySearchAttributes:self.cachedAttributes searchRect:rect];
    NSUInteger count = self.cachedAttributes.count;
    
    if (index < 0) return self.cachedAttributes;
    
    // see  binarySearch@2x1.jpg
    // (index, 0]   MaxY >= MinY 瀑布流有问题
    for (NSInteger i = index-1; i >= 0; i--) {
        UICollectionViewLayoutAttributes *attribute = self.cachedAttributes[i];
//        if (CGRectGetMaxY(attribute.frame) >= CGRectGetMinY(rect)) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [searchArray addObject:attribute];
        }else {
            break;
        }
    }
    
    // [index, count)  MinY <= MaxY
    for (NSUInteger i = index; i < count; i++) {
        UICollectionViewLayoutAttributes *attribute = self.cachedAttributes[i];
        if (CGRectGetMinY(attribute.frame) <= CGRectGetMaxY(rect)) {
            [searchArray addObject:attribute];
        }else {
            break;
        }
    }
    
    return searchArray;
}

/// 自定义二分查找
- (NSInteger)_binarySearchAttributes:(NSArray<UICollectionViewLayoutAttributes *> *)array searchRect:(CGRect)rect
{
    NSUInteger min = 0;
    NSUInteger max = array.count;
    NSUInteger mid = 0;
    
    BOOL found = NO;
    
    while (min <= max) {
        mid = (min + max) / 2;
        if (mid >= array.count) break;
        
        CGRect midRect = array[mid].frame;
        if (CGRectIntersectsRect(rect, midRect)) {
            found = YES;
            break;
        }else if (CGRectGetMaxY(rect) < CGRectGetMinY(midRect)) {
            max = mid - 1;
        }else {
            min = mid + 1;
        }
        
    }
    
    return found ? mid : -1;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)cachedAttributes
{
    if (!_cachedAttributes) {
        _cachedAttributes = [NSMutableArray array];
    }
    return _cachedAttributes;
}

- (NSMutableArray<NSValue *> *)unionRects
{
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}


@end
