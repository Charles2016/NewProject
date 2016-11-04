//
//  NewFeatureView.m
//  HuiXin
//
//  Created by hucheng on 15/12/18.
//  Copyright © 2015年 惠卡世纪. All rights reserved.
//

#import "NewFeatureView.h"
#import "ADPageControl.h"

@interface NewFeatureView ()<UIScrollViewDelegate> {
    UIScrollView *_scrollBody;
    ADPageControl *_pageControl;
    UIButton *_button;
    int _itemCount;
    UIImageView *_bgImageView;
}

@end

@implementation NewFeatureView

- (void)dealloc {
    if (_scrollBody) {
        _scrollBody.delegate = nil;
        _scrollBody = nil;
    }
    if (_pageControl) {
        _pageControl = nil;
    }
    if (_button) {
        _button = nil;
    }
    if (_bgImageView) {
        _bgImageView = nil;
    }
    DLog(@"%@释放了",NSStringFromClass(self.class));
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _itemCount = 3;
        [self setUI];
        
        [self addSubview:_bgImageView];
    }
    return self;
}

- (void)setUI {
    self.backgroundColor = [UIColor whiteColor];
    _scrollBody = [[UIScrollView alloc] init];
    _scrollBody.showsVerticalScrollIndicator = NO;
    _scrollBody.showsHorizontalScrollIndicator = NO;
    _scrollBody.pagingEnabled = YES;
    _scrollBody.alwaysBounceHorizontal = YES;
    _scrollBody.alwaysBounceVertical = NO;
    _scrollBody.backgroundColor = [UIColor whiteColor];
    _scrollBody.delegate = self;
    
    _pageControl = [[ADPageControl alloc] init];
    [_pageControl setPageIndicatorImage:[UIImage imageNamed:@"adScroll_white_point"]];
    [_pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"adScroll_black_point"]];
    
    _bgImageView = [[UIImageView alloc] init];
    NSString *imageName;
    if (ISiPhone4) {
        imageName = @"window_bg4";
    } else if (ISiPhone5) {
        imageName = @"window_bg5";
    } else if (ISiPhone6) {
        imageName = @"window_bg6";
    } else if (ISiPhone6plus) {
        imageName = @"window_bg6p";
    }
    _bgImageView.image = [UIImage imageNamed:imageName];
    
    [self addSubview:_scrollBody];
    [self addSubview:_pageControl];
    [self addSubview:_bgImageView];
    
    @weakify(self);
    [_scrollBody mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self);
    }];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-15);
        make.width.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self);
    }];
    
    [self loadData];
}

- (void)loadData {
    CGSize viewSize = self.frame.size;
    for (int i=0; i<_itemCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        imageView.frame = (CGRect){{i * viewSize.width, 0} , viewSize};
        
        NSString *name = nil;
        if (ISiPhone5 || ISiPhone6 || ISiPhone6plus) {
            name = [NSString stringWithFormat:@"feature%d_568h", i + 1];
        } else {
            name = [NSString stringWithFormat:@"feature%d", i + 1];
        }
        imageView.image = [UIImage imageNamed:name];
        [_scrollBody addSubview:imageView];
        if (i == _itemCount - 1) {
            imageView.userInteractionEnabled = YES;
            UIImage *image = [UIImage imageNamed:@"feature_button_image"];
            _button = [[UIButton alloc]initWithFrame:(CGRect){{(self.width - image.size.width) / 2 , self.height - image.size.height - 75}, image.size}];
            [_button setImage:image forState:UIControlStateNormal];
            [_button addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:_button];
        }
    }
    [_scrollBody setContentWidth:_itemCount * kScreenWidth];
    _pageControl.numberOfPages =  _itemCount;
    
   
}

- (void)setNewFeatureFinish:(BOOL)finish {
    if (finish) {
        _pageControl.hidden = _scrollBody.hidden = NO;
        _bgImageView.hidden = YES;
    } else {
        _pageControl.hidden = _scrollBody.hidden = YES;
        _bgImageView.hidden = NO;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int currentPage = scrollView.contentOffset.x / kScreenWidth;
    if (currentPage > 1) {
        scrollView.bounces = YES;
    }else{
        scrollView.bounces = NO;
    }
    _pageControl.currentPage = currentPage;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ((_itemCount - 1) * kScreenWidth < scrollView.contentOffset.x) {
        [self start];
    }
}

#pragma mark - Private
- (void)start {
    UIImageView *imgView = (UIImageView *)[_scrollBody viewWithTag:_itemCount - 1];
    CGRect rect = imgView.frame;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    rect.size.width = width *2;
    rect.size.height = height *2;
    rect.origin.x = rect.origin.x - width/2;
    rect.origin.y = rect.origin.y - height/2;
    
    @weakify(self);
    [UIView animateWithDuration:0.5 animations:^{
        @strongify(self);
        imgView.frame = rect;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
}

@end
