//
//  AlbumCell.m
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import "AlbumCell.h"


@implementation AlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configureData:(PhotoAlbum *)data indexPath:(NSIndexPath *)indexPath
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.textLabel.text = data.title;
    self.imageView.image = data.thumbnail;
}

+ (NSString *)identifier {
    return @"AlbumCellId";
}

@end
