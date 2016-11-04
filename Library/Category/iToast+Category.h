//
//  iToast+Category.h
//  HKIMDemo
//
//  Created by Charles on 15/10/19.
//  Copyright © 2015年 HuiKaSJi. All rights reserved.
//

#import "iToast.h"

#define iToastText(txt) [iToast alertWithTitle:txt]
/// txtMain主要内容（为空时将显示txtMinor)
#define iToastMakeShow(txtMain,txtMinor) [iToast alertWithTitle:(txtMain.length > 0) ? txtMain : txtMinor]

@interface iToast (Category)

+ (iToast *)alertWithTitle:(NSString *)title;
+ (iToast *)alertWithTitleCenter:(NSString *)title;
+ (iToast *)alertWithTitleBottom:(NSString *)title;
//显示iToast自定义位置和时间
+ (iToast *)alertWithTitle:(NSString *)title gravity:(iToastGravity)gravity duration:(NSInteger)duration;

@end
