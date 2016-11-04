//
//  UserModel.h
//  GoodHappiness
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "BaseModel.h"
@class UserInfoModel, UpdateVersionInfoModel, BannersModel;

@protocol DeviceModel
@end

@protocol BannersModel
@end

@protocol UserInfoModel
@end

@protocol UpdateVersionInfoModel
@end

@interface UserModel : BaseModel

// 验证码接口所用
@property (nonatomic, assign) NSInteger code;// 验证码

// 登录接口所用
@property (nonatomic, copy) NSString *sid;// 登录返回的唯一标识sid
@property (nonatomic, strong) UserInfoModel *userInfo;// 用户信息
@property (nonatomic, assign) BOOL isLogin;// 判断是否退出登录

// 融云IM登录用
@property (nonatomic, copy) NSString *chatToken;
// 七牛上传用
@property (nonatomic, copy) NSString *uploadToken;// 上传图片用

// 个人中心用
@property (nonatomic, assign) NSInteger unreadCommentNum;
@property (nonatomic, assign) NSInteger unreadLikeNum;
@property (nonatomic, strong) NSArray *redBags;

/**
 *  app前台后台状态添加
 */
+ (NSURLSessionDataTask *)getAppStatusWithIsBackground:(BOOL)isBackground
                                            networkHUD:(NetworkHUD)hud
                                                target:(id)target
                                               success:(NetResponseBlock)success;

/**
 *  获取用户信息传设备Id和sid即可
 */
+ (NSURLSessionDataTask *)getUserInfoNetworkHUD:(NetworkHUD)hud
                                         target:(id)target
                                      cacheTime:(NSInteger)cacheTime
                                        success:(NetResponseBlock)success;

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
                                        success:(NetResponseBlock)success;

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
                                     success:(NetResponseBlock)success;



/*!
 * @brief 三方登录接口
 *
 * @param action     第三方登录类型 微信:wx QQ:qq 微博:sina
 * @param openid    第三方唯一标示符
 * @param acesstoken 第三方token
 * @param username   第三方昵称
 * @param iconURL    第三方头像
 * @param hud        hud类型
 * @param target     controller释放网络请求
 * @param sucess     登录成功回调
 *
 */
+ (NSURLSessionDataTask *)getThirdLoginWithAction:(NSString *)action
                                           openid:(NSString *)openid
                                       acessToken:(NSString *)acesstoken
                                         userName:(NSString *)username
                                          iconURL:(NSString *)iconURL
                                       networkHUD:(NetworkHUD)hud
                                           target:(id)target
                                           sucess:(NetResponseBlock)sucess;


/**
 *  注销接口
 */
+ (NSURLSessionDataTask *)getLogoutWithNetworkHUD:(NetworkHUD)hud
                                           target:(id)target
                                          success:(NetResponseBlock)success;

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
                                                success:(NetResponseBlock)success;

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
                                      success:(NetResponseBlock)success;

/**
 *  获取七牛上传图片token
 */
+ (NSURLSessionDataTask *)getPushImageToQiniuWithNetworkHUD:(NetworkHUD)hud
                                                     target:(id)target
                                                    success:(NetResponseBlock)success;

@end


@interface DeviceModel : BaseModel

@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *deviceIdentifier;
@property (nonatomic, copy) NSString *deviceResolution;
@property (nonatomic, copy) NSString *deviceSysVersion;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *chatToken;// 聊天Token
@property (nonatomic, strong) UpdateVersionInfoModel *updateVersionInfo;
@property (nonatomic, copy) NSString *cartUrl;// 购物车Url审核中用
@property (nonatomic, assign) NSInteger browserOpen;// 是否在审核中 1跳Safari审核用 2走原生普通业务用
@property (nonatomic, strong) NSArray *banners;

/**
 *  取获Token
 *  @param success  打开APP成功回调
 */
+ (NSURLSessionDataTask *)getTokenSuccess:(NetResponseBlock)success;

@end



@interface UserInfoModel : BaseModel

@property (nonatomic, copy) NSString *IP;
@property (nonatomic, copy) NSString *IPAddress;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger happyCoin;
@property (nonatomic, assign) NSInteger generalCoin;
@property (nonatomic, assign) CGFloat money;
//第三方登录接口所用
@property (nonatomic, assign) BOOL isBind;// 三方账号是否进行了绑定



/**
 *  用户信息更新
 *  @param key    关键字名称比如mobile，nickname等
 *  @param value  修改的值，当是修改手机号时用13xxx-验证码，否则直接传值
 */
+ (NSURLSessionDataTask *)changeUserInfoWithKey:(NSString *)key
                                          value:(NSString *)value
                                     networkHUD:(NetworkHUD)hud
                                         target:(id)target
                                        success:(NetResponseBlock)success;

@end

@interface UpdateVersionInfoModel : BaseModel

@property (nonatomic, copy) NSString *versionName;// 版本号数字
@property (nonatomic, copy) NSString *url;// 版本下载地址
@property (nonatomic, copy) NSString *content;// 更新地址 以&作为分割符号
@property (nonatomic, assign) NSInteger versionCode; // 版本号数字
@property (nonatomic, assign) NSInteger isRequired;// 是否强制更新0否 1是

@end

@interface BannersModel : BaseModel

@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *appUrl;

@end




