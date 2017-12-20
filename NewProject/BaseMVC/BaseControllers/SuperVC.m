//
//  SuperVC.m
//  ZQB
//
//  Created by YangXu on 14-7-10.
//
//

#import "SuperVC.h"
#import "SuperTabbarVC.h"
#import "LoginVC.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _taBarIndex = [kTaBarIndex integerValue];
    // 当返回根视图时需要跳转到对应tabar
    // 当设置这个后回到首页改变taBar 1首页 2分类 3购物车 4个人中心
    if (_taBarIndex && [self isTabbarRoot]) {
        [self.tabBarController setSelectedIndex:_taBarIndex - 1];
        self.taBarIndex = 0;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:[self isTabbarRoot] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault];
    self.navigationItem.leftBarButtonItem.customView.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = NO;
    if ([self isTabbarRoot]) {
        self.tabBarController.tabBar.hidden = NO;
    }
    self.isCurrentNavHide = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
}

- (void)setTaBarIndex:(NSInteger)taBarIndex {
    kUserDefaults(@"kTaBarIndex", @(taBarIndex));
    kSynchronize;
}

- (void)setIsCurrentNavHide:(BOOL)isCurrentNavHide {
    _isCurrentNavHide = isCurrentNavHide;
    [self.navigationController setNavigationBarHidden:isCurrentNavHide animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColorWhite;
    [self loadViewData];
    // 监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 键盘弹出后在屏幕添加手势，点击空白处收回键盘
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHidden)];
}

- (void)loadViewData {
    if (ISIOS7) {
        self.tabBarController.tabBar.translucent = NO;// controller中self.view的原点是从导航栏左下角开始计算
        self.edgesForExtendedLayout = UIRectEdgeNone;// 从导航栏底部到tabar顶部
        self.extendedLayoutIncludesOpaqueBars = NO;// 是否空出导航栏位置
        self.automaticallyAdjustsScrollViewInsets = NO;// scrollView空出状态栏位置
    }
    self.navigationItem.leftBarButtonItem = [self isTabbarRoot] ? nil : [[self class] setItemsTitles:nil imageNames:@[@"nav_back_s"] isRightItems:NO titleColor:nil target:self action:@selector(backToSuperView)];
}

/**
 *  设置导航栏图片标题
 */
- (void)setNavTitleWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.size = image.size;
    self.navigationItem.titleView = imageView;
}

#pragma mark - libraryViewMethod
/**
 *  获取小红点方法
 *  @param str      小红点字符
 *  @param view     小红点附着view
 *  @return 小红点label
 */
+ (UILabel *)getRedpoitWithStr:(NSString *)str view:(UIView *)view {
    UILabel *redpoint = InsertLabel(view, CGRectZero, NSTextAlignmentCenter, str, kFontSize10, kColorWhite, NO);
    redpoint.backgroundColor = kColorLightRed;
    redpoint.clipsToBounds = YES;
    CGFloat width = [DataHelper widthWithString:str font:kFontSize10] < 12 ? 12 : [DataHelper widthWithString:str font:kFontSize10];
    if (view) {
        [redpoint mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view.mas_right);
            make.centerY.equalTo(view.mas_top);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(12);
        }];
    }
    redpoint.hidden = redpoint.text.length ? NO : YES;
    redpoint.layer.cornerRadius = 6;
    return redpoint;
}

#pragma mark - publicMethod
// 返回上一层
- (void)backToSuperView {
    // 取消网络请求
    [self releaseNet];
    [self.view endEditing:YES];
    if (self.navigationController.viewControllers.firstObject == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
        // 为了跳转消息页面后能返回
        [self.navigationController popViewControllerAnimated:YES];
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
        UIViewController *currentVC = [self topViewController];
        LoginVC *VC = [[LoginVC alloc] init];
        if (success) {
            VC.successBlock = success;
        }
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
        [SuperVC setNavigationStyle:nav textColor:kColorBlack barColor:kColorWhite];
        [currentVC presentViewController:nav animated:YES completion:nil];
    }
}
                                       
+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self getTopViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self getTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)getTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
       return vc;
    }
    return nil;
}

- (void)addLoadingViewWithOffset:(CGFloat)offset {
    if (!_loadingAndRefreshView) {
        CGFloat height = [self isTabbarRoot] ? kMiddleHeight : self.view.height;
        _loadingAndRefreshView = [[LoadingAndRefreshView alloc] initWithFrame:CGRectMake(0, offset, kScreenWidth, height - offset)];
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

#pragma mark -

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
    nav.navigationBar.barStyle =  UIBaselineAdjustmentAlignBaselines;//导航条总是多一条线的bug
    [nav.navigationBar setBarTintColor:barColor];
    nav.navigationBar.translucent = NO;
}

#pragma mark - setNavButtonMethod
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
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = (isRightItems ? 1061790 : 1061780) + i;
        if (titles.count) {
            if ([titles[i] length]) {
                [button setTitle:titles[i] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
                CGSize size = [button.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:button.titleLabel.font} context:nil].size;
                button.frame = CGRectMake(0, 0, MAX(64.0 / itemsCount, size.width + 10), 44);
                [button setTitleColor:titleColor ? titleColor : [UIColor blackColor] forState:UIControlStateNormal];
                button.titleEdgeInsets = isRightItems ? UIEdgeInsetsMake(0, button.frame.size.width - size.width, 0, 0) : UIEdgeInsetsMake(0, -button.frame.size.width + size.width, 0, 0);
            }
        }
        if (imageNames.count) {
            if ([imageNames[i] length]) {
                UIImage *image = [UIImage imageNamed:imageNames[i]];
                [button setImage:image forState:UIControlStateNormal];
                button.touchAreaInsets = UIEdgeInsetsMake(20, 5, 20, 5);
                button.frame = CGRectMake(0, 0, MAX(64.0 / itemsCount, image.size.width), MAX(44, image.size.height));
                button.imageEdgeInsets = isRightItems ? UIEdgeInsetsMake(0, button.frame.size.width - image.size.width, 0, 0) : UIEdgeInsetsMake(0, -button.frame.size.width + image.size.width, 0, 0);
            }
        }
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *items = [[UIBarButtonItem alloc]initWithCustomView:button];
        [buttonItems addObject:items];
    }
    return buttonItems.count > 1 ? buttonItems : buttonItems.firstObject;
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
