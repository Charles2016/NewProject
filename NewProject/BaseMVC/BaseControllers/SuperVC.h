//
//  SuperVC.h
//  YueDian
//
//  Created by xiao on 15/3/5.
//  Copyright (c) 2015年 xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadingAndRefreshView;

@interface SuperVC : UIViewController

@property (nonatomic, assign) BOOL isPopToRootVC;
@property (nonatomic, assign) BOOL isCurrentNavHide;// 是否隐藏当前导航栏
@property (nonatomic, assign) NSInteger taBarIndex;// 当设置这个后回到首页改变taBar 1首页 2分类 3购物车 4个人中心
@property (nonatomic, strong) NSMutableArray *networkOperations;
/**
 *  设置导航栏图片标题
 */
- (void)setNavTitleWithImageName:(NSString *)imageName;
#pragma mark - libraryViewMethod
// 某个view附上小红点方法
+ (UILabel *)getRedpoitWithStr:(NSString *)str view:(UIView *)view;

#pragma mark - publicMethod
// 返回上一层
- (void)backToSuperView;
// 登录验证方法
- (void)loginVerifySuccess:(void (^)())success;
+ (void)loginVerifyWithSuccess:(void (^)())success;
+ (UIViewController *)topViewController;

// 加载成功
- (UIView *)loadingSuccess;
// 开始加载转圈view
- (UIView *)loadingStartBgClear;
// 开始加载转圈view,不带背景色，可带往下偏移量
- (UIView *)loadingStartBgClearWithOffset:(CGFloat)offset;
// 开始加载
- (UIView *)loadingStart;
// 开始加载(带头部)
- (UIView *)loadingStartWithOffset:(CGFloat)offset;
// 加载失败未带头部高度
- (UIView *)loadingFail;
- (UIView *)loadingFailWithTitle:(NSString *)title;
- (UIView *)loadingFailWithTitle:(NSString *)title imageStr:(NSString *)imageStr;
// 加载失败带头部高度
- (UIView *)loadingFailWithOffset:(CGFloat)offset;
- (UIView *)loadingFailWithOffset:(CGFloat)offset title:(NSString *)title;
- (UIView *)loadingFailWithOffset:(CGFloat)offset title:(NSString *)title imageStr:(NSString *)imageStr;
// 没有数据未带头部高度
- (UIView *)loadingBlank;
- (UIView *)loadingBlankWithTitle:(NSString *)title;
- (UIView *)loadingBlankWithTitle:(NSString *)title imageStr:(NSString *)imageStr;
// 没有数据带头部高度
- (UIView *)loadingBlankWithOffset:(CGFloat)offset;
- (UIView *)loadingBlankWithOffset:(CGFloat)offset title:(NSString *)title;
- (UIView *)loadingBlankWithOffset:(CGFloat)offset title:(NSString *)title imageStr:(NSString *)imageStr;
- (UIView *)loadingBlankWithOffset:(CGFloat)offset title:(NSString *)title imageStr:(NSString *)imageStr buttonTitle:(NSString *)buttonTitle;
// 子类实现，登录成功后会回调
- (void)updateLogin;
// 网络请求，backToSuperView执行后就会取消正在请求的网络
- (void)addNet:(NSURLSessionDataTask *)net;
// 手动释放网络操作队列
- (void)releaseNet;
// 隐藏导航栏
- (void)setNavigationBarHidden:(BOOL)isHidden;
// 设置导航栏字体颜色和背景
+ (void)setNavigationStyle:(UINavigationController*)nav textColor:(UIColor *)textColor barColor:(UIColor *)barColor;

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
+ (id)setItemsTitles:(NSArray *)titles  imageNames:(NSArray *)imageNames isRightItems:(BOOL)isRightItems titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action;

@end
