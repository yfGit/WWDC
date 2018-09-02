//
//  MosaicLayout.h
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MosaicLayout : UICollectionViewLayout

@end

/*
 自定义 FlowLayout
 
 1. 提供滚动范围
    - (CGSize)collectionViewContentSize;
 2. 提供布局属性对象
    - (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
    - (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;
 
 3. 布局的相关准备工作
    - (void)prepareLayout;
        为每个 invalidateLayout 调用
        缓存 UICollectionViewLayoutAttributes
        计算 collectionViewContentSize
 
 4. 处理自定义布局中的边界更改
    - (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds;
 */
