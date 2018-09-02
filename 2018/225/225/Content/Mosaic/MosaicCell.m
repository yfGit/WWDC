//
//  MosaicCell.m
//  225
//
//  Created by 许毓方 on 2018/8/24.
//  Copyright © 2018 SN. All rights reserved.
//

#import "MosaicCell.h"

@interface MosaicCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;


@end

@implementation MosaicCell

+ (NSString *)identifier {
    return @"identifierCellId";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgView.layer.borderWidth = 1;
    self.imgView.layer.borderColor = [UIColor blackColor].CGColor;
    
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    self.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", indexPath.row % 3]];
}


@end
