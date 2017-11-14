//
//  SuperNewFeatureVC.h
//  CarShop
//
//  Created by dary on 2017/6/11.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuperNewFeatureVC : UIViewController

@property (nonatomic, copy) void (^completeBlock)();

- (instancetype)initWithComplete:(void(^)())complete;

@end
