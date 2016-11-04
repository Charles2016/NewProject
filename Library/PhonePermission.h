//
//  MicLocationAssistant.h
//  HKMember
//
//  Created by apple on 14-4-14.
//  Copyright (c) 2014年 mypuduo. All rights reserved.
//

#import <Foundation/Foundation.h>
//对应权限类型
typedef NS_ENUM(NSInteger, PermissionType) {
    PermissionPhotoType = 0,  //相册访问权限
    PermissionCamaratype,     //相机访问权限
    PermissionLocationType,   //定位使用权限
    PermissionMailType,       //通讯录访问权限
    PermissionMicrophoneType  //麦克风访问权限
};


@interface PhonePermission : NSObject

+ (id)sharedInstance;

/**
 *  统一处理(相册，照片，定位，通讯录，麦克风等)没有权限情况
 */
- (BOOL)checkAccessPermissions:(PermissionType)type;

@end
