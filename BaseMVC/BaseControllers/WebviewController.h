//
//  WebviewController.h
//  GoodHappiness
//
//  Created by chaolong on 16/5/20.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "SuperVC.h"

@interface WebviewController : SuperVC

@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, assign) BOOL isShowTabBar;
@property (nonatomic, assign) BOOL isShowProgress;// 显示加载进度
@property (nonatomic, strong) UIWebView *webView;

/**
 * 跳转webViewVC
 * @param url    网页url
 * @param fromVC 跳转VC
 */
+ (void)pushToWebViewWithUrl:(NSString *)url fromVC:(UIViewController *)fromVC;

@end
