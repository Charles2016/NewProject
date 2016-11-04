//
//  Common_color.h
//  HKC
//
//  Created by zhangshaoyu on 14-10-27.
//  Copyright (c) 2014年 zhangshaoyu. All rights reserved.
//  功能描述：常用颜色

#ifndef HKC_Common_color_h
#define HKC_Common_color_h
#pragma mark - SetColorMethod
// 设置颜色
#define UIColorRGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
// 设置颜色 示例：UIColorHex(0x26A7E8)
#define UIColorHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 设置颜色与透明度 示例：UIColorHEX_Alpha(0x26A7E8, 0.5)
#define UIColorHex_Alpha(rgbValue, al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]
// 设置颜色 示例：UIColorHexStr(@"#7b7b7b");
#define UIColorHexStr(hex)     [DataHelper colorWithHexString:hex]

#pragma mark - CommonColor
// 导航栏背景颜色
#define kColorNavBground UIColorHex(0xf3ee64)
// 深灰色
#define kColorDarkgray UIColorHex(0x666666)
// 淡灰色-如普通界面的背景颜色
#define kColorLightgray UIColorHex(0xeeeeee)
// 灰色—如内容字体颜色
#define kColorgrayContent UIColorHex(0x969696)
// 搜索焦点颜色
#define kTintColorSearch UIColorRGB(2, 162, 253)
// 主题背景色
#define kBackgroundColor UIColorHex(0xf2f2f2)
// cell高亮颜色
#define kCellHightedColor UIColorHex(0xe6e6e9)
// 通用的红色文字颜色
#define kColorFontRed UIColorHex(0xe12228)
// 透明色
#define kColorClear [UIColor clearColor]
// 白色-如导航栏字体颜色
#define kColorWhite UIColorHex(0xffffff)
#define kColorLightWhite UIColorHex(0xf9f9f9)
#define kColorBgWhite UIColorHex(0xfbfbfb)
// 黑色-如输入框输入字体颜色或标题颜色
#define kColorBlack UIColorHex(0x333333)
// 黑色-细黑
#define kColorLightBlack UIColorHex(0x999999)
// 黑色-纯黑
#define kColorDeepBlack UIColorHex(0x000000)
// 灰色—如列表cell分割线颜色样式
#define kColorSeparatorline UIColorHex(0xdddddd)
// 灰色-边框线颜色
#define kColorBorderline UIColorHex(0xb8b8b8)
// 按钮不可用背景色
#define kColorGrayButtonDisable UIColorHex(0xdcdcdc)
// 绿色-如导航栏背景颜色
#define kColorGreenNavBground UIColorHex(0x38ad7a)
// 绿色
#define kColorGreen UIColorHex(0x349c6f)
// 深绿色
#define kColorDarkGreen UIColorHex(0x188d5a)
// 橙色
#define kColorOrange UIColorHex(0xf39700)
// 深橙色
#define kColorDarkOrange UIColorHex(0xe48437)
// 淡紫色
#define kColorLightPurple UIColorHex(0x909af8)
// 红色
#define kColorRed UIColorHex(0xfd492e)
#define kColorLightRed UIColorHex(0xe4393c)
// 蓝色
#define kColorBlue UIColorHex(0x00a0e9)
#define kColorLightBlue UIColorHex(0x3985ff)

#endif
