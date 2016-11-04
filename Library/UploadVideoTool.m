//
//  UploadVideoTool.m
//  GoodHappiness
//
//  Created by chaolong on 16/9/20.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "UploadVideoTool.h"
#import <AVFoundation/AVFoundation.h>

#define CompressionVideoPaht [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Compression"]

@implementation UploadVideoTool

+ (void)compressedVideoOtherMethodWithFilePath:(id)filePath compressionType:(NSString *)compressionType compressionResultPath:(void (^)(NSString *resultPath,float memorySize))resultPathBlock; {
    NSData *data = [filePath isKindOfClass:[NSString class]] ? [NSData dataWithContentsOfFile:filePath] : [NSData dataWithContentsOfURL:filePath];
    CGFloat totalSize = (float)data.length / 1024 / 1024;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:filePath options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString *resultPath;
    // 所支持的压缩格式中是否有 所选的压缩格式
    if ([compatiblePresets containsObject:compressionType]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:compressionType];
        // 获取压缩后的文件路径
        resultPath = [self getFilePathWithIsCompression:YES];
        NSLog(@"压缩文件路径 resultPath = %@",resultPath);
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
             if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                 NSData *data = [NSData dataWithContentsOfFile:resultPath];
                 float memorySize = (float)data.length / 1024 / 1024;
                 NSLog(@"视频压缩前大小：%f 压缩后大小 %f", totalSize, memorySize);
                 resultPathBlock (resultPath, memorySize);
             } else {
                 NSLog(@"压缩失败");
             }
        }];
    } else {
        NSLog(@"不支持 %@ 格式的压缩", compressionType);
    }
}

+ (NSString *)getFilePathWithIsCompression:(BOOL)isCompression {
    //用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExists = [manager fileExistsAtPath:CompressionVideoPaht];
    if (!isExists) {
        [manager createDirectoryAtPath:CompressionVideoPaht withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"video_%@.%@", [formater stringFromDate:[NSDate date]], isCompression ? @"mp4" : @"mov"];
    return [CompressionVideoPaht stringByAppendingPathComponent:fileName];
}

+ (float)countVideoTotalMemorySizeWithFilePath:(id)filePath {
    NSData *data = [filePath isKindOfClass:[NSString class]] ? [NSData dataWithContentsOfFile:filePath] : [NSData dataWithContentsOfURL:filePath];
    CGFloat totalSize = (float)data.length / 1024 / 1024;
    return totalSize;
}

+ (void)removeCompressedVideoFromDocuments {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:CompressionVideoPaht]) {
        [[NSFileManager defaultManager] removeItemAtPath:CompressionVideoPaht error:nil];
    }
}

@end
