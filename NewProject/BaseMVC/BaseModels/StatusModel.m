//
//  StatusModel.m
//  HKMember
//
//  Created by 文俊 on 14-3-20.
//  Copyright (c) 2014年 CarMango. All rights reserved.
//

#import "StatusModel.h"

@interface StatusModel ()
@end

@implementation StatusModel

#pragma mark - Overwrite
- (void)mj_keyValuesDidFinishConvertingToObject
{
    //标准化系统msg
    NSString *fMsg = [[self class] innerFormatMessage:_Success msg:_Msg];
    if (![fMsg isEqualToString:_Msg]) {
        self.Msg = fMsg;
    }
}

#pragma mark - Init
- (id)initWithCode:(NSInteger)code msg:(NSString *)msg
{
    self = [super init];
    if (self) {
        self.Success = code;
        self.Msg = msg;
    }
    return self;
}

- (id)initWithError:(NSError*)error
{
    self = [super init];
    if (self) {
        // 先设置默认值
        NSString *msg;
        NSInteger flag = error.code;
        switch (error.code) {
            case NSURLErrorCancelled: // 网络请求已经取消!
                msg = @"";
                break;
            case  NSURLErrorTimedOut: // 网络请求超时
                msg = @"网络请求超时!";
                break;
            case NSURLErrorBadServerResponse: // 网络通了 404 500-内部服务器错误（有可能你的接口不对）
                NSLog(@"服务器内部错误!");
                break;
            case NSURLErrorCannotFindHost: // 主机名时返回一个URL不能解决
                NSLog(@"找不到服务器!");
                break;
            case NSURLErrorCannotConnectToHost: //当试图连接到主机返回失败了。这可能发生在一个主机名解析,但主机或可能不会接受特定端口上的连接。
                NSLog(@"无法连接到服务器!");
                break;
            case NSURLErrorNotConnectedToInternet: // 没有网络   返回一个网络资源请求的时候,但不是建立一个互联网连接和自动无法建立,通过缺乏连接,或由用户选择不自动进行网络连接
                msg = @"网络不可用,请检查网络!";
                break;
            default:
                NSLog(@"网络请求出现未知错误!");
                break;
        }
        
        self.Success = flag;
        self.Msg = msg;
    }
    return self;
}

#pragma mark - Private

/// 格式化输出系统提示信息
+ (NSString *)innerFormatMessage:(NSInteger)flag msg:(NSString *)msg {
    NSString *tmpMsg = msg;
    if (flag <= 0 || (flag >= 30001 && flag <= 41002)) {
        switch (flag) {
            case -3: {return @"你访问的页面不存在";}
            case -2: {return @"服务器发生错误";}//程序员开会小差，正在搬砖解决中
            case -1: {return @"系统繁忙，请稍候再试";}
        }
    }
    return tmpMsg;
}

@end
