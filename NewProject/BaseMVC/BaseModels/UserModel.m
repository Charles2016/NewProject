//
//  UserModel.m
//  CarShop
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (NSString *)getPrimaryKey {
    return @"uid";
}


// 实现这个方法的目的：告诉MJExtension框架模型中的属性名对应着字典的哪个key
//+ (NSDictionary *)replacedKeyFromPropertyName{
//    return @{@"userInfo" : @"UserInfo"};
//}

/**
 *  登录/注册接口
 *  @param mobile   手机号
 *  @param 验证码    密码
 *  @param hud      hud提示消息类型
 *  @param target   controller用于释放网络请求
 *  @param success  登录成功回调
 */
+ (NSURLSessionDataTask *)getLoginWithPhone:(NSString *)phone
                                       code:(NSString *)code
                                 networkHUD:(NetworkHUD)hud
                                     target:(id)target
                                    success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(phone, @"Phone");
    DicValueSet(code, @"Code");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"User/Login" params:ParamsDic networkHUD:hud target:target success:success];
}

/**
 *  发送验证码
 *  @param mobile   手机号
 *  @param imageCode 图形验证码
 *  @param hud      hud提示消息类型
 *  @param target   controller用于释放网络请求
 *  @param success  登录成功回调
 */
+ (NSURLSessionDataTask *)getVerificationCodeWithPhone:(NSString *)phone
                                            networkHUD:(NetworkHUD)hud
                                                target:(id)target
                                               success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(phone, @"Phone");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"User/SendMNS" params:ParamsDic networkHUD:hud target:target success:success];
}

@end

@implementation DeviceModel

/**
 *  取获Token
 *  @param success  打开APP成功回调
 */
+ (NSURLSessionDataTask *)getTokenSuccess:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(kDeviceId, @"IDCard");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"Core/GetToken" params:ParamsDic networkHUD:NetworkHUDBackground target:nil success:success];
}

@end

@implementation UserInfoModel

/**
 *  更新个人信息接口
 */
+ (NSURLSessionDataTask *)changeUserInfoWithKey:(NSString *)key
                                          value:(id)value
                                     networkHUD:(NetworkHUD)hud
                                         target:(id)target
                                        success:(NetResponseBlock)success {
    CreateParamsDic;
    NSString *url;
    if ([key isEqualToString:@"NickName"]) {
        url = @"User/UpdateNickName";
    } else if ([key isEqualToString:@"Grand"]) {
        url = @"User/UpdateGrand";
    } else if ([key isEqualToString:@"Birth"]) {
        url = @"User/UpdateBirth";
    }
    DicValueSet(value, key);
    return [[self class] dataTaskMethod:HTTPMethodPOST path:url params:ParamsDic networkHUD:NetworkHUDBackground target:nil success:success];
}

/**
 *  上传单张图片接口
 */
+ (NSURLSessionDataTask *)uploadImageDataWithImage:(UIImage *)image
                                        networkHUD:(NetworkHUD)hud
                                            target:(id)target
                                           success:(NetResponseBlock)success {
    return [[self class] uploadImageWithPath:@"/FileUpLoad/CommentFileUpLoad" image:image params:nil networkHUD:NetworkHUDMsg target:self success:success];
}

/**
 *  上传多张图片接口
 */
+ (void)uploadImageDataWithImages:(NSArray *)images
                       networkHUD:(NetworkHUD)hud
                           target:(id)target
                          success:(NetResponseBlock)success {
    [[self class] uploadImagesWithPath:@"FileUpLoad/CommentFileUpLoad" images:images params:nil networkHUD:NetworkHUDMsg target:target success:success];
}

/**
 *  更新个人头像接口
 */
+ (NSURLSessionDataTask *)updateUserImageWithPathStr:(NSString *)pathStr
                                          networkHUD:(NetworkHUD)hud
                                              target:(id)target
                                             success:(NetResponseBlock)success {
    CreateParamsDic;
    DicValueSet(pathStr, @"HeadPortrait");
    return [[self class] dataTaskMethod:HTTPMethodPOST path:@"User/UpdateHeadPic" params:ParamsDic networkHUD:NetworkHUDBackground target:nil success:success];
}


@end
