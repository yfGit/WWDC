//
//  PhotoCell.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Photo;

@interface PhotoCell : UICollectionViewCell

@property (nonatomic, copy, class, readonly) NSString *identifier;

- (void)configureWithPhoto:(Photo *)photo;

- (CGRect)clippingRectForPhoto;

@end
