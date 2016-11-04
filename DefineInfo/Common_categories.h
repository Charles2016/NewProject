//
//  Common_categories.h
//  HuiXin
//
//  Created by 文俊 on 15/11/20.
//  Copyright © 2015年 mypuduo. All rights reserved.
//  引入iOS-Categories类库文件
//  https://github.com/shaojiankui/iOS-Categories

#ifndef Common_categories_h
#define Common_categories_h

/// NSArray
#import "NSArray+SafeAccess.h"
#import "NSArray+Block.h"

/// NSDictionary
#import "NSDictionary+SafeAccess.h"
#import "NSDictionary+Block.h"
#import "NSDictionary+JSONString.h"

/// NSSet
#import "NSSet+Block.h"

/// NSData
#import "NSData+Base64.h"
#import "NSData+APNSToken.h"

/// NSString
#import "NSString+Base64.h"
#import "NSString+Contains.h"
#import "NSString+DictionaryValue.h"
#import "NSString+hash.h"
#import "NSString+Matcher.h"
#import "NSString+Pinyin.h"
#import "NSString+RegexCategory.h"
#import "NSString+Score.h"
#import "NSString+Size.h"
#import "NSString+Trims.h"
#import "NSString+UrlEncode.h"

/// NSDate
#import "NSDate+Extension.h"
#import "NSDate+Formatter.h"
#import "NSDate+Utilities.h"

/// NSTimer
#import "NSTimer+Addition.h"
#import "NSTimer+Blocks.h"

/// NSURL
#import "NSURL+Param.h"

/// NSUserDefaults
#import "NSUserDefaults+SafeAccess.h"
#import "NSUserDefaults+iCloudSync.h"

/// NSNotificationCenter
#import "NSNotificationCenter+MainThread.h"

/// NSObject
#import "NSObject+AssociatedObject.h"
#import "NSObject+Blocks.h"
#import "NSObject+GCD.h"
#import "NSObject+KVOBlocks.h"

/// UIView
#import "UIView+Frame.h"
#import "UIView+Visuals.h"
#import "UIView+Animation.h"
#import "UIView+BlockGesture.h"
#import "UIView+Find.h"
#import "UIView+GestureCallback.h"
#import "UIView+Recursion.h"
#import "UIView+Shake.h"
#import "UIView+ViewController.h"

/// UIViewController
#import "UIViewController+BackButtonHandler.h"
#import "UIViewController+BackButtonItemTitle.h"

/// UIImage
#import "UIImage+Color.h"
#import "UIImage+Alpha.h"
#import "UIImage+Orientation.h"
#import "UIImage+RemoteSize.h"

/// UIImageView
#import "UIImageView+Addition.h"

/// UILabel
#import "UILabel+AutoSize.h"

/// UIAlertView
#import "UIAlertView+Block.h"

/// UIButton
#import "UIButton+Block.h"
#import "UIButton+Indicator.h"
#import "UIButton+Submitting.h"
#import "UIButton+TouchAreaInsets.h"    //设置按钮额外热区

/// UIColor
#import "UIColor+Gradient.h"
#import "UIColor+HEX.h"
#import "UIColor+Modify.h"
#import "UIColor+Random.h"
#import "UIImage+FX.h"
#import "UIImage+GIF.h"

/// UIControl
#import "UIControl+Block.h"

/// UINavigationItem
#import "UINavigationItem+Lock.h"
#import "UINavigationItem+Margin.h"

/// UINavigationController
#import "UINavigationController+FDFullscreenPopGesture.h"

/// UIScreen
#import "UIScreen+Frame.h"

/// UIScrollView
#import "UIScrollView+Addition.h"

/// UITextField
#import "UITextField+Blocks.h"
#import "UITextField+Select.h"

/// UITextView
#import "UITextView+PlaceHolder.h"
#import "UITextView+Select.h"


#endif /* Common_categories_h */
