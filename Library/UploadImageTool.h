//
//  UploadImageTool.h
//  GoodHappiness
//
//  Created by chaolong on 16/4/18.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QiniuSDK.h>

@interface UploadImageTool : NSObject

@property (copy, nonatomic) void (^singleSuccessBlock)(NSDictionary *resp);
@property (copy, nonatomic) void (^singleFailureBlock)();
@property (copy, nonatomic) void (^progressBlock)(NSString *key, float percent);

+ (instancetype)sharedInstance;
- (void)uploadData:(id)data progress:(QNUpProgressHandler)progress success:(void (^)(NSDictionary *resp))success failure:(void (^)())failure;
/**
 * 批量上传七牛文件方法
 * @param dataArray 上传数据数组
 * @param progress  进度block totalCount文件总数 totalProgress整体上传进度 currentIndex当前上传文件 currenProgress当前文件上传进度
 * @param success   成功回调
 * @param failure   失败回调
 */
- (void)uploadDatas:(NSArray *)dataArray progress:(void (^)(NSInteger totalCount, CGFloat totalProgress, NSInteger currentIndex, CGFloat currenProgress))progress success:(void (^)(NSArray *hashArray))success failure:(void (^)())failure;

@end
