//
//  DXRecordView.m
//  Share
//
//  Created by dujiepeng on 14-3-4.
//  Copyright (c) 2014年 Share. All rights reserved.
//

#import "DXRecordView.h"

#define BackViewWidth 150.0f
#define BackViewHeight 150.0f
#define BackViewTopMargin 120.0f
#define LabelHeight 20
#define LabelTop 15
#define LabelFont [UIFont systemFontOfSize:12.0f]

#define RECORDING_IMAGE [UIImage imageNamed:@"chat_record_wave001"]     //背景
#define RECORD_CANCEL_IMAGE [UIImage imageNamed:@"chat_record_cancel"]  //取消
#define RECORD_TIME_WARN [UIImage imageNamed:@"chat_record_warn"]       //警告
#define RECORD_WAVE_IMAGE(text) [UIImage imageNamed:[NSString stringWithFormat:@"chat_record_wave00%@", text]]      //波动



@interface DXRecordView ()
{
    UIImageView *_recordView;
    UILabel *_tipLabel;
    BOOL _pressButton;
}

@end

@implementation DXRecordView

- (id)init
{
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.progress = 0.f;
        
        [self createMainUI];
    }
    return self;
}

-(void)createMainUI {
    self.backgroundColor = UIColorHex_Alpha(0x000000, 0.5);
    self.layer.cornerRadius = 14.0;
    self.layer.masksToBounds = YES;
    self.frame = CGRectMake((kScreenWidth - BackViewWidth) / 2, BackViewTopMargin, BackViewWidth, BackViewHeight);
    
    CGRect frame = CGRectMake((self.width - RECORDING_IMAGE.size.width)/2, (self.height - RECORDING_IMAGE.size.height)/4, RECORDING_IMAGE.size.width, RECORDING_IMAGE.size.height);
    _recordView = [[UIImageView alloc] initWithFrame:frame];
    _recordView.image = RECORDING_IMAGE;
    [self addSubview:_recordView];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, BackViewWidth-LabelHeight-LabelTop, BackViewWidth-20, LabelHeight)];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.layer.cornerRadius = 5.0;
    _tipLabel.layer.masksToBounds = YES;
    _tipLabel.font = LabelFont;
    [self addSubview:_tipLabel];

}

- (void)setProgress:(float)progress
{
    if (_pressButton) {
        NSString *volumeStr = [NSString stringWithFormat:@"%.lf", progress*50];
        if (volumeStr.integerValue > 6) {
            volumeStr = @"6";
        } else if (volumeStr.integerValue < 1){
            volumeStr = @"1";
        }
        DLog(@"progress:%lf  volume：%@", progress, volumeStr);
        _recordView.image = RECORD_WAVE_IMAGE(volumeStr);
    }
}

// 录音按钮按下
-(void)recordButtonTouchDown
{
    // 需要根据声音大小切换recordView动画
    _pressButton = YES;
    _recordView.image = RECORDING_IMAGE;
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.text = @"手指上划，取消发送";
    
}

// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside
{
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
}

// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside
{
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
}

// 手指移动到录音按钮内部
-(void)recordButtonDragInside
{
    _pressButton = YES;
    _recordView.image = RECORDING_IMAGE;
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.text = @"手指上划，取消发送";
}

// 手指移动到录音按钮外部
-(void)recordButtonDragOutside
{
    _pressButton = NO;
    _recordView.image = RECORD_CANCEL_IMAGE;
    _tipLabel.text = @"松开手指，取消发送";
    _tipLabel.backgroundColor = UIColorHex(0xa43533);
    
}

// 显示录音时间太短
-(void)recordButtonShowTimeCancel
{
    _recordView.image = RECORD_TIME_WARN;
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.text = @"说话时间太短";
}

//剩余时间
- (void)updateLeftTime:(CGFloat)leftTime
{
    if (leftTime <= 11) {
        _tipLabel.text = [NSString stringWithFormat:@"%@%ld%@", @"录音时间还有", (long)leftTime, @"秒"];
    }
    if (leftTime <= 0.0) {
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1];
    }
}

@end
