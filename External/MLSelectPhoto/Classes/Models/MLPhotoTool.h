//
//  MLPhotoTool.h
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MLSelectPhotoAssets.h"
#import "MLSelectPhotoPickerGroup.h"

typedef NS_ENUM(NSInteger, MLReturnType) {
    MLReturnTypeURL = 0,// 保存到相册后返回URL类型
    MLReturnTypeAsset,// 保存到相册后返回asset类型
    MLReturnTypeImage,// 保存到相册后返回UIImage类型
};

#define ML_ISIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MLPhotoTool : NSObject

@property (nonatomic , strong) ALAssetsLibrary *library;

+ (instancetype)sharePhotoTool;

/// 获取最新一张图片
- (void)getLatestDataWithReturnType:(MLReturnType)returnType sourceType:(MLSourceType)sourceType complete:(void(^)(id asset))complete;
/// 获取所有相册列表，sourceType资源类型
- (void)getAllDataWithSourceType:(MLSourceType)sourceType complete:(void(^)(NSArray *photoAblumLists))complete;
/// 传入相册集，获取该相册集中所有asset，sourceType资源类型
- (void)getAllDataWithAssetsGroup:(id)assetsGroup sourceType:(MLSourceType)sourceType isAscending:(BOOL)isAscending complete:(void(^)(NSArray *photoAsset))complete;
/// 传入assets获取资源类型(图片，声音，视频等）
- (MLSourceType)getSourceTypeWithAsset:(id)asset;
/// 传入asset获取缩略图
- (void)getThumbImageWithAsset:(id)asset complete:(void(^)(UIImage *thumbImage))complete;
// 传入asset获取缩略图(若是gif格式&&gifCare则返回imageData, 若是普通格式图片则返回image)
- (void)getThumbImageWithGifAsset:(id)asset gifCare:(BOOL)gifCare complete:(void(^)(id thumbImage))complete;
/// 传入asset获取原图
- (void)getFullImageWithAsset:(id)asset complete:(void(^)(UIImage *fullImage))complete;
// 传入asset获取原图(若是gif格式&&gifCare则返回imageData, 若是普通格式图片则返回image)
- (void)getFullImageWithGifAsset:(id)asset gifCare:(BOOL)gifCare complete:(void(^)(id fullImage))complete;
/// 传入相册集取到相册第一张缩略图
- (void)getFirstThumbWithAssetGroup:(id)assetGroup sourceType:(MLSourceType)sourceType complete:(void(^)(UIImage *thumbImage))complete;
/// 传入asset判断是否是同一个用于小图和原图时的比较
- (BOOL)isSameAsset:(id)asset asset:(id)otherAsset;
/// 判断gif资源图片
- (BOOL)isGifAsset:(id)asset;
/// 传URL取到对应的图片信息
- (id)getAssetWithURL:(NSURL *)url;
/// 传入图片or视频进行保存，返回指定类型asset或url
- (void)saveSourceWithData:(id)data isVideo:(BOOL)isVideo returnType:(MLReturnType)returnType complete:(void(^)(id source))complete;

@end
