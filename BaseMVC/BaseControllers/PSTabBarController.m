//
//  PSTabBarController.m
//  PSDrawerController
//
//  Created by 雷亮 on 16/8/8.
//  Copyright © 2016年 Leiliang. All rights reserved.
//

#import "PSTabBarController.h"
#import "MessageVC.h"
#import "HomeVC.h"
#import "CameraVC.h"
#import "PSDrawerManager.h"

@interface PSTabBarController () <UITabBarControllerDelegate> {
    NSArray *_dataArray;
    NSMutableArray *_viewcontrollers;
}

@end

@implementation PSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.delegate = self;
    _dataArray = @[@[@"HomeVC", @"首页"],
                   @[@"CameraVC", @"相机"],
                   @[@"MessageVC", @"聊天"]];
    _viewcontrollers = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < _dataArray.count; i++) {
        UIViewController *viewController = [[NSClassFromString(_dataArray[i][0]) alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        [SuperVC setNavigationStyle:nav textColor:kColorBlack barColor:kColorLightgray];
        nav.tabBarItem.title = _dataArray[i][1];
        nav.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"tabbar_s_%d",i + 1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nav.tabBarItem.image = [[UIImage imageNamed:[NSString stringWithFormat:@"tabbar_n_%d", i + 1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [[self class] setTableBarItemStyle:nav.tabBarItem];
        [SuperVC setNavigationStyle:nav textColor:kColorBlack barColor:kColorBlue];
        [_viewcontrollers addObject:nav];
    }
    self.viewControllers = _viewcontrollers;
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
    [self.tabBar setShadowImage:[UIImage imageWithColor:kColorClear andSize:self.tabBar.size]];
}

+ (void)setTableBarItemStyle:(UITabBarItem*)tabBarItem {
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3.5);
    UIColor *color = kColorBlack;
    UIColor *colorSelect =kColorBlack;
    UIFont *font = kFontSize10;
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        color, NSForegroundColorAttributeName,
                                        font, NSFontAttributeName, nil]
                              forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        colorSelect, NSForegroundColorAttributeName,
                                        font, NSFontAttributeName, nil]
                              forState:UIControlStateSelected];
    
}

#pragma mark -
#pragma mark - UITabBarController protocol methods
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        /*UINavigationController *navigationController = (UINavigationController *)viewController;
        UIViewController *_viewController = navigationController.viewControllers.firstObject;
        // 如果选中消息页，响应拖拽手势，可以显示侧边栏
        // 否则取消手势响应，不能显示侧边栏
        if ([_viewController isKindOfClass:[MessageVC class]]) {
            [[PSDrawerManager instance] beginDragResponse];
        } else {
            [[PSDrawerManager instance] cancelDragResponse];
        }*/
    }
}


@end
