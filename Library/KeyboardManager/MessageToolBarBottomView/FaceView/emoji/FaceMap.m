//
//  FaceMap.m
//  HKMall
//
//  Created by 文俊 on 15/7/17.
//  Copyright (c) 2015年 365sji. All rights reserved.
//

#import "FaceMap.h"

@implementation FaceMap

static NSDictionary *face_Data = nil, *face_Ch = nil;
static NSDictionary *emoji_Data = nil, *emoji_Ch = nil;
+ (void)load {
    [super load];
    if (face_Data == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"faceMap" ofType:@"txt"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSError *error = nil;
        NSMutableDictionary *mface_Ch = [[NSMutableDictionary alloc]initWithCapacity:0];
        face_Data =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        for (id key in [face_Data allKeys]) {
            NSString *face_All = [face_Data objectForKey:key];
            [mface_Ch setObject:key forKey:face_All];
        }
        face_Ch = mface_Ch;
    }
}

/**
 * 通过表情字符找对应的图片名称
 * @param faceStr 表情字符
 * @return 对应图片名称
 */
+ (NSString *)compareKeyInDictionary:(NSString *)faceStr {
    NSString *imageStr = nil;
    if ([face_Ch objectForKey:faceStr]) {
        imageStr = [face_Ch objectForKey:faceStr];
    }
    return imageStr;
}

/**
 * 通过图片名称找对应的表情字符
 * @param imageStr 图片字符
 * @return 表情名称
 */
+ (NSString *)compareValueInDictionary:(NSString *)imageStr {
    NSString *faceStr = nil;
    if ([face_Data objectForKey:imageStr]) {
        faceStr = [face_Data objectForKey:imageStr];
    }
    return faceStr;
}

@end
