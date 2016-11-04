//
//  OwnerView.m
//  GoodHappiness
//
//  Created by chaolong on 16/10/12.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "OwnerView.h"

@interface OwnerView() {
    NSInteger _goodsType;
    NSString *_goodsName;
    UIView *_bgView;
    UIImageView *_gifView;
    UIImageView *_menuView;
    UILabel *_name;
    UIButton *_goToUse;
    UIButton *_seeRecord;
    UIButton *_close;
}

@end

@implementation OwnerView

/**
 *  中奖弹出框初始化
 *  @param goodsType    普通劵or超级劵
 *  @param goodsName    内容中奖名称
 *  @param complete     返回block
 */
+ (instancetype)initWithGoodsType:(NSInteger)goodsType
                        goodsName:(NSString *)goodsName
                         complete:(void (^)(NSInteger buttonIndex))complete {
    OwnerView *ownerView = [[OwnerView alloc]initWithGoodsType:goodsType goodsName:goodsName complete:complete];
    return ownerView;
}

- (id)initWithGoodsType:(NSInteger)goodsType
              goodsName:(NSString *)goodsName
               complete:(void (^)(NSInteger buttonIndex))complete {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _goodsType = goodsType;
        _goodsName = goodsName;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUI];
        });
    }
    return self;
}

- (void)setUI {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.frame = keyWindow.bounds;
    
    _bgView = InsertView(self, CGRectMake(0, 0, 275, 417), kColorClear);
    _bgView.center = self.center;
    
    _menuView = InsertImageView(_bgView, CGRectMake(0, 10, 241, 397), [UIImage imageNamed:@"owner_bg"]);
    
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:_goodsType == 1 ? @"owner_normal" : @"owner_super" ofType:@"gif"];
    _gifView = InsertImageView(_bgView, CGRectMake(0, 0, 275, 250), nil);
    _gifView.gifPath = gifPath;
    [_gifView startGIF];
    _menuView.centerX = _gifView.centerX;
    
    NSString *nameStr = [NSString stringWithFormat:@"成功获得%@", _goodsName];
    _name = InsertLabel(_bgView, CGRectMake(0, _gifView.bottom + 5, _bgView.width, 40), NSTextAlignmentCenter, @"", kFontSize17, kColorBlack, NO);
    _name.attributedText = [DataHelper getColorsInLabel:nameStr colorStrs:@[_goodsName] colors:@[kColorRed] fontSizes:@[@17]];
    
    _goToUse = InsertImageButton(_bgView, CGRectMake(0, _name.bottom + 5, 150, 40), 110120, [UIImage imageNamed:@"owner_gotouse"], nil, self, @selector(buttonAction:));
    
    _seeRecord = InsertImageButtonWithTitle(_bgView, CGRectMake(0, _goToUse.bottom + 5, 150, 40), 110121, nil, nil, @"查看夺劵记录>", UIEdgeInsetsZero, kFontSize13, kColorBlack, self, @selector(buttonAction:));
    _goToUse.centerX = _seeRecord.centerX = _name.centerX;
    
    _close = InsertImageButton(_bgView, CGRectMake(_bgView.width - 25, 0, 25, 25), 110122, [UIImage imageNamed:@"owner_close"], nil, self, @selector(buttonAction:));
    _close.touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyAnimation.values = @[@0.2,@1,@0.85,@1];
    keyAnimation.duration = 0.5f;
    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_bgView.layer addAnimation:keyAnimation forKey:nil];
    _bgView.transform = CGAffineTransformMakeScale(1, 1);
}

- (void)buttonAction:(UIButton *)button {
    if (button.tag == 110120 || button.tag == 110121) {
        // 去使用 or 查看夺劵记录
        NSString *urlStr = button.tag == 110120 ? @"ios:gotoTabbar?index=4" : @"gotoWinner";
        [[NSNotificationCenter defaultCenter] postNotificationName:kPushToAppVC object:@{@"urlStr" : urlStr}];
    }
    // 关闭
    [self removeFromSuperview];
}

@end
