//
//  WebviewController.m
//  GoodHappiness
//
//  Created by chaolong on 16/5/20.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "WebviewController.h"

@interface WebviewController ()<UIWebViewDelegate> {
    UIBarButtonItem *_share;
    UIBarButtonItem *_home;
    UIView *_progressView;
    NSString *_lastUrlStr;
}
@end

@implementation WebviewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadingStart];
    _lastUrlStr = _urlStr;
    self.navigationItem.title = @"加载中...";
    self.navigationItem.leftBarButtonItem = [self barBackButton];
    NSString *homeImageStr = @"nav_right_home";
    self.navigationItem.rightBarButtonItems = [[self class] setItemsTitles:@[] imageNames:@[homeImageStr, @"nav_right_share"] isRightItems:YES titleColor:nil target:self action:@selector(buttonAction:)];
    _home = self.navigationItem.rightBarButtonItems[0];
    _share = self.navigationItem.rightBarButtonItems[1];
    _share.customView.hidden = _home.customView.hidden = YES;
    /*if (_isShowProgress) {
        _progressView = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height - 2, kScreenWidth, 2)];
        _progressView.backgroundColor = kColorBlue;
        [self.navigationController.navigationBar addSubview:_progressView];
    }*/
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, _isShowTabBar ? kMiddleHeight : kBodyHeight)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    [_webView loadRequest:request];
    //网页是否启用智能识别
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [_webView setScalesPageToFit:YES];
    [self.view addSubview:_webView];
    // 添加加载状态
    [self loadingStartBgClear];
}

- (void)backToSuperView {
    if ([_urlStr rangeOfString:@"/order/result"].length) {
        // app跳内部webview结果页的时候，返回按钮返回首页
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)refreshClickWithStatus:(LoadingStatus)status {
    if (status == LoadingStatusFail) {
        [_webView reload];
    }
}

- (void)buttonAction:(UIButton *)button {
    if (button.tag == 1061790) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        // 点击分享处理
        NSArray *strArray = [_urlStr componentsSeparatedByString:@"productId="];
        [ShareView initWithShareFromType:ShareFromTypeLottery action:@"shop" shareId:[strArray[1] integerValue] complete:nil];
    }
}

/**
 * 跳转webViewVC
 * @param url    网页url
 * @param fromVC 跳转VC
 */
+ (void)pushToWebViewWithUrl:(NSString *)url fromVC:(UIViewController *)fromVC {
    WebviewController *VC = [[WebviewController alloc]init];
    VC.urlStr = url;
    [fromVC.navigationController pushViewController:VC animated:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self loadingSuccess];
    _home.customView.hidden = ![_lastUrlStr isEqual:_urlStr];
    if ([_urlStr rangeOfString:@"/user/insrallnormal"].length) {
        _home.customView.hidden = YES;
    }
    _share.customView.hidden = ![_urlStr rangeOfString:@"detail?productId="].length;
    [SuperVC setNavigationStyle:self.navigationController textColor:kColorBlack barColor:kColorLightgray];
    self.navigationItem.title = webView.getTitle;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    _urlStr = request.URL.absoluteString;
    if (![_urlStr isEqual:_lastUrlStr]) {
        [self loadingSuccess];
        if ([_urlStr rangeOfString:@"ios:goto"].length) {
            /*// 网页条兑换时做做刷新操作 购买成功为了刷新余额操作
            if (!_share.customView.hidden) {
                [_webView reload];
            }*/
            // 跳网页的操作都是由第一个tabBar
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushToAppVC object:@{@"selfVC" : self, @"urlStr" : _urlStr}];
        } else {
            WebviewController *VC = [[WebviewController alloc]init];
            VC.urlStr = _urlStr;
            [self.navigationController pushViewController:VC animated:YES];
        }
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // 网络加载失败
    [self loadingFail];
}



/*- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL ret = YES;
    if ([_webViewProxyDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        ret = [_webViewProxyDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if (ret && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_webViewProxyDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_webViewProxyDelegate webViewDidStartLoad:webView];
    }
    
    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([_webViewProxyDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_webViewProxyDelegate webViewDidFinishLoad:webView];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([_webViewProxyDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_webViewProxyDelegate webView:webView didFailLoadWithError:error];
    }
    
    _loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    BOOL isGrowing = progress > 0.0;
    [UIView animateWithDuration:(isGrowing && animated) ? _barAnimationDuration : 0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = _progressBarView.frame;
        frame.size.width = progress * self.bounds.size.width;
        _progressBarView.frame = frame;
    } completion:nil];
    
    if (progress >= 1.0) {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:_fadeOutDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _progressBarView.alpha = 0.0;
        } completion:^(BOOL completed){
            CGRect frame = _progressBarView.frame;
            frame.size.width = 0;
            _progressBarView.frame = frame;
        }];
    } else {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _progressBarView.alpha = 1.0;
        } completion:nil];
    }
}*/


@end
