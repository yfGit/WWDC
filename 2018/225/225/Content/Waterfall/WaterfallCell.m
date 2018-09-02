//
//  WaterfallCell.m
//  225
//
//  Created by 许毓方 on 2018/8/27.
//  Copyright © 2018 SN. All rights reserved.
//

#import "WaterfallCell.h"

@interface WaterfallCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end

@implementation WaterfallCell

+ (NSString *)identifier {
    return @"WaterfallCellId";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configData:(NSString *)imageName indexPath:(NSIndexPath *)indexPath
{
    self.imgView.image = [UIImage imageNamed:imageName];
    self.numLabel.text = [NSString stringWithFormat:@"%ld", indexPath.item];
}

@end
