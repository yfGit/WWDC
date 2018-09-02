//
//  WaterfallCell.h
//  225
//
//  Created by 许毓方 on 2018/8/27.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterfallCell : UICollectionViewCell

@property (nonatomic, copy, readonly, class) NSString *identifier;

- (void)configData:(NSString *)imageName indexPath:(NSIndexPath *)indexPath;

@end
