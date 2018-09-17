//
//  FlowLayout.m
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import "FlowLayout.h"

@implementation FlowLayout

static int callCount = 0;

- (void)prepareLayout
{
    [super prepareLayout];
    
    callCount++;
    NSLog(@">>>>>>>>>>> -prepareLayout callCount: %d", callCount);
    
    UIView *view = self.collectionView;
    // 横竖屏 Flow 都是一个
//    self.itemSize = CGSizeMake(UIEdgeInsetsInsetRect(view.bounds, view.layoutMargins).size.width, 70.0);
    
    // 横屏2个 竖屏1个
    CGFloat availableWidth = UIEdgeInsetsInsetRect(view.bounds, view.layoutMargins).size.width;
    
    CGFloat minWidth = 300.0;
    NSUInteger maxColumns = (int)(availableWidth / minWidth);
    CGFloat cellWidth = floor(availableWidth / maxColumns);
    self.itemSize = CGSizeMake(cellWidth, 70.0);
    
    self.sectionInset = UIEdgeInsetsMake(self.minimumInteritemSpacing, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        self.sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromSafeArea;
    } else {
        // Fallback on earlier versions
    }
}



@end
