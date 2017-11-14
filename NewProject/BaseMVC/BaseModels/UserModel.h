//
//  UserModel.h
//  CarShop
//
//  Created by chaolong on 16/4/9.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "BaseModel.h"
@class UserInfoModel;

@protocol DeviceModel
@end

@protocol UserInfoModel
@end

@interface UserModel : BaseModel

@property (nonatomic, strong) UserInfoModel *UserInfo;
@property (nonatomic, assign) NSInteger code;// 验证码
@property (nonatomic, assign) BOOL isLogin;// 判断是否退出登录
@property (nonatomic, assign) NSInteger unReadCount;// 未读消息数
@property (nonatomic, copy) NSString *uid;// 用户id
@property (nonatomic, copy) NSString *LIV;// 登录返回的token

/**
 *  登录/注册接口
 *  @param phone    手机号
 *  @param code     验证码
 *  @param hud      hud提示消息类型
 *  @param target   controller用于释放网络请求
 *  @param success  登录成功回调
 */
+ (NSURLSessionDataTask *)getLoginWithPhone:(NSString *)phone
                                       code:(NSString *)code
                                 networkHUD:(NetworkHUD)hud
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
+ (NSURLSessionDataTask *)getVerificationCodeWithPhone:(NSString *)phone
                                            networkHUD:(NetworkHUD)hud
                                                target:(id)target
                                               success:(NetResponseBlock)success;

@end


@interface DeviceModel : BaseModel

@property (nonatomic, copy) NSString *Token;
@property (nonatomic, copy) NSString *InvalidDate;

/**
 *  取获Token
 *  @param success  打开APP成功回调
 */
+ (NSURLSessionDataTask *)getTokenSuccess:(NetResponseBlock)success;

@end



@interface UserInfoModel : BaseModel

@property (nonatomic, assign) NSInteger ID; // 用户ID
@property (nonatomic, copy) NSString *Realname;// 姓名
@property (nonatomic, copy) NSString *Nickname;// 昵称
@property (nonatomic, copy) NSString *Phone;// 手机号
@property (nonatomic, copy) NSString *Province;// 省份
@property (nonatomic, copy) NSString *City;// 市
@property (nonatomic, copy) NSString *Area;// 区域
@property (nonatomic, copy) NSString *Sologen;// 个性标签
@property (nonatomic, copy) NSString *AddressDetail;// 详细地址
@property (nonatomic, assign) NSInteger Age;// 年龄
@property (nonatomic, assign) NSInteger Balance;// 余额
@property (nonatomic, copy) NSString *Birthday;// 生日
@property (nonatomic, copy) NSString *Description;// 个人简介
@property (nonatomic, assign) NSInteger Grand;//0女 1男
@property (nonatomic, copy) NSString *HeadPortrait;// 头像
@property (nonatomic, copy) NSString *IMUserName;// 客服Im账号名称
@property (nonatomic, copy) NSString *IMUserPass;// 客服Im密码

@property (nonatomic, copy) NSString *Data;//上传图片返回的字符串

/**
 *  更新个人信息接口
 */
+ (NSURLSessionDataTask *)changeUserInfoWithKey:(NSString *)key
                                          value:(id)value
                                     networkHUD:(NetworkHUD)hud
                                         target:(id)target
                                        success:(NetResponseBlock)success;

/**
 *  上传单张图片接口
 */
+ (NSURLSessionDataTask *)uploadImageDataWithImage:(UIImage *)image
                                        networkHUD:(NetworkHUD)hud
                                            target:(id)target
                                           success:(NetResponseBlock)success;

/**
 *  上传多张图片接口
 */
+ (void)uploadImageDataWithImages:(NSArray *)images
                       networkHUD:(NetworkHUD)hud
                           target:(id)target
                          success:(NetResponseBlock)success;

/**
 *  更新个人头像接口
 */
+ (NSURLSessionDataTask *)updateUserImageWithPathStr:(NSString *)pathStr
                                          networkHUD:(NetworkHUD)hud
                                              target:(id)target
                                             success:(NetResponseBlock)success;



@end





