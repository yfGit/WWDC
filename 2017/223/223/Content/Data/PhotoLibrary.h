//
//  PhotoLibrary.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoAlbum.h"

@interface PhotoLibrary : NSObject

@property (nonatomic, strong) NSMutableArray<PhotoAlbum *> *albums;

+ (instancetype)sharedInstance;

- (void)addPhoto:(Photo *)photo toAlbum:(PhotoAlbum *)album;

- (void)movePhoto:(Photo *)photo toIndex:(NSUInteger)index;

- (void)insertPhoto:(Photo *)photo toAlbum:(PhotoAlbum *)album atIndex:(NSUInteger)index;

- (NSIndexPath *)sourceIndexFromPhoto:(Photo *)photo moveToAlbum:(PhotoAlbum *)album index:(NSUInteger)index;

@end
