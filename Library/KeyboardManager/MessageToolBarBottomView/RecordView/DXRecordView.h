//
//  DXRecordView.h
//  Share
//
//  Created by dujiepeng on 14-3-4.
//  Copyright (c) 2014年 Share. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXRecordView : UIView

@property(nonatomic) float progress;

// 录音按钮按下
-(void)recordButtonTouchDown;
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside;
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside;
// 手指移动到录音按钮内部
-(void)recordButtonDragInside;
// 手指移动到录音按钮外部
-(void)recordButtonDragOutside;
// 显示录音时间太短
-(void)recordButtonShowTimeCancel;
//剩余时间
- (void)updateLeftTime:(CGFloat)leftTime;


@end
