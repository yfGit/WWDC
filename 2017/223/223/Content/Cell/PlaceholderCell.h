//
//  PlaceholderCell.h
//  223
//
//  Created by 许毓方 on 2018/9/10.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceholderCell : UICollectionViewCell

@property (nonatomic, copy, class, readonly) NSString *identifier;

- (void)configureWithProgress:(NSProgress *)progress;

@end
