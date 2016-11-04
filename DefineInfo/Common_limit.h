//
//  Common_limit.h
//  HKC
//
//  Created by zhangshaoyu on 14-10-27.
//  Copyright (c) 2014年 zhangshaoyu. All rights reserved.
//  功能描述：常用限制

#ifndef HKC_Common_limit_h
#define HKC_Common_limit_h

/********************** limit ****************************/

#pragma mark - 输入限制

// 提示符时间长度
#define kHUDTime 2.5

/// 分页大小
#define kPageSize 10

// 分割线高度
#define kSeparatorlineHeight 0.5

// 注册模块
#define kMaxAccountLength             11 // 账号最大长度限制
#define kMaxPasswordLength            16 // 密码最大长度限制
#define kMinPasswordLength            6  // 密码最小长度限制

#define kVerificationCodeLength       8  // 验证码最大长度限制

#define kMinNicknameLength            4  // 昵称最小长度限制
#define kMaxNicknameLength            20 // 昵称最大长度限制

#define kMax_Account             11 // 用户名:必须以字母开头，可以使用6-20个字母、数字、下划线和减号，长度为最长20位，最少6位
#define kMax_Password            12 // 密码字符位数6~12位,明文密码区分大小写,至少由字母、数字或特殊字符中两种组成
#define kMin_Password            6  // 密码最小长度限制
//#define kMax_PayPassword         16  // 交易密码: 8-16位 字母和数字构成
//#define kMax_NickName            15  // 昵称:最多20位字符
#define kMax_MessageValidateCode 6   // 验证码:6位
//#define kMax_Signature           30 // 个性签名
//#define kMax_Address             100 // 地址
#define kMax_Phone               11  // 手机号
//#define kMax_Tel                 18  // 电话号
//#define kMax_RecommendCode       8   //注册邀请码
//#define kMax_IDCardNum           18 // 身份证号
//#define kMax_RealName            15 // 真实姓名
//#define kMax_Money               12 // 充值金额位数限制

/// 字符输入限制
#define NUMBERS     @"0123456789"
#define xX          @"xX"
#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

///除了下划线外特殊字符
#define Special_Character_ExceptUnderLine  @"[-/:\\;()$&.,?!'\"{}#%^*+=|~<>£¥€•]-：；（）¥“”。，、？！.【】｛｝#%^*+=—|～《》$&•…,^^?!'「」·‘’"

#define Special_Character  @"[-/:\\;()$&@.,?!'\"{}#%^*+=_|~<>£¥€•]-：；（）¥@“”。，、？！.【】｛｝#%^*+=_—|～《》$&•…,^_^?!'「」·‘’"

#define SpecialCharacterAndNumber @"[-/:\\;()$&@.,?!'\"{}#%^*+=_|~<>£¥€•]-：；（）¥@“”。，、？！.【】｛｝#%^*+=_—|～《》$&•…,^_^?!'「」·‘’0123456789"

#define AllCharacterAndNumber @"[-/:\\;()$&@.,?!'\"{}#%^*+=_|~<>£¥€•]-：；（）¥@“”。，、？！.【】｛｝#%^*+=_—|～《》$&•…,^_^?!'「」·‘’0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

/********************** limit ****************************/

// 正则限制
#define RegexExceptSpace @"\\S" // 除了空格的其他字符
#define RegexNumber @"[0-9]"
#define RegexCharacter @"[a-zA-Z]"
#define RegexCharacterlower @"[a-z]"
#define RegexCharacteruper @"[A-Z]"
#define RegexNumberAndCharacter @"[0-9a-zA-Z]"
#define RegexNumberAndCharacterlower @"[0-9a-z_.@]"


#endif
