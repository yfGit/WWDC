//
//  PhotoAlbum.h
//  223
//
//  Created by 许毓方 on 2018/9/7.
//  Copyright © 2018 SN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface PhotoAlbum : NSObject<NSItemProviderWriting>

@property (nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSMutableArray<Photo *> *photos;

@property (nonatomic, strong) UIImage *thumbnail;


- (instancetype)initWithTitle:(NSString *)title photos:(NSArray *)photos;

- (BOOL)containsPhoto:(Photo *)photo;

@end
