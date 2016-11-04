//
//  UploadImageTool.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/18.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "UploadImageTool.h"

@implementation UploadImageTool

+ (instancetype)sharedInstance {
    static UploadImageTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UploadImageTool alloc] init];
    });
    return sharedInstance;
}

- (void)uploadData:(id)data progress:(QNUpProgressHandler)progress success:(void (^) (NSDictionary *url))success failure:(void (^)())failure {
    [UserModel getPushImageToQiniuWithNetworkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        if (response.code == 0) {
            UserModel *userModel = (UserModel *)response.data;
            NSData *tempData = [data isKindOfClass:[UIImage class]] ? UIImageJPEGRepresentation(data, 0.6) : data;
            if (!tempData) {
                if (failure) {
                    failure();
                }
                return;
            }
            QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:progress params:nil checkCrc:NO cancellationSignal:nil];
            QNUploadManager *uploadManager = [[QNUploadManager alloc] init];
            [uploadManager putData:tempData key:nil token:userModel.uploadToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                if (info.statusCode == 200 && resp) {
                    if (success) {
                        success(resp);
                    }
                } else {
                    if (failure) {
                        failure();
                    }
                }
            } option:opt];
        } else {
                if (failure) {
                    failure();
                }
        }
    }];
}

/**
 * 批量上传七牛文件方法
 * @param dataArray 上传数据数组
 * @param progress  进度block totalCount文件总数 totalProgress整体上传进度 currentIndex当前上传文件 currenProgress当前文件上传进度
 * @param success   成功回调
 * @param failure   失败回调
 */
- (void)uploadDatas:(NSArray *)dataArray progress:(void (^)(NSInteger totalCount, CGFloat totalProgress, NSInteger currentIndex, CGFloat currenProgress))progress success:(void (^)(NSArray *hashArray))success failure:(void (^)())failure {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    __block float totalProgress = 0.0f;
    __block float partProgress = 1.0f / [dataArray count];
    __block NSUInteger currentIndex = 0;
    
    UploadImageTool *uploadHelper = [UploadImageTool sharedInstance];
    __weak typeof(uploadHelper) weakHelper = uploadHelper;
    
    uploadHelper.singleFailureBlock = ^() {
        failure();
        return;
    };
    uploadHelper.singleSuccessBlock  = ^(NSDictionary *resp) {
        [array addObject:resp[@"data"][@"hash"]];
        totalProgress += partProgress;
        currentIndex++;
        if ([array count] == [dataArray count]) {
            success([array copy]);
            return;
        } else {
            [self uploadData:dataArray[currentIndex] progress:weakHelper.progressBlock success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
        }
    };
    uploadHelper.progressBlock  = ^(NSString *key, float percent) {
        progress(dataArray.count, totalProgress, currentIndex, percent);
    };
    
    [self uploadData:dataArray[0] progress:uploadHelper.progressBlock success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
}

@end
