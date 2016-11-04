//
//  MicLocationAssistant.m
//  HKMember
//
//  Created by apple on 14-4-14.
//  Copyright (c) 2014年 mypuduo. All rights reserved.
//

#import "PhonePermission.h"
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVFoundation.h>

@implementation PhonePermission

+ (id)sharedInstance {
    static PhonePermission *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)isLocationServiceOn {
    return [CLLocationManager locationServicesEnabled];
}

- (BOOL)isCurrentAppLocatonServiceOn {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isLocationServiceDetermined {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusNotDetermined == status) {
        return NO;
    } else {
        return YES;
    }
    
}

- (BOOL)isCurrentAppALAssetsLibraryServiceOn {
    BOOL isServiceOn;
    if (ISIOS8) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        // 此处只应判断拒绝的情况，第一次未决定时返回YES，不做任何弹框，系统自己弹
        if (status == PHAuthorizationStatusDenied) {
            isServiceOn = NO;
        } else {
            isServiceOn = YES;
        }
    } else {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        // 此处只应判断拒绝的情况，第一次未决定时返回YES，不做任何弹框，系统自己弹
        if (status == kCLAuthorizationStatusDenied) {
            isServiceOn = NO;
        } else {
            isServiceOn = YES;
        }
    }
    return isServiceOn;
}

- (BOOL)isCameraServiceOn {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)isMailServiceOn {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    __block BOOL isCan = NO;
    
    if (authStatus != kABAuthorizationStatusAuthorized) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 if (error) {
                     NSLog(@"Error: %@", (__bridge NSError *)error);
                 } else if (!granted) {
                     isCan = NO;
                 } else {
                     isCan = YES;
                 }
            });
        });
    } else {
        isCan = NO;
    }
    return isCan;
}

- (void)checkMicrophoneServeceOnCompletion:(void (^)(BOOL isPermision, BOOL isFirstAsked))completion {
    __block BOOL permision = NO;
    __block BOOL firstAsked = NO;
    // ios7 是利用 requestRecordPermission,回调只能判断允许或者未被允许
    NSDate *date = [NSDate date];
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // ios7无法判断是否是出于未决定的状态,但是一旦判断，很快回调，所以可以用一个比较短的时间差来达到比较精准的判断
            NSDate *date2 = [NSDate date];
            NSTimeInterval timeGap = [date2 timeIntervalSinceDate:date];
            if (timeGap > 0.5) {
                firstAsked = YES;
            } else {
                firstAsked = NO;
            }
            permision = granted;
            
            if (completion) {
                completion(permision, firstAsked);
            }
        }];
        
    } else {
        // 7以前不用检测权限
        permision = YES;
        firstAsked = NO;
        if (completion) {
            completion(permision, firstAsked);
        }
    }
}

- (BOOL)checkAccessPermissions:(PermissionType)type {
    NSURL *url;
    BOOL isCanOpen = NO;
    if (ISIOS8) {
        url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        isCanOpen = [[UIApplication sharedApplication] canOpenURL:url];
    }
    __block BOOL isCan = NO;
    if (type == PermissionPhotoType) {
        // 相相册权限判断
        // 此处只应判断拒绝的情况，未决定时，不做任何弹框，系统自己弹
        if (ISIOS8) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusDenied) {
                isCan = NO;
            } else if (status == PHAuthorizationStatusNotDetermined){
                return YES;
            } else {
                isCan = YES;
            }
        } else {
            ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
            if (status == kCLAuthorizationStatusDenied) {
                isCan = NO;
            } else if (status == kCLAuthorizationStatusNotDetermined){
                return YES;
            } else {
                isCan = YES;
            }
        }
    } else if (type == PermissionCamaratype) {
        // 相机权限判断
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied) {
            isCan = NO;
        } else if (status == AVAuthorizationStatusNotDetermined){
            return YES;
        } else {
            isCan = YES;
        }
    } else if (type == PermissionLocationType) {
        // 定位服务判断
        // 先判断用户是否决定，再手机定位是否开启，最后判断是否允许APP使用定位
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == AVAuthorizationStatusNotDetermined) {
            return YES;
        } else {
            // 是否打开定位
            BOOL isServerOn = [CLLocationManager locationServicesEnabled];
            if (isServerOn) {
                if (status == AVAuthorizationStatusDenied) {
                    isCan = NO;
                } else {
                    isCan = YES;
                }
            } else {
                isCan = NO;
                url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
                isCanOpen = [[UIApplication sharedApplication] canOpenURL:url];
            }
        }
    } else if (type == PermissionMailType) {
        // 邮箱权限判断
        isCan = [self isMailServiceOn];
    } else if (type == PermissionMicrophoneType) {
        // 麦克风权限判断
        [self checkMicrophoneServeceOnCompletion:^(BOOL isPermision, BOOL isFirstAsked) {
            if (isFirstAsked) {
                isCan = isFirstAsked;
            } else {
                isCan = isPermision;
            }
        }];
    }
    //权限未打开
    if (!isCan) {
        NSArray *titleArray = @[@"没有相册访问权限", @"没有相机访问权限", @"没有打开定位服务", @"没有通讯录访问权限", @"没有麦克风访问权限"];
        NSArray *messageNot = @[@"请在iPhone的“设置-隐私-照片”\n允许扑多访问您的手机照片",
                                @"请在iPhone的“设置-隐私-相机”\n允许扑多访问您的手机相机",
                                @"请在iPhone的“设置-隐私-定位服务”\n允许扑多使用您的手机定位服务",
                                @"请在iPhone的“设置-隐私-通讯录”\n允许扑多访问您的手机通讯录",
                                @"请在iPhone的“设置-隐私-麦克风”\n允许扑多访问您的手机麦克风"];
        NSArray *messageCan = @[@"立即前往iPhone的“扑多-照片”\n允许扑多访问您的手机照片",
                                @"立即前往iPhone的“扑多-相机”\n允许扑多访问您的手机相机",
                                @"立即前往iPhone的“扑多-定位服务”\n允许扑多使用您的手机定位服务",
                                @"立即前往iPhone的“扑多-通讯录”\n允许扑多访问您的手机通讯录",
                                @"立即前往iPhone的“扑多-麦克风”\n允许扑多访问您的手机麦克风"];
        
        NSString *title, *message, *otherStr;
        if (isCanOpen) {
            message = messageCan[type];
            otherStr = @"去设置";
        } else {
            otherStr = @"确定";
            message = messageNot[type];
        }
        title = titleArray[type];
        [HXFAlertView alertWithTitle:title message:message cancelButton:@"取消" otherButton:otherStr complete:^(NSInteger buttonIndex) {
            if (isCanOpen && buttonIndex == 1) {
                dispatch_after(0.01, dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] openURL:url];
                });
            }
        }];
    }

    return isCan;
}

@end
