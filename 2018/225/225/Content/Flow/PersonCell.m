//
//  PersonCell.m
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PersonCell.h"

@interface PersonCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation PersonCell

+ (NSString *)identifier
{
    return @"PersonCellId";
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)configData:(NSString *)name
{
    self.nameLabel.text = name;
}

@end
