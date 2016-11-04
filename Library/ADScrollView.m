;
//
//  ADScrollView.m
//  DemoAdvertisement
//
//  Created by zhangshaoyu on 14-7-16.
//  Copyright (c) 2014年 zhangshaoyu. All rights reserved.
//

#import "ADScrollView.h"
#import "ADPageControl.h"
@interface ADScrollView ()<UIScrollViewDelegate> {
    CGRect _adRect;
    UIScrollView *_scrollView;
    NSArray *_imageArray;
    NSArray *_titleArray;
    NSUInteger pageCount;
    UIView *_noteView;
    ADPageControl *_pageControl;
    NSInteger _currentPageIndex;
    UILabel *_noteTitle;
    //    NSTimer *_timer;
    dispatch_source_t _timer;
    BOOL _isADNeedsPlay;
    UILabel * pageLabel;
    UIView * pageView;
}
@end

@implementation ADScrollView

@synthesize delegate;
@synthesize imageSelected;

#pragma mark - 初始化方法
- (id)initWithFrameRect:(CGRect)rect imageArray:(NSArray *)imageArray titleArray:(NSArray *)titleArray {
    if ((self = [super initWithFrame:rect])) {
        self.userInteractionEnabled = YES;
        if (titleArray.count) {
            // 标题数组
            _titleArray = titleArray;
        }
        if (imageArray.count) {
            // 图片数组
            _imageArray = imageArray;
        }
        _adRect = rect;
        
        // 创建滚动广告栏
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, _adRect.size.width, _adRect.size.height)];
        [self addSubview:_scrollView];
        [_scrollView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.1]];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        
        // 说明文字层
        _noteView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height - 33.0,self.bounds.size.width,33.0)];
        [self addSubview:_noteView];
        
        [_noteView setBackgroundColor:UIColorHex_Alpha(0x000000, 0.6)];
        _noteView.userInteractionEnabled = NO;
        
        // 标题
        _noteTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 33.0)];
        [_noteTitle setBackgroundColor:[UIColor clearColor]];
        [_noteTitle setTextAlignment:NSTextAlignmentCenter];
        [_noteTitle setTextColor:UIColorHex(0xdadada)];
        [_noteTitle setFont:[UIFont systemFontOfSize:13.0]];
        [_noteView addSubview:_noteTitle];
        
        pageView = InsertView(self, CGRectMake(0, _scrollView.height - 30, _scrollView.width, 30), kColorBlack);
        pageView.hidden = YES;
        pageView.alpha = 0.8;
        pageLabel = InsertLabel(pageView, CGRectMake(0, 0, pageView.width, pageView.height), NSTextAlignmentCenter, @"", kFontSize11, kColorWhite, NO);
        // 重置广告栏信息
        if (imageArray && 0 != imageArray.count) {
            [self resetScrollViewInfo:imageArray];
        }
    }
	return self;
}

- (void)resetScrollViewInfo:(NSArray *)images {
    if (images.count > 1) {
        // 广告分页层
        _pageControl = [[ADPageControl alloc] init];
        [_pageControl setPageIndicatorImage:[UIImage imageNamed:@"adScroll_white_point"]];
        [_pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"adScroll_black_point"]];
        [self addSubview:_pageControl];
        
        // 初始化计时器, 当只有一张图片时不用滚动
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 3*NSEC_PER_SEC, 0);
        @weakify(self);
        dispatch_source_set_event_handler(_timer, ^{
            @strongify(self);
            [self timerCallScroll];
        });
        dispatch_resume(_timer);
    }
    // 图片数组 原数+2，前后各+1
    if (images.count <= 1) {//当只图片数小于1张时不能滑动
        _scrollView.scrollEnabled = NO;
    } else {
        _scrollView.scrollEnabled = YES;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:images];
    [tempArray insertObject:[images objectAtIndex:([images count] - 1)] atIndex:0]; // +1 首个为原最后一个
    [tempArray addObject:[images objectAtIndex:0]]; // +1 最后一个为原首个
    _imageArray = [NSArray arrayWithArray:tempArray];
    pageCount = [_imageArray count];
    
    // 创建滚动广告栏
    _scrollView.contentSize = CGSizeMake(_adRect.size.width * pageCount, _adRect.size.height);
    for (int i = 0; i < pageCount; i++) {
        UIImageView *imgView = [[UIImageView alloc] init];
        [_scrollView addSubview:imgView];
        NSString *urlStr = [_imageArray objectAtIndex:i];
        
        if ([urlStr hasPrefix:@"http://"]) {
            // 网络图片 请使用ego异步图片库
            NSURL *imageUrl = [NSURL URLWithString:urlStr];
            [imgView sd_setImageWithURL:imageUrl placeholderImage:_placeholderImage];
        } else {
            UIImage *img = [UIImage imageNamed:[_imageArray objectAtIndex:i]];
            [imgView setImage:img];
        }
        
        [imgView setFrame:CGRectMake(_adRect.size.width * i, 0.0, _adRect.size.width, _adRect.size.height)];
        imgView.tag = 100 + i - 1;
        
        // 点击手势
        UITapGestureRecognizer *Tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
        [Tap setNumberOfTapsRequired:1];
        [Tap setNumberOfTouchesRequired:1];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:Tap];
    }
    
    [_scrollView setContentOffset:CGPointZero];
    // 页码控制器
    float pageControlWidth = (pageCount - 2) * 10.0f + 40.f;
    float pagecontrolHeight = 20.0f;
    _pageControl.frame = CGRectMake((self.frame.size.width - pageControlWidth)/2, self.bounds.size.height - pagecontrolHeight, pageControlWidth, pagecontrolHeight);
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = (pageCount - 2);
    _pageControl.pageIndicatorTintColor = UIColorHex_Alpha(0xffffff, 0.7);
    _pageControl.currentPageIndicatorTintColor = kColorRed;
//    pageControl.userInteractionEnabled = YES;
//    [pageControl addTarget:self action:@selector(scrollToPage:) forControlEvents:UIControlEventValueChanged];
    
    pageLabel.text = [NSString stringWithFormat:@"%d/%lu",0,(pageCount - 2)];
    
    [self setPageControlShow];
    
    [self resetNoteTitle];
}

- (void)resetNoteTitle {
    if (_titleArray && 0 != _titleArray.count) {
        [_noteTitle setText:[_titleArray objectAtIndex:0]];
    }
}

- (void)setPageControlFrame {
    if (PageControlCenter == _pageControlMode) {
        float pageControlWidth = (pageCount - 2) * 10.0 + 40.;
        _pageControl.frame = CGRectMake((self.frame.size.width - pageControlWidth) / 2, _pageControl.frame.origin.y, pageControlWidth, _pageControl.frame.size.height);
    } else if (PageControlRight == _pageControlMode) {
        float pageControlWidth = (pageCount - 2) * 10.0 + 40.;
        _pageControl.frame = CGRectMake((self.frame.size.width - pageControlWidth), _pageControl.frame.origin.y, pageControlWidth, _pageControl.frame.size.height);
    }
}

- (void)setPageControlShow {
    _pageControl.hidden = !_showPageControl;
    _pageControl.alpha = 1;//(_showPageControl ? 1.0 : 0.0);
}


- (void)setPageViewShow {
    pageView.hidden = !_showPageView;
}

//- (void)scrollToPage:(UIPageControl *)sender{
//    
//    NSInteger page = sender.currentPage;//获取当前pagecontroll的值
//    [scrollView setContentOffset:CGPointMake(kScreenWidth * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
//}


#pragma mark - set方法

- (void)setImageSources:(NSArray *)newimageSources {
    if (newimageSources.count) {
        _imageSources = newimageSources;
    } else {
        return;
    }
    [self resetScrollViewInfo:_imageSources];
    
    if (_autoPlay) {
        [self autoPlayScroll];
    }
}

- (void)setTitleSources:(NSArray *)newtitleSources {
    _titleSources = newtitleSources;
    
    _titleArray = _titleSources;
    [self resetNoteTitle];
}

- (void)setPageControlMode:(PageControlMode)pagecontrolMode {
    _pageControlMode = pagecontrolMode;
    [self setPageControlFrame];
}

- (void)setShowAlphaBground:(BOOL)showalphaBground {
    _showAlphaBground = showalphaBground;
    _noteView.hidden = !_showAlphaBground;
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl = showPageControl;
    [self setPageControlShow];
}

-(void)setShowPageView:(BOOL)showPageView {
    _showPageView = showPageView;
    [self setPageViewShow];
}


- (void)setPageColor:(UIColor *)pageColor {
    _pageControl.pageIndicatorTintColor = pageColor;
}

-(void)setCurrentPageColor:(UIColor *)currentPageColor {
    _pageControl.currentPageIndicatorTintColor = currentPageColor;
}

- (void)setAutoPlay:(BOOL)newautoplay {
    _autoPlay = newautoplay;
}

- (void)setDragging:(BOOL)canDrag {
    _scrollView.scrollEnabled = canDrag;
}

#pragma mark - 内存管理
- (void)dealloc {
    if (_scrollView) {
        _scrollView.delegate = nil;
        _scrollView = nil;
    }
    if (_noteView) {
        _noteView = nil;
    }
    if (_noteTitle) {
        _noteTitle = nil;
    }
    if (delegate) {
        delegate = nil;
    }
    if (_pageControl) {
        _pageControl = nil;
    }
    if (_imageArray) {
        _imageArray = nil;
    }
    if (_titleArray) {
        _titleArray=nil;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (_imageArray && 0 != _imageArray.count) {
        CGFloat pageWidth = _scrollView.frame.size.width;
        NSInteger page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _currentPageIndex = page;
        
        _pageControl.currentPage = (page - 1);
        
        pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",(page-1),_imageArray.count-2];
        
        NSInteger titleIndex = page - 1;
        if (titleIndex == [_titleArray count]) {
            titleIndex = 0;
        }
        
        if (titleIndex < 0) {
            titleIndex = [_titleArray count] - 1;
        }
        
        [_noteTitle setText:[_titleArray objectAtIndex:titleIndex]];
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_imageArray && 0 != _imageArray.count) {
        if (_currentPageIndex == 0) {
            [_scrollView setContentOffset:CGPointMake(([_imageArray count] - 2) * _adRect.size.width, 0.0)];
        }
        
        if (_currentPageIndex == ([_imageArray count] - 1)) {
            [_scrollView setContentOffset:CGPointMake(_adRect.size.width, 0.0)];
        }
    }
}

#pragma mark - 手势点击
- (void)imagePressed:(UITapGestureRecognizer *)sender {
    if ([delegate respondsToSelector:@selector(ADScrollerViewDidClicked:)]) {
        [delegate ADScrollerViewDidClicked:sender.view.tag - 100];
    }
    if (self.imageSelected) {
        self.imageSelected(sender, sender.view.tag - 100 >= 0 ? sender.view.tag - 100 : 0);
    }
}

#pragma mark - 自动播放
- (void)timerCallScroll {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self autoPlayScroll];
    });
}
#pragma 自动播放
- (void)autoPlayScroll {
    if (!_isADNeedsPlay || _imageArray.count == 1) {
        return;
    }
    if (_imageArray && 0 != _imageArray.count) {
        // 超出范围时，重置
        if (_currentPageIndex == ([_imageArray count] - 1)) {
            _currentPageIndex = 0;
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0.0)];
        }
        // 自动播放scroll
        [_scrollView setContentOffset:CGPointMake(_currentPageIndex * _scrollView.frame.size.width, 0.0) animated:YES];
        // 设置标题
        NSInteger titleIndex = _currentPageIndex - 1;
        if (titleIndex == [_titleArray count]) {
            titleIndex = 0;
        }
        if (titleIndex < 0) {
            titleIndex = [_titleArray count] - 1;
        }
        [_noteTitle setText:[_titleArray objectAtIndex:titleIndex]];
        _currentPageIndex++;
    }
}

#pragma mark - 播放与停止
/// 重新播放
- (void)startPlayAD {
    _isADNeedsPlay = YES;
}

/// 停止播放
- (void)stopPlayAD {
    _isADNeedsPlay = NO;
}

-(NSInteger)getCurrentPage {
    NSInteger page = _currentPageIndex;
    return page;
}

@end
