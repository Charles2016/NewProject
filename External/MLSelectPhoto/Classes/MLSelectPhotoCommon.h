//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerCommon.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-19.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#ifndef MLSelectPhoto_h
#define MLSelectPhoto_h

typedef NS_ENUM(NSInteger, MLSourceType) {
    MLSourcePhoto = 0,  //图片
    MLSourceVideo,      //视频
    MLSourceAudio,      //声音
    MLSourceOthers,     //其他类型
    MLSourceAll         //混合类型，包括所有类型
};

#define mWeakSelf __weak typeof(self) weakSelf = self
#define mStrongSelf __strong __typeof__(weakSelf) strongSelf = weakSelf

// 图片最多显示9张，超过9张取消单击事件
static NSInteger const KPhotoShowMaxCount = 9;
// 是否开启拍照自动保存图片
static BOOL const isCameraAutoSavePhoto = YES;
// HUD提示框动画执行的秒数
static CGFloat KHUDShowDuration = 1.0;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// Navigation Color
#define DefaultNavbarTintColor UIColorFromRGB(0xeeeeee)
#define DefaultNavTintColor UIColorFromRGB(0x333333)
#define DefaultNavTitleColor UIColorFromRGB(0x333333)
#define DefaultButtonColor UIColorFromRGB(0x3985ff)

#define iOS7gt ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

// NSNotification
static NSString *PICKER_TAKE_DONE = @"PICKER_TAKE_DONE";
static NSString *PICKER_REFRESH_DONE = @"PICKER_REFRESH_DONE";
static NSString *PICKER_PUSH_BROWSERPHOTO = @"PICKER_PUSH_BROWSERPHOTO";

// 图片路径
#define MLSelectPhotoSrcName(file) [@"MLSelectPhoto.bundle" stringByAppendingPathComponent:file]

#endif
