//
//  SuperNewFeatureVC.m
//  CarShop
//
//  Created by dary on 2017/6/11.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "SuperNewFeatureVC.h"

#import "ADPageControl.h"

@interface SuperNewFeatureVC ()<UIScrollViewDelegate> {
    UIScrollView *_scrollBody;
    ADPageControl *_pageControl;
    int _itemCount;
    NSString *_isFirstTime;
    UIImageView *_bgImageView;
}

@end

@implementation SuperNewFeatureVC

- (instancetype)initWithComplete:(void(^)())complete {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _completeBlock = complete;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI {
    // 第一个启动页页面延续view
    _bgImageView = [[UIImageView alloc] init];
    NSString *imageName = nil;
    NSArray* imagesArray = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    if (imagesArray.count) {
        imageName = imagesArray.lastObject[@"UILaunchImageName"];
    }
    _bgImageView.contentMode = UIViewContentModeScaleToFill;
    _bgImageView.image = [UIImage imageNamed:imageName];
    [self.view addSubview:_bgImageView];
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    // 打开app请求的信息接口
    __weak typeof(self) kWeakSelf = self;
    [self loadUserData:^{
        // 在此做app是否第一次打开判断
        NSString *isFirstTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"kFirstTime"];
        if (isFirstTime) {
            // 非第一次打开只显示启动页
            [kWeakSelf hideAction:NO];
        } else {
            // 第一次打开显示新特性介绍页
            [kWeakSelf setFeatureView];
        }
    }];
    
}

- (void)setFeatureView {
    _scrollBody = [[UIScrollView alloc] init];
    _scrollBody.showsVerticalScrollIndicator = NO;
    _scrollBody.showsHorizontalScrollIndicator = NO;
    _scrollBody.pagingEnabled = YES;
    _scrollBody.alwaysBounceHorizontal = YES;
    _scrollBody.alwaysBounceVertical = NO;
    _scrollBody.backgroundColor = [UIColor whiteColor];
    _scrollBody.delegate = self;
    [self.view addSubview:_scrollBody];
    
    [_scrollBody mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    /*_pageControl = [[ADPageControl alloc] init];
    [_pageControl setPageIndicatorImage:[UIImage imageNamed:@"adScroll_white_point"]];
    [_pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"adScroll_black_point"]];
    [self.view addSubview:_pageControl];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-15);
        make.width.equalTo(self.view);
        make.height.equalTo(@20);
    }];*/
    
    CGSize viewSize = self.view.frame.size;
    for (int i = 0; i < INT_MAX; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"feature_%d", i + 1]];
        if(image) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.tag = 2017061300 + i;
            imageView.frame = (CGRect){{i * viewSize.width, 0} , viewSize};
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"feature_%d", i + 1]];
            [_scrollBody addSubview:imageView];
        } else {
            _itemCount = i;
            UIImage *buttonImage = [UIImage imageNamed:@"feature_button_image"];
            UIButton *button = [[UIButton alloc]initWithFrame:(CGRect){{(self.view.frame.size.width - buttonImage.size.width) / 2 , self.view.frame.size.height - buttonImage.size.height - 55}, buttonImage.size}];
            [button setImage:buttonImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(hideAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 2017061200;
            UIImageView *imageView = [self.view viewWithTag:2017061300 + i - 1];
            imageView.userInteractionEnabled = YES;
            [imageView addSubview:button];
            break;
        }
    }
    [_scrollBody setContentWidth:_itemCount * kScreenWidth];
    _pageControl.numberOfPages =  _itemCount;
    // 保存第一次引用标识
    [[NSUserDefaults standardUserDefaults] setObject:@"kFirstTime" forKey:@"kFirstTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        [self hideAction:YES];
    }
}

#pragma mark - privateMethod
- (void)hideAction:(BOOL)isFirstTime {
    UIImageView *imageView = isFirstTime ? [self.view viewWithTag:2017061300 + _itemCount - 1] : _bgImageView;
    [UIView animateWithDuration:0.8f animations:^{
        imageView.alpha = 0.6f;
        imageView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1);
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        if (_completeBlock) {
            _completeBlock();
        }
    }];
}

#pragma mark - loadData
- (void)loadUserData:(void(^)())finish {
    // 打开app请求的信息接口
    finish();
}

@end
