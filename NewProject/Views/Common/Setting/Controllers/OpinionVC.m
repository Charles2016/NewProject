//
//  OpinionVC.m
//  RacingCarLottery
//
//  Created by dary on 2017/4/21.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "OpinionVC.h"
#import "OpinionModel.h"

@interface OpinionVC () {
    UITextView *_textView;
}

@end

@implementation OpinionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"意见反馈";
    [self setUI];
}

- (void)setUI {
    _textView = InsertTextView(self.view, self, CGRectZero, kFontSize14, NSTextAlignmentLeft);
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.width.equalTo(self.view.mas_width).offset(-20);
        make.height.mas_equalTo(150);
    }];
    _textView.textColor = kColorBlack;
    _textView.backgroundColor = kColorWhite;
    
    UIButton *opinion = InsertButtonWithType(self.view, CGRectZero, 104214, self, @selector(buttonAction), UIButtonTypeCustom);
    [opinion setTitle:@"提交意见" forState:UIControlStateNormal];
    [opinion setBackgroundColor:kColorNavBgFrist];
    opinion.layer.cornerRadius = 5;
    [opinion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_textView.mas_centerX);
        make.top.equalTo(_textView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth - 40, 42 * H_Unit));
    }];
}

- (void)buttonAction {
    if (!_textView.text.length) {
        iToastText(@"请输入您的建议！");
        return;
    }
    // 提交意见
    @weakify(self);
    [OpinionModel getOpinionWithText:_textView.text networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        if (response.Success) {
            @strongify(self);
            iToastText(@"感谢您的建议，你的意见与建议已发送至产品意见箱！");
            [self backToSuperView];
        } else {
            iToastText(response.Msg);
        }
    }];
}

@end
