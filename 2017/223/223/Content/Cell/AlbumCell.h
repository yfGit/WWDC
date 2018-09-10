//
//  AlbumCell.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoAlbum.h"

@interface AlbumCell : UITableViewCell

@property (nonatomic, copy, class, readonly) NSString *identifier;

- (void)configureData:(PhotoAlbum *)data indexPath:(NSIndexPath *)indexPath;

@end
