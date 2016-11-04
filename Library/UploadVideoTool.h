//
//  UploadVideoTool.h
//  GoodHappiness
//
//  Created by chaolong on 16/9/20.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadVideoTool : NSObject

/**
 *  method Comperssion Video  压缩视频的方法, 该方法将压缩过的视频保存到沙河文件, 如果压缩过的视频不需要再进行保留, 可调用 removeCompressedVideoFromDocuments 方法, 将其删除即可
 *  @param filePath        SourceVideoURL  被压缩视频的URL
 *  @param compressionType 压缩可选类型
 
 AVAssetExportPresetLowQuality
 AVAssetExportPresetMediumQuality
 AVAssetExportPresetHighestQuality
 AVAssetExportPreset640x480
 AVAssetExportPreset960x540
 AVAssetExportPreset1280x720
 AVAssetExportPreset1920x1080
 AVAssetExportPreset3840x2160
 *
 *  @return 返回压缩后的视频路径
 */
+ (void)compressedVideoOtherMethodWithFilePath:(id)filePath compressionType:(NSString *)compressionType compressionResultPath:(void (^)(NSString *resultPath,float memorySize))resultPathBlock;
// 获取文件路径
+ (NSString *)getFilePathWithIsCompression:(BOOL)isCompression;
/**
 * 获取视频大小
 * @param filePath 文件路径url或string
 */
+ (float)countVideoTotalMemorySizeWithFilePath:(id)filePath;

/**
 *  清除沙盒文件中, 压缩后的视频所有
 */
+ (void)removeCompressedVideoFromDocuments;

@end
