//
//  AutoScrollUpLabel.h
//  GoodHappiness
//
//  Created by Charles on 3/29/16.
//  Copyright © 2016 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AutoScrollUpClickType) {
    AutoScrollUpClickTypePersonName = 1,// 点击人名
    AutoScrollUpClickTypeProductName// 点击商品名
};

@interface AutoScrollUpLabel : UILabel {
    NSTimer *_timer;
    NSArray *_contentArray;
    NSArray *_idArray;
    CGPoint _position;
    NSInteger _index;
    BOOL _scrollUp;
    CGFloat _scrollTime;
}

@property (nonatomic, copy) void (^clickBlock)(NSInteger index, AutoScrollUpClickType type);

// label文字自动向上滚动，
- (void)setcontentArray:(NSArray *)contentArray idArray:(NSArray *)idArray autoScrollUp:(BOOL)scrollUp clickBlock:(void(^)(NSInteger scrollId, AutoScrollUpClickType type))clickBlock;

@end
