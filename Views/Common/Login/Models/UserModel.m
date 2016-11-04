//
//  UserModel.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (NSString *)getPrimaryKey {
    return @"sid";
}

+ (NSDictionary *)objectClassInArray {
    return @{@"redBags" : @"RedEnvelopModel"};
}

/**
 *  app前台后台状态添加
 */
+ (NSURLSessionDataTask *)getAppStatusWithIsBackground:(BOOL)isBackground
                                            networkHUD:(NetworkHUD)hud
                                                target:(id)target
                                               success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(kSid ? kSid : @"", @"sid");
    DicValueSet(isBackground ? @"quit" : @"open", @"action");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/app/active" params:ParamsDic networkHUD:hud target:target success:success];
}


/**
 *  获取用户信息传设备Id和sid即可
 */
+ (NSURLSessionDataTask *)getUserInfoNetworkHUD:(NetworkHUD)hud
                                         target:(id)target
                                      cacheTime:(NSInteger)cacheTime
                                        success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(kSid ? kSid : @"", @"sid");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/user/userInfo" params:ParamsDic networkHUD:hud target:target cacheTime:cacheTime success:success];
}

/**
 *  注册接口
 *  @param mobile   手机号
 *  @param password 密码
 *  @param code     验证码
 *  @param inviteCode 邀请码
 *  @param isRegister Yes注册 NO要完善资料
 *  @param hud      hud提示消息类型
 *  @param target   controller用于释放网络请求
 *  @param success  注册成功回调
 */
+ (NSURLSessionDataTask *)getRegisterWithMobile:(NSString *)mobile
                                       password:(NSString *)password
                                           code:(NSString *)code
                                     inviteCode:(NSString *)inviteCode
                                     isRegister:(BOOL)isRegister
                                     networkHUD:(NetworkHUD)hud
                                         target:(id)target
                                        success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(mobile, @"mobile");
    if ([kSid length]) {
       DicValueSet(kSid,@"sid");
    }
    if (inviteCode.length) {
        DicValueSet(inviteCode, @"inviteCode");
    }
    DicValueSet(code, @"code");
    DicValueSet(password, @"password");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:isRegister ? @"/v2/user/register" : @"/v2/user/bindUserMobile" params:ParamsDic networkHUD:hud target:target success:success];
}

/**
 *  登录接口
 *  @param mobile   手机号
 *  @param password 密码
 *  @param hud      hud提示消息类型
 *  @param target   controller用于释放网络请求
 *  @param success  登录成功回调
 */
+ (NSURLSessionDataTask *)getLoginWithMobile:(NSString *)mobile
                                    password:(NSString *)password
                                  networkHUD:(NetworkHUD)hud
                                      target:(id)target
                                     success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(mobile, @"mobile");
    DicValueSet(password, @"password");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/user/login" params:ParamsDic networkHUD:hud target:target success:success];
}

/*!
 * @brief 三方登录接口
 *
 * @param action     第三方登录类型
 * @param uniqid     第三方唯一符标示
 * @param acesstoken 第三方token
 * @param username   第三方昵称
 * @param iconURL    第三方头像
 * @param hud        hud类型
 * @param target     controller释放网络请求
 * @param sucess     成功之后的回调
 *
 */
+ (NSURLSessionDataTask *)getThirdLoginWithAction:(NSString *)action openid:(NSString *)openid acessToken:(NSString *)acesstoken userName:(NSString *)username iconURL:(NSString *)iconURL networkHUD:(NetworkHUD)hud target:(id)target sucess:(NetResponseBlock)sucess {
    CreateParamsDic;
    DicValueSet(kDeviceIdentifier, @"deviceIdentifier");
    DicValueSet(action, @"action");
    if (openid.length) {
    DicValueSet(openid, @"openid");
    }
    DicValueSet(acesstoken, @"token");
    DicValueSet(username, @"username");
    DicValueSet(iconURL, @"avatar");
    return [[self class]  dataTaskMethod:HTTPMethodPOST path:@"/v2/user/appThirdLogin" params:ParamsDic networkHUD:NetworkHUDMsg target:target success:sucess];
}

/**
 *  注销接口
 */
+ (NSURLSessionDataTask *)getLogoutWithNetworkHUD:(NetworkHUD)hud
                                           target:(id)target
                                          success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(kSid ? kSid : @"", @"sid");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/user/logout" params:ParamsDic networkHUD:hud target:target success:success];
}

/**
 *  发送验证码
 *  @param mobile   手机号
 *  @param imageCode 图形验证码
 *  @param hud      hud提示消息类型
 *  @param target   controller用于释放网络请求
 *  @param success  登录成功回调
 */
+ (NSURLSessionDataTask *)getverificationCodeWithMobile:(NSString *)mobile
                                              imageCode:(NSString *)imageCode
                                             networkHUD:(NetworkHUD)hud
                                                 target:(id)target
                                                success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(mobile, @"mobile");
    DicValueSet(imageCode, @"imageCode");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/user/sms" params:ParamsDic networkHUD:hud target:target success:success];
}

/**
 *  忘记密码接口
 *  @param mobile   手机号
 *  @param password 密码
 *  @param code 验证码
 */
+ (NSURLSessionDataTask *)getForgetWithMobile:(NSString *)mobile
                                     password:(NSString *)password
                                        code:(NSString *)code
                                   networkHUD:(NetworkHUD)hud
                                       target:(id)target
                                      success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(mobile, @"mobile");
    DicValueSet(password, @"password");
    DicValueSet(code, @"code");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/user/passwordReset" params:ParamsDic networkHUD:hud target:target success:success];
}


/**
 *  获取七牛上传图片token
 */
+ (NSURLSessionDataTask *)getPushImageToQiniuWithNetworkHUD:(NetworkHUD)hud
                                                 target:(id)target
                                                success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(kSid ? kSid : @"", @"sid");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/app/uploadToken" params:ParamsDic networkHUD:hud target:target success:success];
}

@end

@implementation DeviceModel

+ (NSDictionary *)objectClassInArray {
    return @{@"banners" : @"BannersModel"};
}


/**
 *  取获Token
 *  @param success  成功回调
 */
+ (NSURLSessionDataTask *)getTokenSuccess:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(kDeviceId, @"deviceId");
    DicValueSet(kResolution, @"deviceResolution");
    DicValueSet(kVersion, @"deviceSysVersion");
    DicValueSet(@"ios", @"deviceType");
    DicValueSet(@([GetCurrentBuild integerValue]), @"appVersion");
    DicValueSet(kPushToken ? kPushToken : @"", @"pushToken");
    DicValueSet(kSid ? kSid : @"", @"sid");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/app/register" params:ParamsDic networkHUD:NetworkHUDBackground target:nil success:success];
}

@end

@implementation UserInfoModel

+ (NSString *)getPrimaryKey {
    return @"uid";
}

/**
 *  用户信息更新
 *  @param key    关键字名称比如mobile，nickname等
 *  @param value  修改的值，当是修改手机号时用13xxx-验证码，否则直接传值
 */
+ (NSURLSessionDataTask *)changeUserInfoWithKey:(NSString *)key
                                          value:(NSString *)value
                                     networkHUD:(NetworkHUD)hud
                                         target:(id)target
                                        success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(kSid ? kSid : @"", @"sid");
    DicValueSet(key, @"key");
    DicValueSet(value, @"value");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"/v2/user/updateUserInfo" params:ParamsDic networkHUD:hud target:target success:success];
}

@end

@implementation UpdateVersionInfoModel

+ (NSString *)getPrimaryKey {
    return @"versionCode";
}

@end

@implementation BannersModel

@end
