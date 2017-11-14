//
//  BaseModel.h
//  BaseDemo
//
//  Created by chaolong on 16/8/3.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDBHelper.h"

// 方便写接口
#define ParamsDic dic
#define CreateParamsDic NSMutableDictionary *ParamsDic = [NSMutableDictionary dictionary]
#define DicObjectSet(obj,key) [ParamsDic setObject:obj forKey:key]
#define DicValueSet(value,key) [ParamsDic setValue:value forKey:key]

typedef NS_ENUM(NSUInteger, NetworkHUD) {
    /// 不锁屏，不提示
    NetworkHUDBackground = 0,
    /// 不锁屏，只要msg不为空就提示
    NetworkHUDMsg = 1,
    /// 不锁屏，提示错误信息
    NetworkHUDError = 2,
    /// 锁屏
    NetworkHUDLockScreen = 3,
    /// 锁屏，只要msg不为空就提示
    NetworkHUDLockScreenAndMsg = 4,
    /// 锁屏，提示错误信息
    NetworkHUDLockScreenAndError = 5,
    /// 锁屏, 但是导航栏可以操作
    NetworkHUDLockScreenButNav = 6,
    /// 锁屏, 但是导航栏可以操作, 只要msg不为空就提示
    NetworkHUDLockScreenButNavWithMsg = 7,
    /// 锁屏, 但是导航栏可以操作, 提示错误信息
    NetworkHUDLockScreenButNavWithError = 8
};

typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodGET,
    HTTPMethodPOST,
    HTTPMethodPUT,
    HTTPMethodDELETE,
    HTTPMethodHEAD,
    HTTPMethodPATCH
};

@class StatusModel;

/**
 * 网络请求回调
 * @param data StatusModel
 */
typedef void(^NetResponseBlock)(StatusModel *response);

@interface BaseModel : NSObject

#pragma mark - 数据库
///// 登录帐号的数据库
+ (LKDBHelper *)getUserLKDBHelper;
/// 默认的数据库 子类可以重写，默认已经登录用登录帐号数据库，没有则默认数据库
+ (LKDBHelper *)getUsingLKDBHelper;
/// 跟用户无关的数据库
+ (LKDBHelper *)getDefaultLKDBHelper;
/// 释放用户LKDB
+ (void)releaseLKDBHelp;

#pragma mark - 映射
/// 映射方法 字典对象
+ (StatusModel*)statusModelFromJSONObject:(id)object;
/// 映射方法 字典对象，data对应的是哪个类
+ (StatusModel*)statusModelFromJSONObject:(id)object class:(Class)aClass;

/**
 * 请求不带缓存和进度方法
 * @param method     请求模式
 * @param path       HTTP路径
 * @param params     请求参数
 * @param success    完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)dataTaskMethod:(HTTPMethod)method
                                    path:(NSString *)path
                                  params:(id)params
                                 success:(NetResponseBlock)success;

/**
 * 请求带HUD状态方法
 * @param method     请求模式
 * @param path       HTTP路径
 * @param params     请求参数
 * @param networkHUD HUD状态，如需不锁导航栏必须传target
 * @param target     目标UIViewController，用于addNet:,返回按钮按下会断开网络请求
 * @param success    完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)dataTaskMethod:(HTTPMethod)method
                                    path:(NSString *)path
                                  params:(id)params
                              networkHUD:(NetworkHUD)networkHUD
                                  target:(id)target
                                 success:(NetResponseBlock)success;

/**
 * 请求带缓存和HUD状态
 * @param method     请求模式
 * @param path       HTTP路径
 * @param params     请求参数
 * @param networkHUD HUD状态，如需不锁导航栏必须传target
 * @param target     目标UIViewController，用于addNet:,返回按钮按下会断开网络请求
 * @param cacheTime  缓存失效时间cacheTime==-1.同时取数据库/网络 cacheTime==0.不取数据库直接取网络  cacheTime>1  缓存没有失效取数据库，否则取网络
 * @param success    完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)dataTaskMethod:(HTTPMethod)method
                                    path:(NSString *)path
                                  params:(id)params
                              networkHUD:(NetworkHUD)networkHUD
                                  target:(id)target
                               cacheTime:(NSInteger)cacheTime
                                 success:(NetResponseBlock)success;
/**
 * 请求带缓存和HUD状态和进度方法
 * @param method           请求模式
 * @param path             HTTP路径
 * @param params           请求参数
 * @param networkHUD       HUD状态，如需不锁导航栏必须传target
 * @param target           目标UIViewController，用于addNet:,返回按钮按下会断开网络请求
 * @param uploadProgress   上传进度
 * @param downloadProgress 下载进度
 * @param cacheTime        缓存失效时间cacheTime==-1.同时取数据库/网络 cacheTime==0.不取数据库直接取网络  cacheTime>1  缓存没有失效取数据库，否则取网络
 * @param success          完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)dataTaskMethod:(HTTPMethod)method
                                    path:(NSString *)path
                                  params:(id)params
                              networkHUD:(NetworkHUD)networkHUD
                                  target:(id)target
                          uploadProgress:(void(^)(NSProgress *uploadProgress))uploadProgress
                        downloadProgress:(void(^)(NSProgress *downloadProgress))downloadProgress
                               cacheTime:(NSInteger)cacheTime
                                 success:(NetResponseBlock)success;

/**
 * post上传文件
 * @param path       HTTP路径
 * @param files      文件data
 * @param params     请求参数
 * @param networkHUD HUD状态，如需不锁导航栏必须传target
 * @param target     目标UIViewController，用于addNet:,返回按钮按下会断开网络请求
 * @param success    完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)updataFile:(NSString *)path
                               files:(NSArray *)files
                              params:(id)params
                          networkHUD:(NetworkHUD)networkHUD
                              target:(id)target
                             success:(NetResponseBlock)success;

/**
 * post上传单张图片
 * @param path       HTTP路径
 * @param image      图片
 * @param params     请求参数
 * @param networkHUD HUD状态，如需不锁导航栏必须传target
 * @param target     目标UIViewController，用于addNet:,返回按钮按下会断开网络请求
 * @param success    完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)uploadImageWithPath:(NSString *)path
                                        image:(UIImage *)image
                                       params:(id)params
                                   networkHUD:(NetworkHUD)networkHUD
                                       target:(id)target
                                      success:(NetResponseBlock)success;

/**
 * post上传多张图片
 * @param path       HTTP路径
 * @param images     图片数组
 * @param params     请求参数
 * @param networkHUD HUD状态，如需不锁导航栏必须传target
 * @param target     目标UIViewController，用于addNet:,返回按钮按下会断开网络请求
 * @param success    完成Block
 */
+ (void)uploadImagesWithPath:(NSString *)path
                      images:(NSArray *)images
                      params:(id)params
                  networkHUD:(NetworkHUD)networkHUD
                      target:(id)target
                     success:(NetResponseBlock)success;

/// 是否缓存，子类可以根据 flag返回对应值
+ (BOOL)isCacheStatusModel:(StatusModel*)model;

/// 32位 md5加密
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase;
/// 16位 md5加密
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase;
/// 获取文件MD5
+ (NSString *)fileMD5:(NSString *)path;

/// 传入jsonStr返回字典，字典返回jsonStr
+ (id)transformMethodByDictionaryOrJsonStr:(id)target;

@end
