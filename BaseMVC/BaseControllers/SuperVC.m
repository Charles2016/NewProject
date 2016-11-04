//
//  SuperVC.m
//  ZQB
//
//  Created by YangXu on 14-7-10.
//
//

#import "SuperVC.h"
#import "LoginVC.h"
#import "RegisterVC.h"

@interface SuperVC () <LoadingAndRefreshViewDelegate> {
    UITapGestureRecognizer  *_tap; // 添加手势用于点击空白处收回键盘
    LoadingAndRefreshView   *_loadingAndRefreshView;
}

@end

@implementation SuperVC

- (void)dealloc {
    DLog(@"%@释放了",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseNet];
}

- (void)setTaBarIndex:(NSInteger)taBarIndex {
    kUserDefaults(@"kTaBarIndex", @(taBarIndex));
    kSynchronize;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = NO;
    [SuperVC setNavigationStyle:self.navigationController textColor:kColorBlack barColor:[self isTabbarRoot] ? kColorNavBground :kColorLightgray];
    _taBarIndex = [kTaBarIndex integerValue];
    // 当返回根视图时需要跳转到对应tabar
    // 当设置这个后回到首页改变taBar 1首页 2最新揭晓 3扑多 4商城 5个人中心
    if (_taBarIndex && [self isTabbarRoot]) {
        [self.tabBarController setSelectedIndex:_taBarIndex - 1];
        self.taBarIndex = 0;
    }
    
    [MobClick beginLogPageView:self.navigationItem.title];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    if ([self isTabbarRoot]) {
        self.hidesBottomBarWhenPushed = NO;
    } else {
        self.hidesBottomBarWhenPushed = YES;
    }
    [MobClick endLogPageView:self.navigationItem.title];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"kNetworkStatus:%ld", kNetworkStatus);
    self.view.backgroundColor = kColorWhite;
    // 监控网络变化block status-1未知网络 0连不上网络 1xG网络 2WiFi网络
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        [self networkChangeAction:status];
    }];
    [self loadViewData];
    // 监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 键盘弹出后在屏幕添加手势，点击空白处收回键盘
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHidden)];
}

- (void)loadViewData {
    self.view.backgroundColor = UIColorRGB(240, 240, 243);
    if (ISIOS7) {
        self.tabBarController.tabBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationItem.leftBarButtonItem = [self isTabbarRoot] ? nil : [self barBackButton];
}

#pragma mark - publicMethod
// 返回上一层
- (void)backToSuperView {
    // 取消网络请求
    [self releaseNet];
    [self.view endEditing:YES];
    if (self.navigationController.viewControllers.firstObject == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (_isPopToRootVC) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

// 判断是否是tabBar根视图
- (BOOL)isTabbarRoot {
    for (UINavigationController *nav in self.tabBarController.viewControllers) {
        if (nav.viewControllers.firstObject == self) {
            return YES;
        }
    }
    return NO;
}

- (void)networkChangeAction:(AFNetworkReachabilityStatus)status {

}

// 登录和完善资料验证
+ (void)bindVerifySuccess:(void(^)())success {
    [self loginVerifyWithSuccess:^{
        if (GetDataUserModel.userInfo.isBind) {
            success();
        } else {
            /*TabBarVC *tabBarVC = (TabBarVC *)[UIApplication sharedApplication].windows[0].rootViewController;
            UIViewController *currentVC = ((UINavigationController *)tabBarVC.selectedViewController).viewControllers.lastObject;
            RegisterVC *VC = [[RegisterVC alloc]init];
            VC.finishBlock = ^() {
                success();
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
            [currentVC presentViewController:nav animated:YES completion:nil];*/
        }
    }];
}

// 登录验证方法
- (void)loginVerifySuccess:(void(^)())success {
    [[self class] loginVerifyWithSuccess:success];
}

+ (void)loginVerifyWithSuccess:(void (^)())success {
    if (GetDataUserModel.isLogin) {
        if (success) {
            success();
        }
    } else {
        /*TabBarVC *tabBarVC = (TabBarVC *)[UIApplication sharedApplication].windows[0].rootViewController;
        UIViewController *currentVC = ((UINavigationController *)tabBarVC.selectedViewController).viewControllers.lastObject;
        LoginVC *VC = [[LoginVC alloc] init];
        if (success) {
            VC.successBlock = success;
        }
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
        [SuperVC setNavigationStyle:nav textColor:kColorBlack barColor:kColorLightgray];
        [currentVC presentViewController:nav animated:YES completion:nil];*/
    }
}

- (void)addLoadingViewWithOffset:(CGFloat)offset {
    if (!_loadingAndRefreshView) {
        _loadingAndRefreshView = [[LoadingAndRefreshView alloc] initWithFrame:CGRectMake(0, offset, kScreenWidth, self.view.height - offset)];
        _loadingAndRefreshView.delegate = self;
    }
    if (!_loadingAndRefreshView.superview) {
        [self.view addSubview:_loadingAndRefreshView];
    }
    [self.view bringSubviewToFront:_loadingAndRefreshView];
}

#pragma mark - 加载成功
- (UIView *)loadingSuccess {
    if (_loadingAndRefreshView.superview) {
        [_loadingAndRefreshView removeFromSuperview];
    }
    return _loadingAndRefreshView;
}

#pragma mark - 加载中view
- (UIView *)loadingStart {
    return [self loadingStartWithOffset:0];
}

- (UIView *)loadingStartWithOffset:(CGFloat)offset {
    return [self loadingStartWithOffset:offset style:LoadingStyleNormal];
}

- (UIView *)loadingStartBgClear {
    return [self loadingStartBgClearWithOffset:0];
}

- (UIView *)loadingStartBgClearWithOffset:(CGFloat)offset {
    return [self loadingStartWithOffset:offset style:LoadingStyleBgClear];
}

- (UIView *)loadingStartWithOffset:(CGFloat)offset style:(LoadingStyle)style {
    [self addLoadingViewWithOffset:offset];
    [_loadingAndRefreshView setLoadingStateWithOffset:offset style:style];
    return _loadingAndRefreshView;
}

#pragma mark - 未偏移量的加载失败view
- (UIView *)loadingFail {
    [self loadingFailWithTitle:@"" imageStr:@""];
    return _loadingAndRefreshView;
}

- (UIView *)loadingFailWithTitle:(NSString *)title {
    [self loadingFailWithTitle:title imageStr:@""];
    return _loadingAndRefreshView;
}

- (UIView *)loadingFailWithTitle:(NSString *)title imageStr:(NSString *)imageStr {
    [self addLoadingViewWithOffset:0];
    [_loadingAndRefreshView setFailStateWithTitle:title imageStr:imageStr offset:0];
    return _loadingAndRefreshView;
}

#pragma mark - 带偏移量的加载失败view
- (UIView *)loadingFailWithOffset:(CGFloat)offset {
    [self loadingFailWithOffset:offset title:@"" imageStr:@""];
    return _loadingAndRefreshView;
}

- (UIView *)loadingFailWithOffset:(CGFloat)offset title:(NSString *)title {
    [self loadingFailWithOffset:offset title:title imageStr:@""];
    return _loadingAndRefreshView;
}

- (UIView *)loadingFailWithOffset:(CGFloat)offset title:(NSString *)title imageStr:(NSString *)imageStr {
    [self addLoadingViewWithOffset:offset];
    [_loadingAndRefreshView setFailStateWithTitle:title imageStr:imageStr offset:offset];
    _loadingAndRefreshView.loadingTip.hidden = NO;
    return _loadingAndRefreshView;
}

#pragma mark - 未带偏移量的无数据view
- (UIView *)loadingBlank {
    return [self loadingBlankWithTitle:@""];
}

- (UIView *)loadingBlankWithTitle:(NSString *)title {
    return [self loadingBlankWithTitle:title imageStr:@""];
}

- (UIView *)loadingBlankWithTitle:(NSString *)title imageStr:(NSString *)imageStr {
    return [self loadingBlankWithOffset:0 title:title imageStr:imageStr];
}

#pragma mark - 带偏移量的无数据view
- (UIView *)loadingBlankWithOffset:(CGFloat)offset {
    return [self loadingBlankWithOffset:offset title:@""];
}

- (UIView *)loadingBlankWithOffset:(CGFloat)offset title:(NSString *)title {
    return [self loadingBlankWithOffset:offset title:title imageStr:@""];
}

- (UIView *)loadingBlankWithOffset:(CGFloat)offset title:(NSString *)title imageStr:(NSString *)imageStr {
    return [self loadingBlankWithOffset:offset title:title imageStr:imageStr buttonTitle:@""];
}

- (UIView *)loadingBlankWithOffset:(CGFloat)offset title:(NSString *)title imageStr:(NSString *)imageStr buttonTitle:(NSString *)buttonTitle {
    [self addLoadingViewWithOffset:offset];
    [_loadingAndRefreshView setBlankStateWithTitle:title imageStr:imageStr buttonTitle:buttonTitle offset:offset];
    return _loadingAndRefreshView;
}

- (void)refreshClickWithStatus:(LoadingStatus)status {
    
}

- (void)updateLogin {
    
}

// 网络请求，backToSuperView执行后就会取消正在请求的网络
- (void)addNet:(NSURLSessionDataTask *)net {
    if (!_networkOperations) {
        _networkOperations = [[NSMutableArray alloc] init];
    }
    [_networkOperations addObject:net];
}

// 手动释放网络操作队列
- (void)releaseNet {
    for (NSURLSessionDataTask *net in _networkOperations) {
        if ([net isKindOfClass:[NSURLSessionDataTask class]]) {
            [net cancel];
        }
    }
}

// 隐藏导航栏
- (void)setNavigationBarHidden:(BOOL)isHidden {
     [self.navigationController setNavigationBarHidden:isHidden animated:YES];
}

// 设置导航栏字体颜色和背景
+ (void)setNavigationStyle:(UINavigationController*)nav textColor:(UIColor *)textColor barColor:(UIColor *)barColor {
    NSDictionary *dict = @{ NSForegroundColorAttributeName:textColor,
                            NSFontAttributeName:kFontSizeBold18};
    nav.navigationBar.titleTextAttributes = dict;
    nav.navigationBar.barStyle =  UIBaselineAdjustmentNone;//导航条总是多一条线的bug
    [nav.navigationBar setBarTintColor:barColor];
    nav.navigationBar.translucent = NO;
}

#pragma mark - SetRightButton Method
/**
 *  导航栏按钮方法
 *  @param titles       如果是单个按钮名称或图片则返回单个item，多个则返回数组
 *  @param imageNames   按钮图片名数组
 *  @param isRightItems 是否是右边按钮(用来产生按钮间间隔用）
 *  @param titleColor   按钮名字颜色
 *  @param target       按钮代理controller
 *  @param action       按钮方法
 *  @return 单个按钮或多个按钮数组
 */
+ (id)setItemsTitles:(NSArray *)titles imageNames:(NSArray *)imageNames isRightItems:(BOOL)isRightItems titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action {
    NSInteger itemsCount = titles.count > imageNames.count ? titles.count : imageNames.count;
    NSMutableArray *buttonItems = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < itemsCount; i++) {
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        item.tag = (isRightItems ? 1061790 : 1061780) + i;
        if (titles.count) {
            [item setTitle:titles[i] forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            CGFloat titleWidth =[DataHelper widthWithString:titles[i] font:[UIFont boldSystemFontOfSize:13]];
            item.frame = CGRectMake(0, 0, MAX(44, titleWidth), 44);
            [item setTitleColor:titleColor ? titleColor : [UIColor blackColor] forState:UIControlStateNormal];
            item.titleEdgeInsets = isRightItems ? UIEdgeInsetsMake(0, 10 * (1 + 2 * i), 0, -10 * (1 + 2 * i)) : UIEdgeInsetsMake(0, -10 * (1 + 2 * i), 0, 10 * (1 + 2 * i));
        }
        if (imageNames.count) {
            UIImage *image = [UIImage imageNamed:imageNames[i]];
            [item setImage:image forState:UIControlStateNormal];
            item.touchAreaInsets = UIEdgeInsetsMake(20, 5, 20, 5);
            item.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            item.imageEdgeInsets = isRightItems ? UIEdgeInsetsMake(0, -5 * i, 0, 5 * i) : UIEdgeInsetsMake(0, 5 * i, 0, -5 * i);
        }
        [item addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *items = [[UIBarButtonItem alloc]initWithCustomView:item];
        [buttonItems addObject:items];
    }
    return buttonItems.count > 1 ? buttonItems : buttonItems.firstObject;
}



+ (UIBarButtonItem *)rightBarButtonWithName:(NSString *)name imageName:(NSString*)imageName titleColor:(UIColor *)color target:(id)target action:(SEL)action {
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    
    if (imageName && ![imageName isEqualToString:@""]) {
        UIImage *image = [UIImage imageNamed:imageName];
        [btn setImage:image forState:UIControlStateNormal];
        
        UIImage *imageSelected = [UIImage imageNamed:[NSString stringWithFormat:@"%@_s",imageName]];
        if (imageSelected)
            [btn setImage:imageSelected forState:UIControlStateSelected];
        if (ISIOS7) {
            btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        } else {
            btn.frame = CGRectMake(0, 0, image.size.width+20, image.size.height);
        }
    } else {
        float width = [DataHelper widthWithString:name font:kFontSizeBold13];
        width = width < 50?50:width;
        btn.frame=CGRectMake(0, 0, width+15, 30);
    }
    
    if (name && ![name isEqualToString:@""]) {
        [btn setTitle:name forState:UIControlStateNormal];
        btn.titleLabel.font = kFontSizeBold13;
        [btn setTitleColor:color forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateHighlighted];
        [btn setTitleColor:color forState:UIControlStateDisabled];
    }
    if(ISIOS7) {
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, -14);
    }
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

// 自定义导航栏右按钮（图片自定义）
+ (UIBarButtonItem *)rightBarButtonWithName:(NSString *)name imageNormal:(NSString*)imageN imageHlight:(NSString*)imageH target:(id)target action:(SEL)action {
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    if (imageN && ![imageN isEqualToString:@""]) {
        UIImage *image = [UIImage imageNamed:imageN];
        [btn setImage:image forState:UIControlStateNormal];
        
        UIImage *imageSelected = [UIImage imageNamed:imageH];
        if (imageSelected)
        {
            [btn setImage:imageSelected forState:UIControlStateHighlighted];
        }
        
        btn.frame = CGRectMake(0, 0, (ISIOS7 ? image.size.width : image.size.width + 20.0), image.size.height);
    } else {
        btn.frame = CGRectMake(0, 0, 50, 30);
    }
    
    if (name && ![name isEqualToString:@""]) {
        [btn setTitle:name forState:UIControlStateNormal];
        btn.titleLabel.font = kFontSizeBold18;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] forState:UIControlStateDisabled];
    }
    
    if (ISIOS7) {
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
    }
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

#pragma mark - SetLeftButton Mathod
- (UIBarButtonItem *)barBackButton {
    UIImage *image = [UIImage imageNamed :@"nav_back_logo_black"];
    CGRect buttonFrame = CGRectMake(16, (kNavigationHeight - image.size.height) / 2, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(backToSuperView) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    button.titleLabel.font = kFontSize18;
//    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.accessibilityLabel = @"back";
    button.touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

+ (UIBarButtonItem *)leftBarButtonWithName:(NSString *)name imageName:(NSString*)imageName titleColor:(UIColor *)color target:(id)target action:(SEL)action {
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    
    if (imageName && ![imageName isEqualToString:@""]) {
        UIImage *image = [UIImage imageNamed:imageName];
        [btn setImage:image forState:UIControlStateNormal];
        
        UIImage *imageSelected = [UIImage imageNamed:[NSString stringWithFormat:@"%@_s",imageName]];
        if (imageSelected) {
            [btn setImage:imageSelected forState:UIControlStateSelected];
        }
        btn.frame =CGRectMake(16 + image.size.width, 20 + (44 - image.size.height) / 2, image.size.width, image.size.height);
    } else {
        float width = [DataHelper widthWithString:name font:kFontSizeBold13];
        width = width < 50?50:width;
        btn.frame=CGRectMake(0, 0, width+15, 30);
    }
    
    if (name && ![name isEqualToString:@""]) {
        [btn setTitle:name forState:UIControlStateNormal];
        btn.titleLabel.font = kFontSizeBold13;
        [btn setTitleColor:color forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateHighlighted];
        [btn setTitleColor:color forState:UIControlStateDisabled];
    }
    btn.touchAreaInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithCustomView:btn];
    return item;
}

#pragma mark- 点击空白收键盘
// 点击空白处键盘收回
- (void)textFieldReturn {
    // 监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘弹出后在屏幕添加手势，点击空白处收回键盘
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHidden)];
}

// 键盘弹出添加手势
- (void)keyboardWillShow:(NSNotification*)notification {
    [self.view addGestureRecognizer:_tap];
}

// 键盘收回移除手势
- (void)keyboardWillHide:(NSNotification*)notification {
    [self.view removeGestureRecognizer:_tap];
}

// 收回键盘
- (void)keyboardHidden {
    [self.view endEditing:YES];
}

// 销毁键盘弹出通知
- (void)deallocTextFieldNSNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
