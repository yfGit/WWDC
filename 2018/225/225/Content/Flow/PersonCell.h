//
//  PersonCell.h
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonCell : UICollectionViewCell

@property (nonatomic, copy, class, readonly) NSString *identifier;


- (void)configData:(NSString *)name;

@end
