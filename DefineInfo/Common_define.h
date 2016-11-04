//
//  Common_define.h
//  HKC
//
//  Created by zhangshaoyu on 14-10-27.
//  Copyright (c) 2014年 zhangshaoyu. All rights reserved.
//  功能描述：常用宏定义

/***common**/
#import "Common_font.h"
#import "Common_color.h"
#import "Common_Markwords.h"
#import "Common_time.h"
#import "Common_limit.h"
#import "Common_image.h"
#import "Common_nofication.h"
#import "AutoSizeCGRect.h"
#import "APIKey.h"

/***Category***/
#import "CategoryHelper.h"

/***View***/
#import "LoadingAndRefreshView.h"
#import "ShareView.h"

/***Model***/
#import "UUID.h"
#import "UserModel.h"
#import "StatusModel.h"

/***Controllers***/
#import "SuperVC.h"
#import "SuperScrollVC.h"
#import "WebviewController.h"

/***Manager***/
#import "DataHelper.h"
#import "DataManager.h"
#import "HUDManager.h"

/***Util***/
#import "UIInitMethod.h"
#import "TimeUtil.h"
#import "HXFAlertView.h"
#import "PhonePermission.h"
#import "UploadImageTool.h"
#import "CommonUtil.h"
#import "SandboxFile.h"

/***Configure***/
#import "NetConfigure.h"

/***Thirdparty***/
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"
#import "WXApi.h"
#import "PayModel.h"
#import <AlipaySDK/AlipaySDK.h>

#import "IQKeyboardManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MLSelectPhoto.h"
#import "MJExtension.h"
#import <TuSDKGeeV1/TuSDKGeeV1.h>
#import <TuSDK/TuSDK.h>
#import "RegexKitLite.h"
#import "UMShare.h"
#import "MobClick.h"
#import "Masonry.h"
#import <RongIMKit/RongIMKit.h>

/********************** app环境 ****************************/
#pragma mark - app环境，isTrueEnvironment 0开发 1发布(已在macros上设置值)
#define kServerHost         [NetConfigure getCurrentNetwork]
#define kH5HostURL          [NetConfigure getCurrentH5BaseURLString]

// 获取实际的一个状态[app是否处于审核状态]
#define GetIsAppReviewing ([[[NSUserDefaults standardUserDefaults] objectForKey:kIsAppReviewingKey] boolValue])

/********************** 常用宏 ****************************/
#pragma mark - 常用宏
/// 判断无网络情况networkReachabilityStatus：-1未知网络 0连不上网络 1xG网络 2WiFi网络
#define kNetworkStatus [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]
/// 当前版本号
#define GetCurrentVersion ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"])
/// 当前build号
#define GetCurrentBuild [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
/// 当前app名称
#define GetAppName ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"])
/// 当前app delegate
#define GetAPPDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

/// 获取queue
#define GetMainQueue dispatch_get_main_queue()
#define GetGlobalQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

/// block self
#define kSelfWeak __weak typeof(self) weakSelf = self
#define kSelfStrong __strong __typeof__(weakSelf) strongSelf = weakSelf

// url
#define kURLWithString(str)  [NSURL URLWithString:str]
#define kGetUserDefaults(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define kUserDefaults(key, value) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key]
#define kSynchronize [[NSUserDefaults standardUserDefaults] synchronize]
#define kRemoveOUserDefaults(key) [[NSUserDefaults standardUserDefaults] removeObjectForKey:key]
// iOS6-iOS9判断
#define ISIOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define ISIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define ISIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define ISIOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

// 判断是否安装某个应用
#define kInStallWechat [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]]
#define kInStallAlipay [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]]
// Height/Width
#define kScreenWidth    [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight   [[UIScreen mainScreen] bounds].size.height
#define kBodyHeight     (kScreenHeight - 44 - 20)
#define kMiddleHeight   (kBodyHeight - 49)

#define kTabbarHeight       49
#define kSearchBarHeight    45
#define kStatusBarHeight    20
#define kNavigationHeight   44
#define ScreenMutiple (iPhone6?1.171875:(iPhone6plus?1.29375:1))

/// System判断
#define ISiPod      [[[UIDevice currentDevice] model] isEqual:@"iPod touch"]
#define ISiPhone    [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define ISiPad      [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define ISiPhone4   ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define ISiPhone5   ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define ISiPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)) : NO)
#define ISiPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#else
#define DLog(...)
#define NSLog(...) {}
#endif

#pragma mark - DeviceInfo
#define kPhoneNumber        @"4008326838"
#define kUserName_Password  @"com.hxf.GoodHappiness.usernamepassword"
#define kUserName           @"com.hxf.GoodHappiness.username"
#define kPassword           @"com.hxf.GoodHappiness.password"
#define kDeviceIdentifier   [[NSUserDefaults standardUserDefaults] objectForKey:@"kDeviceIdentifier"]
#define kDeviceId           [UUID getUUID]
#define kResolution         [NSString stringWithFormat:@"%@*%@",kIntToStr(kScreenWidth), kIntToStr(kScreenHeight)]
#define kVersion            [[UIDevice currentDevice] systemVersion]
#define kSid                [[NSUserDefaults standardUserDefaults] objectForKey:@"kSid"]
#define kUid                [[NSUserDefaults standardUserDefaults] objectForKey:@"kUid"]
#define kPushToken          [[NSUserDefaults standardUserDefaults] objectForKey:@"kPushToken"]
#define kChatToken          [[NSUserDefaults standardUserDefaults] objectForKey:@"kChatToken"]
#define kCarNum             [[NSUserDefaults standardUserDefaults] objectForKey:@"kCarNum"]
#define kTaBarIndex         [[NSUserDefaults standardUserDefaults] objectForKey:@"kTaBarIndex"]
#define kNetworkType        [[NSUserDefaults standardUserDefaults] objectForKey:@"kNetworkType"]
//////////////用于三方手机绑定
//#define kThirdToken   [[NSUserDefaults standardUserDefaults] objectForKey:@"acessToken"]
#define kThirdopenId  [[NSUserDefaults standardUserDefaults] objectForKey:@"openId"]

#pragma mark - CommonChange
#define kIntToStr(intValue) ([NSString stringWithFormat:@"%@", @(intValue)])
#define kFloatToStr(floatValue) ([NSString stringWithFormat:@"%.2f", floatValue])
#define kNumberToStr(NumberValue) ([NSString stringWithFormat:@"%@", NumberValue])
#define kUint64ToStr(uint64) [@(uint64) stringValue]
#define kStrToInt(str) [str integerValue]
#define kStrToDouble(str) [str doubleValue]

#pragma mark - CommonImages

#pragma mark - CommentData

#define IQKeyboardDistanceFromTextField 10


#pragma mark -   weakify( x ) && strongify( x )
/// block self
#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif
