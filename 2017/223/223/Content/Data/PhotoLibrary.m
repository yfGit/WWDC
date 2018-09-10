//
//  PhotoLibrary.m
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PhotoLibrary.h"

@implementation PhotoLibrary


+ (instancetype)sharedInstance
{
    static PhotoLibrary *photoLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoLibrary = [[self alloc] init];
    });
    return photoLibrary;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _loadSampleData];
    }
    return self;
}

#pragma mark - Method
/// another app 过来, 原来没有这个图片
- (void)addPhoto:(Photo *)photo toAlbum:(PhotoAlbum *)album
{
    if (!photo) return;
    
    NSUInteger idx = [self.albums indexOfObject:album];
    if (idx != NSNotFound) {
        [self.albums[idx].photos insertObject:photo atIndex:0];
    }
}

/// native app, 原来有这个图片
- (void)movePhoto:(Photo *)photo toIndex:(NSUInteger)index
{
    if (!photo) return;
    // 删除
    [self.albums enumerateObjectsUsingBlock:^(PhotoAlbum * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.photos containsObject:photo]) {
            [obj.photos removeObject:photo];
            return ;
        }
    }];
    
    // 插入
    [self.albums[index].photos insertObject:photo atIndex:0];
}

- (void)insertPhoto:(Photo *)photo toAlbum:(PhotoAlbum *)album atIndex:(NSUInteger)index
{
    if (!photo) return;
    NSUInteger idx = [self.albums indexOfObject:album];
    [self.albums[idx].photos insertObject:photo atIndex:index];
}

- (NSIndexPath *)sourceIndexFromPhoto:(Photo *)photo moveToAlbum:(PhotoAlbum *)album index:(NSUInteger)index
{
    
    // 找到原来的 album,  删除
    NSUInteger sourceIdx = 0;
    for (PhotoAlbum *photoAlbum in self.albums) {
        if ([photoAlbum containsPhoto:photo]) {
            sourceIdx = [self.albums indexOfObject:photoAlbum];
            [photoAlbum.photos removeObject:photo];
            break;
        }
    }
    
    // 插入到新的album
    [album.photos insertObject:photo atIndex:index];
    
    return [NSIndexPath indexPathForItem:sourceIdx inSection:0];
}

#pragma mark - Private Method

- (void)_loadSampleData
{
    NSTimeInterval begin = CACurrentMediaTime();
    
    self.albums = [NSMutableArray array];
    NSUInteger albumIndex = 0;
    BOOL foundAlbum;
    do {
        foundAlbum = NO;
        NSMutableArray *phots = [NSMutableArray array];
        
        
        BOOL foundImage;
        NSUInteger imageIndex = 0;
        do {
            foundImage = NO;
            
            NSString *imageName = [NSString stringWithFormat:@"Album%luPhoto%lu", albumIndex, imageIndex]; // Album0Photo0
            UIImage *image = [UIImage imageNamed:imageName];
            if (image) {
                foundImage = YES;
                Photo *photo = [[Photo alloc] initWithImage:image];
                [phots addObject:photo];
            }
            imageIndex++;
            
        } while (foundImage);
        
        
        albumIndex++;
        if (phots.count != 0) {
            foundAlbum = YES;
            NSString *title = [NSString stringWithFormat:@"Album%lu", albumIndex];
            PhotoAlbum *album = [[PhotoAlbum alloc] initWithTitle:title photos:phots];
            [self.albums addObject:album];
        }
        
    } while (foundAlbum);
    
    NSTimeInterval end = CACurrentMediaTime();
    NSLog(@"time init ==> %f", end - begin);
}

@end
