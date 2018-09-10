//
//  PhotoCollectionController.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoAlbum;
@class AlbumTableController;

@interface PhotoCollectionController : UICollectionViewController

- (void)loadAlbum:(PhotoAlbum *)album fromAlbumController:(AlbumTableController *)albumController;

@end
