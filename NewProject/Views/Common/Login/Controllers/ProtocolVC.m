//
//  ProtocolVC.m
//  RacingCarLottery
//
//  Created by dary on 2017/5/12.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "ProtocolVC.h"
#import <WebKit/WebKit.h>

@interface ProtocolVC () {
    NSURL *_url;
    WKWebView *_webView;
}

@end

@implementation ProtocolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColorWhite;
    self.navigationItem.title = @"用户协议";
    NSArray *titleArray = @[@"注册协议", @"多得彩平台服务协议", @"法律申明及隐私权政策"];
    for (int i = 0; i < 3; i++) {
        UIButton *button = InsertButton(self.view, CGRectZero, 2017051205 + i, self, @selector(buttonAction:), UIButtonTypeCustom);
        if (i == 0) {
            [self buttonAction:button];
        }
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = kFontSizeBold15;
        [button setTitleColor:kColorNavBgFrist forState:UIControlStateNormal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(30);
            make.top.equalTo(self.view.mas_top).offset(10 + 30 * i);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth - 50, 30));
        }];
        
        UIView *point = InsertView(self.view, CGRectZero, kColorNavBgFrist);
        point.clipsToBounds = YES;
        point.layer.cornerRadius = 5;
        [point mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(button.mas_centerY);
            make.left.equalTo(self.view.mas_left).offset(15);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
    }
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 120, kScreenWidth, kBodyHeight - 120)];
    _webView.backgroundColor = kColorWhite;
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    [_webView sizeToFit];
    [self.view addSubview:_webView];
}

#pragma mark - privateMethod
- (void)buttonAction:(UIButton *)button {
    NSInteger tag = button.tag - 2017051204;
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"protocol%ld", tag] ofType:@"doc"];
    _url = [NSURL fileURLWithPath:path];
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

@end
