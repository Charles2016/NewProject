//
//  SuperTabbarVC.m
//  CarShop
//
//  Created by Charles on 4/17/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "SuperTabbarVC.h"
#import "BufferedNavigationController.h"

@interface SuperTabbarVC () <UITabBarControllerDelegate> {
    NSMutableArray *_viewcontrollers;
}

@end

@implementation SuperTabbarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    [self setUI];
}

-(void)setUI {
    NSArray *views = @[@[@"HomeVC", @"ClassifyVC", @"ShoppingCarVC", @"MineVC"],
                       @[@"首页", @"分类", @"购物车", @"我的"]];
    _viewcontrollers = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < [views[0] count]; i ++) {
        // 导航栏设置
        BufferedNavigationController *nav = [[BufferedNavigationController alloc]initWithRootViewController:[NSClassFromString(views[0][i]) new]];
        /*[nav.navigationBar setBackgroundImage:[UIImage imageWithColor:kColorClear andSize:self.tabBar.size] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setBackIndicatorTransitionMaskImage:[UIImage imageWithColor:kColorClear andSize:nav.navigationBar.size]];
        [nav.navigationBar setShadowImage:[UIImage imageWithColor:kColorClear andSize:nav.navigationBar.size]];*/
        [SuperVC setNavigationStyle:nav textColor:kColorBlack barColor:kColorWhite];
        // 底部菜单栏设置
        nav.tabBarItem = [[UITabBarItem alloc]initWithTitle:views[1][i] image:nil tag:i];
        nav.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"tabbar_s_%d",i + 1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nav.tabBarItem.image = [[UIImage imageNamed:[NSString stringWithFormat:@"tabbar_n_%d",i+1 ]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [[self class] setTableBarItemStyle:nav.tabBarItem];
        
        [_viewcontrollers addObject:nav];
    }
    self.viewControllers = _viewcontrollers;
    
    /*[self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
    [self.tabBar setShadowImage:[UIImage imageWithColor:kColorClear andSize:self.tabBar.size]];*/
}

+ (void)setTableBarItemStyle:(UITabBarItem *)tabBarItem {
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3.5);
    UIColor *color = UIColorHex(0x888888);
    UIColor *colorSelect =kColorBlue;
    UIFont *font = kFontSize10;
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        color, NSForegroundColorAttributeName,
                                        font, NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        colorSelect, NSForegroundColorAttributeName,
                                        font, NSFontAttributeName, nil]
                              forState:UIControlStateSelected];
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:( UIViewController *)viewController {
    BOOL canSelect = YES;
    /*if ([viewController isEqual:_viewcontrollers.lastObject]) {
        // 点击我的模块做登陆判断
        if (GetDataUserModel.isLogin) {
            canSelect = YES;
        } else {
            @weakify(self);
            [SuperVC loginVerifyWithSuccess:^{
                @strongify(self);
                [self setSelectedIndex:self.viewControllers.count - 1];
            }];
            canSelect = NO;
        }
    }*/
    return canSelect;
}

@end
