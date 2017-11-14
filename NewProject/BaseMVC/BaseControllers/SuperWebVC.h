//
//  SuperWebVC.h
//  CarShop
//
//  Created by Charles on 4/17/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "SuperVC.h"
#import <WebKit/WebKit.h>

@interface SuperWebVC : SuperVC

@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, assign) BOOL isShowTabBar;
@property (nonatomic, assign) BOOL isShowProgress;// 显示加载进度
@property (nonatomic, assign) BOOL isFirstVC;// 是否是第一个VC，不显示导航栏左右按钮
@property (nonatomic, strong) WKWebView *webView;


/**
 * 跳转webViewVC
 * @param url    网页url
 * @param fromVC 跳转VC
 */
+ (void)pushToWebViewWithUrl:(NSString *)url fromVC:(UIViewController *)fromVC;

/*
 @property (nonatomic, copy) WKWebViewConfiguration *configuration;// webView配置
 @property (nonatomic, copy) NSString *title;// 页面的标题，支持KVO
 @property (nonatomic, copy) NSURL *url;// 当前请求的url支持KVO
 @property (nonatomic, assign) BOOL loding;// 当前是否正在加载内容中，支持KVO
 @property (nonatomic, assign) BOOL allowsBackForwardNavigationGestures;// 是否支持左滑前进，右滑后退
 @property (nonatomic, assign) double estinatedProgress;// 当前加载的进度，范围[0，1]
 @property (nonatomic, assign) BOOL hasOnlySecureContent;// 页面中的所有资源是否通过安全加密链接来加载，支持KVO
 @property (nonatomic, assign) BOOL canGoBack;// 是否可以支持goback操作，支持KVO
 @property (nonatomic, assign) BOOL canGoForward;// 是否可以支持gofarward操作，支持KVO
 
 - (WKNavigation *)goback;// 返回上级页面，若不能则无任何操作
 - (WKNavigation *)goForward;// 进入下级页面，若不能则无任何操作
 - (WKNavigation *)reload;// 重新加载页面
 - (WKNavigation *)reloadFromOrigin;// 重新从原始URL载入
 - (void)stopLoading;// 停止加载数据
 // 执行JS代码
 - (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *error))completionHandler;
 */

@end
