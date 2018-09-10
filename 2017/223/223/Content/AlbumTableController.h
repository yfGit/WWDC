//
//  AlbumTableController.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableController : UITableViewController

- (void)_updateAlbum;

/// Master每个album cell 的图片显示的是第一张
- (void)_reloadItemForIndexPath:(NSIndexPath *)indexPath;

@end
