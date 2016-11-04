//
//  BaseTableViewCell.m
//  ZQB
//
//  Created by YangXu on 14-7-18.
//
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCell()
{
    SeperateStyle _currentSpStyle;
    UIView *_lineT;
    UIView *_lineB;
}

@end

@implementation BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected status
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect;
    
    rect = _lineT.frame;
    rect.origin = CGPointMake(0, 0);
    _lineT.frame = rect;
    
    rect = _lineB.frame;
    rect.origin = CGPointMake(rect.origin.x, self.height - kSPLineH);
    _lineB.frame = rect;
}

/// 短线默认缩进 10px
- (void)setSeperateStyle:(SeperateStyle)style {
    [self setSeperateStyle:style shortLineInset:kDefaultShortLineInset];
}

- (void)clearOrInitLineView {
    // 没有就创建
    if (!_lineT) {
        _lineT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kSPLineH)];
        _lineT.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _lineT.backgroundColor = kColorSeparatorline;
    }
    if (!_lineB) {
        _lineB = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kSPLineH, self.width, kSPLineH)];
        _lineB.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _lineB.backgroundColor = kColorSeparatorline;
    }
    // 从父视图移除
    if (_lineT.superview) {
        [_lineT removeFromSuperview];
    }
    if (_lineB.superview) {
        [_lineB removeFromSuperview];
    }
}

- (void)adjustLineInset:(UIView *)lineView style:(SeperateStyle)style inset:(CGFloat)inset {
    if (!lineView) {
        return;
    }
    // 恢复原状态
    lineView.frame = CGRectMake(0, lineView.top, self.width, lineView.height);
    if (style == SeperateStyle_LTLB || style == SeperateStyle_NTLB) {
        return;
    }
    lineView.frame = CGRectMake(inset, lineView.top, self.width - inset, lineView.height);
}

/// 自定义短线缩进
- (void)setSeperateStyle:(SeperateStyle)style shortLineInset:(CGFloat)inset {
    if (style == _currentSpStyle) {
        return;
    }
    _currentSpStyle = style;
    // 先清除
    [self clearOrInitLineView];
    // 调整 _lineB frame
    [self adjustLineInset:_lineB style:style inset:inset];
    switch (style) {
        case SeperateStyle_LTLB:
        case SeperateStyle_LTSB: {
            [self addSubview:_lineT];
            [self addSubview:_lineB];
        }
            break;
        case SeperateStyle_LTNB: {
            [self addSubview:_lineT];
        }
            break;
        case SeperateStyle_NTLB:
        case SeperateStyle_NTSB: {
            [self addSubview:_lineB];
        }
            break;
        default:
            break;
    }
}

- (void)setSeperateStyleWithDataSourceCount:(NSInteger)count rowIndex:(NSInteger)rowIndex {
#if 0
    if (count == 1) {
        [self setSeperateStyle:SeperateStyle_LTLB];
    } else if (count == 2) {
        [self setSeperateStyle:rowIndex == 0?SeperateStyle_LTSB:SeperateStyle_NTLB];
    } else {
        if (0 == rowIndex) {
            [self setSeperateStyle:SeperateStyle_LTSB];
        } else if (count - 1 == rowIndex) {
            [self setSeperateStyle:SeperateStyle_NTLB];
        } else {
            [self setSeperateStyle:SeperateStyle_NTSB];
        }
    }
#endif
    [self setSeperateCustomInsetStyleWithDataSourceCount:count rowIndex:rowIndex inset:kDefaultShortLineInset];
}

/// 没有缩进
- (void)setSeperateNoInsetStyleWithDataSourceCount:(NSInteger)count rowIndex:(NSInteger)rowIndex {
    [self setSeperateCustomInsetStyleWithDataSourceCount:count rowIndex:rowIndex inset:0];
}

/// 自定义缩进
- (void)setSeperateCustomInsetStyleWithDataSourceCount:(NSInteger)count rowIndex:(NSInteger)rowIndex inset:(CGFloat)inset {
    if (count == 1) {
        [self setSeperateStyle:SeperateStyle_LTLB shortLineInset:inset];
    } else if (count == 2) {
        [self setSeperateStyle:rowIndex == 0?SeperateStyle_LTSB:SeperateStyle_NTLB shortLineInset:inset];
    } else {
        if (0 == rowIndex) {
            [self setSeperateStyle:SeperateStyle_LTSB shortLineInset:inset];
        } else if (count - 1 == rowIndex) {
            [self setSeperateStyle:SeperateStyle_NTLB shortLineInset:inset];
        } else {
            [self setSeperateStyle:SeperateStyle_NTSB shortLineInset:inset];
        }
    }
}

@end
