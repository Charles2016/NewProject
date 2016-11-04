//
//  SDWebImageManager+MJ.h
//  FingerNews
//
//  Created by mj on 13-9-23.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "SDWebImageManager.h"

@interface SDWebImageManager (MJ)
+ (void)downloadWithURL:(NSURL *)url completed:(void(^)(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL))completed;
@end
