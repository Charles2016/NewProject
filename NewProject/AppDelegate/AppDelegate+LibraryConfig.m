//
//  AppDelegate+LibraryConfig.m
//  NewProject
//
//  Created by Charles on 4/18/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import "AppDelegate+LibraryConfig.h"

@implementation AppDelegate (LibraryConfig)

- (void)setupLibraryConfigWith:(UIApplication *)application options:(NSDictionary *)launchOptions {
    // app引导页
    if (@available(iOS 11, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

}



@end
