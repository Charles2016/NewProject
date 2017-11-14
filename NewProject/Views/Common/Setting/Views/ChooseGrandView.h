//
//  ChooseGrandView.h
//  CarMango
//
//  Created by Charles on 4/21/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseGrandView : UIView

@property (nonatomic, copy) void (^completeBlock)(NSInteger buttonIndex);

/**
 *  展示alertView并返回值 0女 1男
 */
+ (instancetype)alertWithChooseGrandComplete:(void (^)(NSInteger buttonIndex))complete;

@end
