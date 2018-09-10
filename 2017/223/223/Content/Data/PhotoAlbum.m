//
//  PhotoAlbum.m
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import "PhotoAlbum.h"

@implementation PhotoAlbum

- (instancetype)initWithTitle:(NSString *)title photos:(NSArray *)photos
{
    self = [super init];
    if (self) {
        
        _identifier = [NSUUID UUID].UUIDString;
        _title = title;
        _photos = [photos mutableCopy];
    }
    return self;
}

- (UIImage *)thumbnail
{
    return self.photos.firstObject.thumbnail;
}

- (BOOL)containsPhoto:(Photo *)photo
{
    return [self.photos containsObject:photo];
}

- (BOOL)isEqual:(id)object
{
    PhotoAlbum *o = (PhotoAlbum *)object;
    return [self.identifier isEqualToString:o.identifier];
}

@end
