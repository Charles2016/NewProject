//
//  BaseModel.m
//  BaseDemo
//
//  Created by chaolong on 16/8/3.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "BaseModel.h"
#import "HttpClient.h"
#import "StatusModel.h"
#import "DataCache.h"

#import "RSA.h"
#import <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData (1024 * 8)

@implementation BaseModel

+ (void)initialize {
    [HttpClient startWithURL:kServerHost];
    [HttpClient sharedInstance].responseType = ResponseJSON;
    [HttpClient sharedInstance].requestType = RequestJSON;
}

#pragma mark - DB

+ (LKDBHelper *)getUsingLKDBHelper {
    static LKDBHelper* db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *sqlitePath = [BaseModel downloadPath];
        NSString *dbpath = [sqlitePath stringByAppendingPathComponent:[NSString stringWithFormat:@"CarMango.db"]];
        db = [[LKDBHelper alloc]initWithDBPath:dbpath];
    });
    return db;
}

+ (NSString *)downloadPath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"CarMango"];
    DLog(@"downloadPath:%@",downloadPath);
    return downloadPath;
}

+ (NSString *)getCreateTableSQL {
    LKModelInfos *infos = [self getModelInfos];
    NSString *primaryKey = [self getPrimaryKey];
    NSMutableString *tablePars = [NSMutableString string];
    for (int i = 0; i < infos.count; i++) {
        if(i > 0) {
            [tablePars appendString:@","];
        }
        LKDBProperty* property =  [infos objectWithIndex:i];
        [self columnAttributeWithProperty:property];
        
        [tablePars appendFormat:@"%@ %@", property.sqlColumnName, property.sqlColumnType];
        
        if([property.sqlColumnType isEqualToString:LKSQL_Type_Text]) {
            if(property.length > 0) {
                [tablePars appendFormat:@"(%ld)", (long)property.length];
            }
        }
        if(property.isNotNull) {
            [tablePars appendFormat:@" %@", LKSQL_Attribute_NotNull];
        }
        if(property.isUnique) {
            [tablePars appendFormat:@" %@", LKSQL_Attribute_Unique];
        }
        if(property.checkValue) {
            [tablePars appendFormat:@" %@(%@)", LKSQL_Attribute_Check, property.checkValue];
        }
        if(property.defaultValue) {
            [tablePars appendFormat:@" %@ %@", LKSQL_Attribute_Default, property.defaultValue];
        }
        if(primaryKey && [property.sqlColumnName isEqualToString:primaryKey]) {
            [tablePars appendFormat:@" %@", LKSQL_Attribute_PrimaryKey];
        }
    }
    NSString* createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)", [self getTableName], tablePars];
    return createTableSQL;
}

+ (void)releaseLKDBHelp {
    
}

#pragma mark - 映射
/// 映射方法 字典对象
+ (StatusModel *)statusModelFromJSONObject:(id)object {
    return [self statusModelFromJSONObject:object class:self];
}

/// 映射方法 字典对象，data对应的是哪个类
+ (StatusModel *)statusModelFromJSONObject:(id)object class:(Class)class {
    StatusModel *statusModel = [StatusModel mj_objectWithKeyValues:object];
    id returnObject = nil;
    id rs = object[@"Data"];
    if (rs) {
        if ([rs isKindOfClass:[NSDictionary class]]) {
            returnObject = [class mj_objectWithKeyValues:rs];
        } else if ([rs isKindOfClass:[NSArray class]]) {
            if ([[rs firstObject] isKindOfClass:[NSString class]]) {
                returnObject = rs;
            } else {
                returnObject = [class mj_objectArrayWithKeyValuesArray:rs];
            }
        } else if ([rs isKindOfClass:[NSString class]]) {
            returnObject = rs;
        } else if ([rs isKindOfClass:[NSNull class]]) {
            returnObject = nil;
        }
    }
    statusModel.Data = returnObject;
    return statusModel;
}

#pragma mark - 服务器返回处理
+ (id)getObjectFromReponseObject:(id)responseObject path:(NSString *)path {
    NSDictionary *value = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]] &&
        kHttpClient.responseType == ResponseJSON) {
        value = responseObject;
    } else {
        NSString *responseString = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        } else {
            responseString = responseObject;
        }
        /**
         *  处理服务器返回数据
         */
        DLog(@"responseString:%@", responseString);
        NSError *decodeError = nil;
        NSData *decodeData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (kHttpClient.responseType == ResponseJSON) {
            value = [NSJSONSerialization JSONObjectWithData:decodeData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&decodeError];
        }
    }
#ifndef __OPTIMIZE__
    NSLog (@"\n响应:---------------->%@\n%@", path, value);
#endif
    return value ?: @{};
}

#pragma mark - dataTaskMethod
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
                                 success:(NetResponseBlock)success {
    return [self netDataTaskMethod:method
                              path:path
                            params:params
                        networkHUD:NetworkHUDBackground
                            target:nil
                    uploadProgress:nil
                  downloadProgress:nil
                         cacheTime:0
                           success:success];
}

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
                                 success:(NetResponseBlock)success {
    return [self netDataTaskMethod:method
                              path:path
                            params:params
                        networkHUD:networkHUD
                            target:target
                    uploadProgress:nil
                  downloadProgress:nil
                         cacheTime:0
                           success:success];
}

/**
 * 请求带缓存和HUD状态
 * @param method     请求模式
 * @param path       HTTP路径
 * @param params     请求参数
 * @param networkHUD HUD状态，如需不锁导航栏必须传target
 * @param target     目标UIViewController，用于addNet:,返回按钮按下会断开网络请求
 * @param time       缓存失效时间time==-1.同时取数据库/网络 time==0.不取数据库直接取网络  time>1  缓存没有失效取数据库，否则取网络
 * @param dbSuccess  读取缓存的Block，传nil代表不缓存
 * @param success    完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)dataTaskMethod:(HTTPMethod)method
                                    path:(NSString *)path
                                  params:(id)params
                              networkHUD:(NetworkHUD)networkHUD
                                  target:(id)target
                               cacheTime:(NSInteger)cacheTime
                                 success:(NetResponseBlock)success {
    return [self dataTaskMethod:method
                           path:path
                         params:params
                     networkHUD:networkHUD
                         target:target
                 uploadProgress:nil
               downloadProgress:nil
                      cacheTime:cacheTime
                        success:success];
}

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
 * @param dbSuccess        读取缓存的Block，传nil代表不缓存
 * @param success          完成Block
 * @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)dataTaskMethod:(HTTPMethod)method
                                    path:(NSString *)path
                                  params:(id)params
                              networkHUD:(NetworkHUD)networkHUD
                                  target:(id)target
                          uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                        downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                               cacheTime:(NSInteger)cacheTime
                                 success:(NetResponseBlock)success {
    return [self netDataTaskMethod:method
                              path:path
                            params:params
                        networkHUD:networkHUD
                            target:target
                    uploadProgress:uploadProgress
                  downloadProgress:downloadProgress
                         cacheTime:cacheTime
                           success:success];
    
    /*__block NSURLSessionDataTask *dataTask;
    if (success && (cacheTime == -1 || cacheTime > 0)) {
        [DataCache queryWithPath:path parameter:params result:^(DataCache *data) {
            BOOL getNet = YES;
            DataCache *cache = data;
            if (cache) {
                NSDate *date = [NSDate dateWithTimeInterval:-cacheTime sinceDate:[NSDate date]];
                if (cacheTime == -1 || (cache.updateDate && [cache.updateDate compare:date] == NSOrderedDescending)) {
                    id JSON = [self transformMethodByDictionaryOrJsonStr:cache.content];
                    success([self statusModelFromJSONObject:JSON]);
                    getNet = NO;
                }
            }
            if (cacheTime == -1) {
                getNet = NO;
            }
            //根据需要是否调网络
            if (getNet) {
                dataTask = [self netDataTaskMethod:method
                                              path:path
                                            params:params
                                        networkHUD:networkHUD
                                            target:target
                                    uploadProgress:uploadProgress
                                  downloadProgress:downloadProgress
                                         cacheTime:cacheTime
                                           success:success];
            }
        }];
    }
    if(cacheTime == -1 || cacheTime == 0 || !success){
        dataTask = [self netDataTaskMethod:method
                                      path:path
                                    params:params
                                networkHUD:networkHUD
                                    target:target
                            uploadProgress:uploadProgress
                          downloadProgress:downloadProgress
                                 cacheTime:cacheTime
                                   success:success];
    }
    return dataTask;*/
}

//内部方法禁止调用
+ (NSURLSessionDataTask *)netDataTaskMethod:(HTTPMethod)method
                                       path:(NSString *)path
                                     params:(id)params
                                 networkHUD:(NetworkHUD)networkHUD
                                     target:(id)target
                             uploadProgress:(nullable void(^)(NSProgress *uploadProgress))uploadProgress
                           downloadProgress:(nullable void(^)(NSProgress *downloadProgress))downloadProgress
                                  cacheTime:(NSInteger)cacheTime
                                    success:(NetResponseBlock)success {
    /*[self startHUD:networkHUD target:target];*/
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:params];
    // 加密处理
    mutableDic = [NSMutableDictionary dictionaryWithDictionary:[self encryptWithParams:mutableDic]];
    // 请求头需要地理经纬度参数判断
    BOOL isNeedLocation = NO;
    if ([path rangeOfString:@"Goods/QueryFranchiseeInfoByLongitude"].length) {
        isNeedLocation = YES;
    }
    // 请求头设置
    [self setHttpHeaderValuesIsNeedLocation:isNeedLocation];
    // 排序添加sign参数处理
    // params = [self getSortParamsWithDic:mutableDic];
    if (cacheTime == -1 || cacheTime > 0) {
        NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
        [DataCache queryWithPath:path parameter:paramsDic result:^(DataCache *data) {
            DataCache *cache = data;
            if (cache) {
                NSDate *date = [NSDate dateWithTimeInterval:-cacheTime sinceDate:[NSDate date]];
                if (cacheTime == -1 || (cache.updateDate && [cache.updateDate compare:date] == NSOrderedDescending)) {
                    id JSON = [self transformMethodByDictionaryOrJsonStr:cache.content];
                    StatusModel *model = [self statusModelFromJSONObject:JSON];
                    model.isFromDB = YES;
                    success(model);
                }
            }
        }];
    }

    // 请求方法设置
    NSString *methodStr;
    switch (method) {
        case HTTPMethodGET:
            methodStr = @"GET";
            break;
        case HTTPMethodPOST:
            methodStr = @"POST";
            break;
        case HTTPMethodPUT:
            methodStr = @"PUT";
            break;
        case HTTPMethodDELETE:
            methodStr = @"DELETE";
            break;
        case HTTPMethodHEAD:
            methodStr = @"HEAD";
            break;
        case HTTPMethodPATCH:
            methodStr = @"PATCH";
            break;
    }
#ifndef __OPTIMIZE__
    NSString *jsonString = @"";
    if (params) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    }
    NSLog (@"\n请求:---------------->%@:%@%@\n%@\n%@\n", methodStr, kServerHost, path, jsonString ,kHttpClient.requestSerializer.HTTPRequestHeaders);
#endif
    
    NSURLSessionDataTask *dataTask = [kHttpClient dataTaskWithHTTPMethod:methodStr
                                                               URLString:path
                                                              parameters:params
                                                          uploadProgress:uploadProgress
                                                        downloadProgress:downloadProgress
                                                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                     id JSON = [self getObjectFromReponseObject:responseObject path:path];
                                                                     StatusModel *model;
                                                                     if (JSON) {
                                                                         model = [[self class] statusModelFromJSONObject:JSON];
                                                                     } else {
                                                                         model = [[StatusModel alloc] initWithCode:-100 msg:NSLocalizedString (@"json_error", nil)];
                                                                     }
                                                                     if ([self isCacheStatusModel:model] && cacheTime != 0) {
                                                                         NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
                                                                         [paramsDic removeObjectForKey:@"sign"];
                                                                         [paramsDic removeObjectForKey:@"time"];
                                                                        [DataCache cacheWithPath:path
                                                                                       parameter:paramsDic
                                                                                         content:JSON];
                                                                     }
                                                                     /*[self handleResponse:model networkHUD:networkHUD];*/
                                                                     if(success) {
                                                                         success(model);
                                                                     }
                                                                 }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
#ifndef __OPTIMIZE__
                                                                     DLog (@"\n响应：--------------------->%@%@\n%@", kServerHost, path, error.localizedDescription);
#endif
                                                                     StatusModel *model = [[StatusModel alloc] initWithError:error];
                                                                     /*[self handleResponse:model networkHUD:networkHUD];*/
                                                                     if(success) {
                                                                         success(model);
                                                                     }
                                      }];
    
    [dataTask resume];
    if (target && [target respondsToSelector:@selector (addNet:)]) {
        [target performSelector:@selector (addNet:) withObject:dataTask];
    }
    return dataTask;
}

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
                             success:(NetResponseBlock)success {
    path = [NSString stringWithFormat:@"%@/%@",kServerHost, path];
//    [self startHUD:networkHUD target:target];
     kHttpClient.requestType = RequestOhter;
     kHttpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", nil];
    // 加密处理
    params = [self encryptWithParams:params];
    // 设置请求头部
    [self setHttpHeaderValuesIsNeedLocation:NO];
    
#ifndef __OPTIMIZE__
    NSString *jsonString = @"";
    if (params) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    }
    NSLog (@"\n上传文件：--------------------->%@\n%@\n%@\n", path, jsonString,kHttpClient.requestSerializer.HTTPRequestHeaders);
#endif
    
    void (^bodyBlock)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        [files enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *uploadInfo = obj;
            [formData appendPartWithFileData:uploadInfo[@"data"]
                                        name:uploadInfo[@"name"]
                                    fileName:uploadInfo[@"fileName"]
                                    mimeType:uploadInfo[@"mimeType"]];
        }];
    };
    
    NSURLSessionUploadTask *uploadTask = (NSURLSessionUploadTask *)[kHttpClient POST:path
                                                                          parameters:params
                                                           constructingBodyWithBlock:bodyBlock
                                                                            progress:^(NSProgress * _Nonnull uploadProgress) {
                                                                                
                                                                            }
                                                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                 id JSON = [self getObjectFromReponseObject:responseObject path:path];
                                                                                 StatusModel *model;
                                                                                 if (JSON) {
                                                                                     model = [[self class] statusModelFromJSONObject:JSON];
                                                                                 } else {
                                                                                     model = [[StatusModel alloc] initWithCode:-100 msg:NSLocalizedString (@"json_error", nil)];
                                                                                 }
                                                                                 /*[self checkResponseCode:model];
                                                                                  [self handleResponse:model networkHUD:networkHUD];*/
                                                                                 if(success) {
                                                                                     success(model);
                                                                                 }
                                                                             }
                                                                             failure:^(NSURLSessionDataTask *task, NSError *error) {
#ifndef __OPTIMIZE__
                                                                                 DLog (@"\n响应：--------------------->%@\n%@", path, error.localizedDescription);
#endif
                                                                                 StatusModel *model = [[StatusModel alloc] initWithError:error];
                                                                                 /*[self handleResponse:model networkHUD:networkHUD];*/
                                                                                 if(success) {
                                                                                     success(model);
                                                                                 }
                                                                             }];
    [uploadTask resume];
    return uploadTask;
}

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
                                      success:(NetResponseBlock)success {
    path = [NSString stringWithFormat:@"%@%@",kServerHost, path];
    //    [self startHUD:networkHUD target:target];
    kHttpClient.requestType = RequestOhter;
    kHttpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", nil];
    // 加密处理
    params = [self encryptWithParams:params];
    // 设置请求头部
    [self setHttpHeaderValuesIsNeedLocation:NO];
    
#ifndef __OPTIMIZE__
    NSString *jsonString = @"";
    if (params) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    }
    NSLog (@"\n上传文件：--------------------->%@\n%@\n%@\n", path, jsonString,kHttpClient.requestSerializer.HTTPRequestHeaders);
#endif
    
    void (^bodyBlock)(id<AFMultipartFormData> formData) = ^(id<AFMultipartFormData> formData) {
        if(image){
            NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat =@"yyyyMMddHHmmss";
            NSString *dateStr = [formatter stringFromDate:[NSDate date]];
            NSString *imageKey = [NSString stringWithFormat:@"%@.jpg", dateStr];
            [formData appendPartWithFileData:imageData name:imageKey fileName:@"image.jpg" mimeType:@"image/png,image/jpeg"];
        }
    };
    
    NSURLSessionUploadTask *uploadTask = (NSURLSessionUploadTask *)[kHttpClient POST:path
                                                                          parameters:params
                                                           constructingBodyWithBlock:bodyBlock
                                                                            progress:^(NSProgress * _Nonnull uploadProgress) {
                                                                                
                                                                            }
                                                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                 id JSON = [self getObjectFromReponseObject:responseObject path:path];
                                                                                 StatusModel *model;
                                                                                 if (JSON) {
                                                                                     model = [[self class] statusModelFromJSONObject:JSON];
                                                                                 } else {
                                                                                     model = [[StatusModel alloc] initWithCode:-100 msg:NSLocalizedString (@"json_error", nil)];
                                                                                 }
                                                                                 /*[self checkResponseCode:model];
                                                                                  [self handleResponse:model networkHUD:networkHUD];*/
                                                                                 if(success) {
                                                                                     success(model);
                                                                                 }
                                                                             }
                                                                             failure:^(NSURLSessionDataTask *task, NSError *error) {
#ifndef __OPTIMIZE__
                                                                                 DLog (@"\n响应：--------------------->%@\n%@", path, error.localizedDescription);
#endif
                                                                                 StatusModel *model = [[StatusModel alloc] initWithError:error];
                                                                                 /*[self handleResponse:model networkHUD:networkHUD];*/
                                                                                 if(success) {
                                                                                     success(model);
                                                                                 }
                                                                             }];
    [uploadTask resume];
    return uploadTask;
}

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
                     success:(NetResponseBlock)success {
    // [self startHUD:networkHUD target:target];
    kHttpClient.requestType = RequestOhter;
    kHttpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", nil];
    // 加密处理
    params = [self encryptWithParams:params];
    // 设置请求头部
    [self setHttpHeaderValuesIsNeedLocation:NO];
    // 准备保存结果的数组，元素个数与上传的图片个数相同，先用 NSNull 占位
    NSMutableArray* result = [NSMutableArray array];
    for (NSInteger i = 0; i < images.count; i++) {
        [result addObject:[NSNull null]];
    }
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger i = 0; i < images.count; i++) {
        dispatch_group_enter(group);
        [[self class] uploadImageWithPath:path image:images[i] params:params networkHUD:networkHUD target:target success:^(StatusModel *response) {
            if (response.Success) {
                DLog(@"第 %d 张图片上传成功: %@", (int)i + 1, response.Data);
                @synchronized (result) { // NSMutableArray 是线程不安全的，所以加个同步锁
                    result[i] = response.Data;
                }
                dispatch_group_leave(group);
            } else {
                DLog(@"第 %d 张图片上传失败: %@", (int)i + 1, response.Data);
                dispatch_group_leave(group);
            }
        }];
    }
    //所有的都上传完成
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        BOOL uploadFail = NO;
        for(id value in result){
            if([value isEqual:[NSNull null]]){
                uploadFail = YES;
                break;
            }
        }
        StatusModel *model = [[StatusModel alloc]init];
        if(uploadFail == YES){
            //没有所有的图片都上传成功
            model.Msg = @"图片上传失败";
            model.Success = 0;
        }else{
            //成功上传所有的图片
            model.Msg = @"图片上传成功";
            model.Success = 1;
            model.Data = result;
            
        }
        success(model);
    });
}

#pragma mark - 添加请求头处理
// 请求头设置，当有设置的dic时则直接使用，若无则使用默认的字典作为请求头
+ (void)setHttpHeaderValuesIsNeedLocation:(BOOL)isNeedLocation {
    // 请求头设置
    CreateParamsDic;
    DicValueSet(kLIV, @"LIV");
    DicValueSet(@"yyyy-MM-dd HH:mm:ss", @"DateFormat");
    DicValueSet(kDeviceId, @"IMEI");
    if (isNeedLocation) {
        NSString *latitudeStr = [NSString stringWithFormat:@"%lf", [LocationManager sharedManager].currentLocation.latitude];
        NSString *longitudeStr = [NSString stringWithFormat:@"%lf", [LocationManager sharedManager].currentLocation.longitude];
        DicValueSet(latitudeStr, @"Latitude");
        DicValueSet(longitudeStr, @"Longitude");
    }
    for (NSString *httpHeaderField in ParamsDic.allKeys) {
        id value = ParamsDic[httpHeaderField];
        [kHttpClient.requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
    }
}


#pragma mark - 排序添加time和sign参数处理
+ (NSDictionary *)getSortParamsWithDic:(NSMutableDictionary *)params {
    NSString *timeStr = [NSString stringWithFormat:@"%.lf", [NSDate date].timeIntervalSince1970];
    [params setValue:timeStr forKey:@"time"];
    NSMutableString *signStr = [NSMutableString string];
    NSArray *keys = [params allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *key in sortedArray) {
        [signStr appendString:key];
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [NSString stringWithFormat:@"%@", value];
        }
        [signStr appendString:value];
    }
    [signStr appendString:kAPPSecretKey];
//    signStr = [[signStr sha1String] copy];
    signStr = [[signStr uppercaseString] copy];
    [params setValue:signStr forKey:@"sign"];
    return params;
}

#pragma mark - 加密参数处理
+ (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    static NSSet *encryptWithMD5_RSAFields = nil;
    static NSSet *encryptWithRSAFields = nil;
    static NSSet *encryptWithMD5Only = nil;
    static NSSet *encryptWithSHA1 = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        /*// 需要MD5+RSA加密的字段
        encryptWithMD5_RSAFields = [NSSet setWithObjects:@"password", @"oldPassword",
        @"payPwd", nil];
        // 只需要RSA加密的字段
        encryptWithRSAFields = [NSSet
        setWithObjects:@"phone",@"userId",@"merchantId",@"activityId",@"psaKey",@"activityUserId",
        @"account", @"productId", @"amount" ,
        @"productNo",@"loginId",@"reportId",@"accountId",@"referrerId",@"favourableId"
        ,nil];*/
        // 只需要SHA1加密字段
        encryptWithSHA1 = [NSSet setWithObjects:@"password", nil];
    });
    
    NSArray *allKeys = dic.allKeys;
    for (NSString *key in allKeys) {
        if ([encryptWithMD5_RSAFields containsObject:key]) {
            NSString *oldObject = [dic objectForKey:key];
            if (oldObject) {
                if ([oldObject isKindOfClass:[NSNumber class]]) {
                    oldObject = [NSString stringWithFormat:@"%@", oldObject];
                }
                NSString *rsaString = [[RSA shareInstance] encryptWithString:[[self class] getMd5_32Bit_String:oldObject uppercase:YES]];
                [dic setValue:rsaString forKey:key];
            }
        } else if ([encryptWithRSAFields containsObject:key]) {
            NSString *oldObject = [dic objectForKey:key];
            if (oldObject) {
                if ([oldObject isKindOfClass:[NSNumber class]]) {
                    oldObject = [NSString stringWithFormat:@"%@", oldObject];
                }
                NSString *rsaString = [[RSA shareInstance] encryptWithString:oldObject];
                [dic setValue:rsaString forKey:key];
            }
        } else if ([encryptWithMD5Only containsObject:key]) {
            NSString *oldObject = [dic objectForKey:key];
            if (oldObject) {
                if ([oldObject isKindOfClass:[NSNumber class]]) {
                    oldObject = [NSString stringWithFormat:@"%@", oldObject];
                }
                NSString *rsaString = [[self class] getMd5_32Bit_String:oldObject uppercase:YES];
                [dic setValue:rsaString forKey:key];
            }
        } else if ([encryptWithSHA1 containsObject:key]) {
//            NSString *oldObject = [dic objectForKey:key];
//            NSString *rsaString = [[oldObject sha1String] uppercaseString];
//            [dic setValue:rsaString forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:dic];
}

#pragma mark - 是否缓存，子类可以根据 flag返回对应值
+ (BOOL)isCacheStatusModel:(StatusModel*)model {
    if (model.Success == 1) {
        return YES;
    }
    return NO;
}

#pragma mark - md5 32位加密
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase {
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return uppercase ? [result uppercaseString] : result;
}

#pragma mark - md5 16位加密
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString uppercase:(BOOL)uppercase {
    // 提取32位MD5散列的中间16位
    NSString *md5_32Bit_String=[self getMd5_32Bit_String:srcString uppercase:uppercase];
    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8]; // 即9～25位
    return result;
}

#pragma mark- 文件MD5
+ (NSString *)fileMD5:(NSString *)path {
    return (__bridge_transfer NSString *)fileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef fileMD5HashCreateWithPath(CFStringRef filePath, size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0)
        {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
done:
    if (readStream) {
        
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        
        CFRelease(fileURL);
    }
    return result;
}

#pragma mark - 字典转jsonStr or jsonStr转字典
/// 传入jsonStr返回字典，字典返回jsonStr
+ (id)transformMethodByDictionaryOrJsonStr:(id)target {
    if (!target) {
        return target;
    }
    id transformTarget;
    NSError *err;
    if ([target isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:target options:NSJSONWritingPrettyPrinted error:&err];
        transformTarget = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        NSData *jsonData = [target dataUsingEncoding:NSUTF8StringEncoding];
        transformTarget = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&err];
    }
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return transformTarget;
}

@end
