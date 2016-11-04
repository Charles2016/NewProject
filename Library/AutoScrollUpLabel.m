//
//  AutoScrollUpLabel.m
//  GoodHappiness
//
//  Created by Charles on 3/29/16.
//  Copyright © 2016 Charles. All rights reserved.
//

#import "AutoScrollUpLabel.h"

@implementation AutoScrollUpLabel

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer= nil;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

// label文字自动向上滚动，
- (void)setcontentArray:(NSArray *)contentArray idArray:(NSArray *)idArray autoScrollUp:(BOOL)scrollUp clickBlock:(void(^)(NSInteger scrollId, AutoScrollUpClickType type))clickBlock {
    if (!contentArray.count) {
        return;
    }
    _clickBlock = clickBlock;
    _index = 0;
    _contentArray = contentArray;
    _idArray = idArray;
    if ([_contentArray[_index] isKindOfClass:[NSAttributedString class]]) {
        self.attributedText = _contentArray[_index];
    } else {
        self.text = _contentArray[_index];
    }
    _position = self.frame.origin;
    _scrollUp = scrollUp;
    _scrollTime = 3.0;
    if (!_timer) {
        // 初始化计时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:_scrollTime target:self selector:@selector(startPlayAD) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    }
}

#pragma mark - 播放与停止
// 重新播放
- (void)startPlayAD {
    // 此处依赖于NSTimer+Addition
    if (![_timer isValid]) {
        [_timer resumeTimer];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(_position.x, _scrollUp ? _position.y - self.height : _position.y + self.height , self.width, self.height);
    } completion:^(BOOL finished) {
        if (_index < _contentArray.count - 1) {
            _index++;
        } else {
            _index = 0;
        }
        if ([_contentArray[_index] isKindOfClass:[NSAttributedString class]]) {
            self.attributedText = _contentArray[_index];
        } else {
            self.text = _contentArray[_index];
        }
        self.frame = CGRectMake(_position.x, _position.y, self.width, self.height);
    }];
}

// 停止播放
- (void)stopPlayAD {
    // 此处依赖于NSTimer+Addition
    [_timer pauseTimer];
}

// 手势控制
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    //touch.gestureRecognizers
    CGPoint point = [touch locationInView:self];
    
    if (_clickBlock) {
        if (point.x < self.width / 2){
            _clickBlock([_idArray[0][_index] integerValue], AutoScrollUpClickTypePersonName);
        } else {
            _clickBlock([_idArray[1][_index] integerValue], AutoScrollUpClickTypeProductName);
        }
    }
}

@end
