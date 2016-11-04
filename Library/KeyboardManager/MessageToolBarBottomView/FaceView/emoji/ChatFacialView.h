//
//  ChatFacialView.h
//  HuiXin
//
//  Created by 文俊 on 13-11-26.
//  Copyright (c) 2013年 mypuduo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FaceReturnKeyType) {
    FaceReturnKeyTypeDone = 0,
    FaceReturnKeyTypeSend = 1
};

@class EmoticonView;
@protocol ChatFaciaViewDelegate;
@interface ChatFacialView : UIView
@property (nonatomic, assign) BOOL isEmoji;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) FaceReturnKeyType returnKeyType;
@property (nonatomic, weak) id<ChatFaciaViewDelegate> delegate;

@end

@protocol ChatFaciaViewDelegate <NSObject>
- (void)chatFaciaView:(ChatFacialView *)chatFaciaView selectedEmoticonView:(EmoticonView *)view;
- (void)chatFaciaView:(ChatFacialView *)chatFaciaView emojiStr:(NSString *)emojiStr;
- (void)chatFaciaViewDidSendButtonClicked:(ChatFacialView *)chatFaciaView;
@end