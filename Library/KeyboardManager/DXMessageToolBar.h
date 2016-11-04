//
//  DXMessageToolBar.h
//  Share
//
//  Created by dhcdht on 14-5-22.
//  Copyright (c) 2014年 Share. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "ChatFacialView.h"
#import "FacialView.h"
#import "DXMessageTextView.h"

typedef NS_ENUM(NSInteger, KeyboardStyle)
{
    KeyboardStyleChat = 0,          //聊天键盘(默认)
    KeyboardStyleComment = 1,       //评论键盘
    KeyboardStylePublish            //发布键盘
};

/**
 *  类说明：
 *  1、推荐使用[initWithFrame:...]方法进行初始化
 *  2、提供默认的录音，表情，更多按钮的附加页面
 *  3、可自定义以上的附加页面
 *  4、KeyboardStylePublish 必须实现代理5
 *  5、KeyboardStyleChat 必须实现代理1-4，7-12
 *  6、KeyboardStyleComment 必须实现代理1-4
 */

@protocol DXMessageToolBarDelegate;
@interface DXMessageToolBar : UIView

@property (nonatomic, weak) id <DXMessageToolBarDelegate> delegate;
/// 背景图片
@property (nonatomic, strong) UIImage *backgroundImage;
/// 更多的附加页面
@property (nonatomic, strong) DXChatBarMoreView *moreView;
/// 表情的附加页面
@property (nonatomic, strong) ChatFacialView *faceView;
/// 录音的附加页面
@property (nonatomic, strong) UIView *recordView;
/// 用于输入文本消息的输入框
@property (nonatomic, strong) DXMessageTextView *inputTextView;
/// 按钮、输入框、toolbarView
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) UIButton *styleChangeButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *faceButton;
@property (nonatomic, strong) UIButton *recordButton;

/// 初始化方法附带键盘样式
- (instancetype)initWithFrame:(CGRect)frame style:(KeyboardStyle)style;
/// 不能直接inputTextView.text = xxx;输入框的高度会有BUG
- (void)setInputText:(NSString*)text;
/// 高度改变方法
- (void)textViewDidChange:(UITextView *)textView;
/// 获取默认高度
+ (CGFloat)defaultHeight;

@end

@protocol DXMessageToolBarDelegate <NSObject>

@optional

- (void)textViewDidChange:(UITextView *)textView;
/// 1.文字输入框将要开始编辑
- (void)inputTextViewWillBeginEditing:(UITextView *)inputTextView;
/// 2.文字输入框增减字符
- (BOOL)inputTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
/// 3.发送文字消息，可能包含系统自带表情
- (BOOL)didSendText:(NSString *)text;
/// 4.高度变到toHeight
- (void)didChangeFrameToHeight:(CGFloat)toHeight;
/// 5.选中表情返回的字符(如:[开心])
- (void)chooseFaceText:(NSString *)faceText;
/// 6.按下录音按钮开始录音
- (void)didStartRecordingVoiceAction:(UIView *)recordView;
/// 7.手指向上滑动取消录音
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;
/// 8.松开手指完成录音
- (void)didFinishRecoingVoiceAction:(UIView *)recordView;
/// 9.当手指离开按钮的范围内时，主要为了通知外部的HUD
- (void)didDragOutsideAction:(UIView *)recordView;
/// 10.当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
- (void)didDragInsideAction:(UIView *)recordView;
/// 11.设置更多按钮栏代理
- (void)setMoreViewDelegate;
/// 修复第三方键盘消失通知
- (void)textViewWillHide;

@end
