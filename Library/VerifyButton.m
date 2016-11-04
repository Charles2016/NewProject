//
//  VerifyButton.m
//  GoodHappiness
//
//  Created by chaolong on 16/4/14.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "VerifyButton.h"

@interface VerifyButton (){
    NSTimer *_timer;
    NSInteger _count;
    NSString *_verifyStr;
}

@end

@implementation VerifyButton


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _count = 60;
        [self setUI];
    }
    return self;
}

-(void)setUI {
    [self setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.titleLabel.font = kFontSize13;
    [self setTitleColor:kColorBlack forState:UIControlStateNormal];
    [self setTitleColor:kColorDarkgray forState:UIControlStateDisabled];
    [self setBackgroundImage:kButtonImage(@"register_verification") forState:UIControlStateNormal];
    [self setBackgroundImage:kButtonImage(@"register_verification_s") forState:UIControlStateDisabled];
}

- (void)timerStart {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
        [_timer fire];
    }
    self.enabled = NO;
}

- (void)timerAction {
    if (_count != 0) {
        _count--;
        _verifyStr = [NSString stringWithFormat:@"%ld秒后重试", _count];
        [self setTitle:_verifyStr forState:UIControlStateNormal];
    } else {
        _count = 60;
        [_timer invalidate];
        _timer = nil;
        _verifyStr = @"获取验证码";
        self.enabled = YES;
    }
    [self setTitle:_verifyStr forState:UIControlStateNormal];
}

@end
