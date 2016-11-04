//
//  DXChatBarMoreView.h
//  Share
//
//  Created by xieyajie on 14-4-15.
//  Copyright (c) 2014年 Share. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VoiceView;
@protocol DXChatBarMoreViewDelegate;
@interface DXChatBarMoreView : UIView

@property (nonatomic,assign) id<DXChatBarMoreViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) UIView *recordView;//语音view
@property (nonatomic, strong) VoiceView *voiceView;//语音按钮及背景view

- (void)setupSubviews;
//更多按钮会全部创建，这里是对按钮位置进行调整和屏蔽 isChatGroup1群聊 2单聊 3惠粉团队
- (void)isChatGroup:(int)isChatGroup;

@end

@protocol DXChatBarMoreViewDelegate <NSObject>

@required

- (void)moreViewBusinessCardAction:(DXChatBarMoreView *)moreView;
- (void)moreViewPersonalResumeAction:(DXChatBarMoreView *)moreView;
- (void)moreViewPersonalRecruitmentAction:(DXChatBarMoreView *)moreView;
- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView;
- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView;
- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView;
- (void)moreViewAtAction:(DXChatBarMoreView *)moreView;
- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView;

@end
