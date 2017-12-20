//
//  SuperWebVC.m
//  CarShop
//
//  Created by Charles on 4/17/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "SuperWebVC.h"

const float NJKInitialProgressValue = 0.2f;
const float NJKInteractiveProgressValue = 0.5f;
const float NJKFinalProgressValue = 1.0f;

@interface SuperWebVC () <WKNavigationDelegate, WKUIDelegate> {
    UIBarButtonItem *_share;
    UIBarButtonItem *_home;
    UIView *_progressView;
    NSString *_lastUrlStr;
}

@end

@implementation SuperWebVC

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    if (_progressView.width) {
        // 若本页面发生跳转，则隐藏进度条
        [self webViewDidFinishLoad];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![_urlStr hasPrefix:@"http://"]) {
        // 若网站只有www开头则添加http://前缀
        _urlStr = [NSString stringWithFormat:@"http://%@", _urlStr];
    }
    self.navigationItem.title = @"加载中...";
    _home = self.navigationItem.rightBarButtonItems[0];
    _share = self.navigationItem.rightBarButtonItems[1];
    _share.customView.hidden = _home.customView.hidden = YES;
    
    // 加载进度条
    if (_isShowProgress) {
        _progressView = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height - 2, kScreenWidth * 0.1, 2)];
        _progressView.backgroundColor = kColorBlack;
        [self.navigationController.navigationBar addSubview:_progressView];
    }
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    // 自适应屏幕宽度js
    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    // 添加自适应屏幕宽度js调用的方法
    [wkWebConfig.userContentController addUserScript:wkUserScript];
    
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, _isShowTabBar ? kMiddleHeight : kBodyHeight) configuration:wkWebConfig];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    @weakify(self);
    [_webView.scrollView addLegendHeaderWithRefreshingBlock:^{
        @strongify(self);
        [self loadWebView];
    }];
    [self.view addSubview:_webView];
    [self loadWebView];
    [self loadingStart];
}

- (void)refreshClickWithStatus:(LoadingStatus)status {
    if (status == LoadingStatusFail) {
        [self loadWebView];
    }
}

- (void)loadWebView {
    // 当urlStr包含中文时，url为空，所以要讲中文编码再取其url的值
    if ([_urlStr includeChinese]) {
        _urlStr = [_urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSURL *url = [NSURL URLWithString:_urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

/**
 * 跳转webViewVC
 * @param url    网页url
 * @param fromVC 跳转VC
 */
+ (void)pushToWebViewWithUrl:(NSString *)url fromVC:(UIViewController *)fromVC {
    SuperWebVC *VC = [[SuperWebVC alloc]init];
    VC.urlStr = url;
    [fromVC.navigationController pushViewController:VC animated:YES];
}

// 页面加载进度条
- (void)webViewDidFinishLoad {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _progressView.width = kScreenHeight;
    } completion:^(BOOL completed){
        _progressView.alpha = 0;
        _progressView.width = 0;
    }];
    if (_webView.scrollView.header.isRefreshing) {
        [_webView.scrollView.header endRefreshing];
    }
}

#pragma mark - WKUIDelegate
/**
 *  web界面中有弹出警告框时调用
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param frame             主窗口
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(void (^)())completionHandler {
    
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler {
    
}

- (void)webViewDidClose:(WKWebView *)webView {
    
}

// 创建新的webView
// 可以指定配置对象、导航动作对象、window特性。如果没用实现这个方法，不会加载链接，如果返回的是原webview会崩溃。
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)) {
    return YES;
}
- (UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0)) {
    return self;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0)) {
    
}


#pragma mark - WKNavigationDelegate
// 发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // WebKit框架对跨域进行了安全性检查限制，不允许跨域在此做些特殊处理
    // 跨域请求处理(如从一个HTTP页对HTTPS发起请求)
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    if (WKNavigationTypeLinkActivated == navigationAction.navigationType && [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
        policy = WKNavigationActionPolicyCancel;
    }
    decisionHandler(policy);
    /*WKFrameInfo *sFrame = navigationAction.sourceFrame;//navigationAction的出处
    WKFrameInfo *tFrame = navigationAction.targetFrame;//navigationAction的目标
    //只有当  tFrame.mainFrame == NO；时，表明这个 WKNavigationAction 将会新开一个页面。
    //才会调用- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;*/
}

// 在收到服务器的响应头，根据response相关信息，决定是否跳转，decisionHandler必须调用，来决定是否跳转，参数WKNavigationResponsePolicyCancel取消跳转，WKNavigationResponsePolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 收到服务器跳转请求之后调用（服务器端redirect），不一定调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 准备加载页面。等同UIWebViewDelegate中的webView:shouldStartLoadWithRequest:navigationType
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    DLog(@"webView.URL.absoluteString:%@", webView.URL.absoluteString);
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _progressView.width = kScreenHeight * NJKInteractiveProgressValue;
    } completion:nil];
    _lastUrlStr = webView.URL.absoluteString;
    
    if (!([_urlStr isEqual:_lastUrlStr] || [_lastUrlStr isEqual:[NSString stringWithFormat:@"%@/", _urlStr]])) {
        if ([_lastUrlStr rangeOfString:@"cmgapp://"].length) {
            /*// 网页条兑换时做做刷新操作 购买成功为了刷新余额操作
             if (!_share.customView.hidden) {
             [_webView reload];
             }*/
            // 跳网页的操作都是由第一个tabBar
            [[NSNotificationCenter defaultCenter] postNotificationName:kPushToAppVC object:@{@"selfVC" : self, @"urlStr" : _lastUrlStr}];
            [webView stopLoading];
        } else {
            if (_progressView.width) {
                // 若本页面发生跳转，则隐藏进度条
                [self webViewDidFinishLoad];
            }
            [[self class] pushToWebViewWithUrl:_urlStr fromVC:self];
        }
    }
}

// 开始获取到网页内容
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成。等同于UIWebWebDelegate:-webViewDidFinishLoad:
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.navigationItem.title = webView.title;
    [self loadingSuccess];
    [self webViewDidFinishLoad];
}

// 页面加载失败。等同于UIWebWebDelegate:-webView: didFailLoadWithError:
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self loadingFail];
    [self webViewDidFinishLoad];
}

// 页面内容加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self webViewDidFinishLoad];
}
// SSL认证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

@end
