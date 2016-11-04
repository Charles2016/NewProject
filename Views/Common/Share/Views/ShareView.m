//
//  ShareView.m
//  GoodHappiness
//
//  Created by chaolong on 16/5/17.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "ShareView.h"
#import "ShareModel.h"

@interface ShareView() <UIGestureRecognizerDelegate> {
    UIView *_menuView;
    UIImageView *_imageView;
    NSString *_shareTitle;
    NSString *_shareUrl;
    NSString *_shareTxt;
    NSString *_shareImg;
    NSString *_action;
    NSInteger _shareId;
}

@end

@implementation ShareView

/**
 *  带参数分享
 *  @param shareTitle 标题
 *  @param shareUrl   分享链接
 *  @param shareTxt  分享内容
 *  @param shareImg 分享图片
 */
+ (instancetype)initWithShareTitle:(NSString *)shareTitle
                          shareUrl:(NSString *)shareUrl
                         shareTxt:(NSString *)shareTxt
                        shareImg:(NSString *)shareImg
                          complete:(void (^)(NSInteger buttonIndex))complete {
    ShareView *shareView = [[ShareView alloc] initWithShareTitle:shareTitle shareUrl:shareUrl shareTxt:shareTxt shareImg:shareImg complete:complete];
    return shareView;
}

/**
 *  直接弹出shareView样式（参数之后请求接口所得）
 *  不带参数分享初始化方法
 *  @param shareFromType 分享View样式
 *  @param action  分享入口feed:朋友圈 shop:商城 period:礼券 exchange:兑换记录 award:中奖记
 *  @param shareId 对应Id
 */
+ (instancetype)initWithShareFromType:(ShareFromType)shareFromType
                               action:(NSString *)action
                              shareId:(NSInteger)shareId
                             complete:(void (^)(NSInteger buttonIndex))complete {
    ShareView *shareView = [[ShareView alloc] initWithShareTitle:@"" shareUrl:@"" shareTxt:@"" shareImg:@"" shareFromType:shareFromType action:action shareId:shareId complete:complete];
    return shareView;
}

/**
 *  带参数分享初始化方法（不用请求接口直接分享）
 *  @param shareTitle 标题
 *  @param shareUrl   分享链接
 *  @param shareTxt  分享内容
 *  @param shareImg 分享图片
 */
- (instancetype)initWithShareTitle:(NSString *)shareTitle
                          shareUrl:(NSString *)shareUrl
                         shareTxt:(NSString *)shareTxt
                        shareImg:(NSString *)shareImg
                          complete:(void (^)(NSInteger buttonIndex))complete {
    return [self initWithShareTitle:shareTitle shareUrl:shareUrl shareTxt:shareTxt shareImg:shareImg shareFromType:ShareFromTypeOther action:@"" shareId:0 complete:complete];
}

/**
 *  带参数模块分享
 *  @param shareTitle 标题
 *  @param shareUrl   分享链接
 *  @param shareTxt  分享内容
 *  @param shareImg 分享图片
 *  @param shareFromType 分享显示样式
 */
- (instancetype)initWithShareTitle:(NSString *)shareTitle
                          shareUrl:(NSString *)shareUrl
                         shareTxt:(NSString *)shareTxt
                        shareImg:(NSString *)shareImg
                     shareFromType:(ShareFromType)shareFromType
                            action:(NSString *)action
                           shareId:(NSInteger)shareId
                          complete:(void (^)(NSInteger buttonIndex))complete {
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        _completeBlock = complete;
        _shareTitle = shareTitle;
        _shareUrl = shareUrl;
        _shareTxt = shareTxt;
        _shareImg = shareImg;
        _shareFromType = shareFromType;
        _action = action;
        _shareId = shareId;
        [self setUI];
    }
    return self;
}

- (void)setUI {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
    self.backgroundColor = UIColorHex_Alpha(0x000000, 0.6);
    // 用来接收分享图片
    _imageView = [UIImageView new];
    
    _menuView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 271)];
    _menuView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_menuView];
    NSArray *titleTemArray = @[@"QQ", @"QQ空间", @"微信", @"朋友圈", @"新浪微博", @"举报", @"删除", @"取消"];
    NSArray *imageTemArray = @[@"share_qq", @"share_qq_zone", @"share_wechat", @"share_wechat_circle", @"share_sina", @"share_report", @"share_delete"];
    NSMutableArray *titleArray = [NSMutableArray arrayWithArray:titleTemArray];
    NSMutableArray *imageArray = [NSMutableArray arrayWithArray:imageTemArray];
    switch (_shareFromType) {
        case ShareFromTypeNormal:
        case ShareFromTypeLottery: {
            // 分享正常样式不请求接口，不显示举报和删除
            // 中奖部分分享样式请求接口，不显示举报和删除
            [titleArray removeObjectsInRange:NSMakeRange(titleArray.count - 3, 2)];
            [imageArray removeObjectsInRange:NSMakeRange(imageArray.count - 2, 2)];
        }
            break;
        case ShareFromTypeFriendCircleNormal: {
            // 朋友圈分享正常样式，只显示举报
            [titleArray removeObjectsInRange:NSMakeRange(titleArray.count - 2, 1)];
            [imageArray removeLastObject];
        }
            break;
        case ShareFromTypeFriendCircleWithDelete: {
            // 自己发布的只显示删除，隐藏举报功能
            [titleArray removeObjectsInRange:NSMakeRange(titleArray.count - 3, 1)];
            [imageArray removeObjectsInRange:NSMakeRange(imageArray.count - 2, 1)];
        }
            break;
        case ShareFromTypeOther: {
            // 其他样式待定
        }
            break;
    }
    
    CGFloat itemW = _menuView.frame.size.width / 4;
    CGFloat itemH = 99;
    UIButton *button[titleArray.count];
    for (int i = 0; i < titleArray.count; i ++) {
        button[i] = [[UIButton alloc]initWithFrame:CGRectMake((i > 3 ? i - 4 : i) * itemW, (i > 3 ? 1 : 0) * (itemH + 0.5), itemW, itemH)];
        button[i].tag = 105170 + i;
        [button[i] setTitle:titleArray[i] forState:UIControlStateNormal];
        [button[i] setTitleColor:i > 6 ? kColorLightRed : [UIColor blackColor] forState:UIControlStateNormal];
        button[i].titleLabel.font = [UIFont systemFontOfSize:i > 6 ? 18 : 11];
        [button[i] addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i < titleArray.count - 1) {
            button[i].contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
            button[i].contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [button[i] setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
            [button[i] setImageEdgeInsets:UIEdgeInsetsMake((itemH - 53 - 10 - 11) / 2, (itemW - 53) / 2, 0, 0)];
            CGFloat titleW = [DataHelper widthWithString:titleArray[i] font:kFontSize11];
            [button[i] setTitleEdgeInsets:UIEdgeInsetsMake(53 + 12.5 + 10, (itemW - titleW) / 2 - 53, 0, 0)];
            if ((i + 1) % 4 != 0) {
                UIView *separateLine = [[UIView alloc]initWithFrame:CGRectMake(button[i].right - 1, button[i].top + (itemH - 10) / 2, 2, 10)];
                separateLine.tag = 106020 + i;
                separateLine.backgroundColor = kColorSeparatorline;
                [_menuView addSubview:separateLine];
            }
        }
        [_menuView addSubview:button[i]];
    }
    UIView *separateLine =  [[UIView alloc]initWithFrame:CGRectMake(0, button[3].bottom, kScreenWidth, 0.5)];
    separateLine.backgroundColor = kColorSeparatorline;
    [_menuView addSubview:separateLine];
    
    UIView *separateView =  [[UIView alloc]initWithFrame:CGRectMake(0, button[4].bottom, kScreenWidth, 10)];
    separateView.backgroundColor = kColorNavBground;
    [_menuView addSubview:separateView];
    
    button[titleArray.count - 1].frame = CGRectMake(0, _menuView.height - 63, kScreenWidth, 63);
    button[titleArray.count - 1].tag = 105177;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
    tap.delegate = self;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        _menuView.top = self.bounds.size.height - 271;
    }];
}

- (void)buttonAction:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = sender;
        NSInteger buttonTag = button.tag - 105170;
        if (buttonTag < 5) {
            // 分享到对应平台
            if (_shareFromType == ShareFromTypeNormal) {
                [self sharePushToPlatformWithButtonTag:buttonTag shareTitle:_shareTitle shareUrl:_shareUrl shareTxt:_shareTxt shareImg:_shareImg];
            } else {
                [self getParamsWithAction:_action shareId:_shareId buttonTag:buttonTag];
            }
        } else if (buttonTag == 5 || buttonTag == 6) {
            if (_shareFromType == ShareFromTypeFriendCircleWithDelete) {
                // 自己发布的只显示删除，隐藏举报功能tag对应着改变
                buttonTag = 6;
            }
            // 举报or删除
            if (self.completeBlock) {
                self.completeBlock(buttonTag);
            }
        }
    } else {
        UITapGestureRecognizer *tap = sender;
        if (tap.state == UIGestureRecognizerStateEnded){
            CGPoint location = [tap locationInView:self];
            if (location.y > self.bounds.size.height - 270) {
                return;
            }
        }
    }
    [UIView animateWithDuration:0.3 animations:^{
        _menuView.top = self.bottom;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/**
 *  分享到对应平台
 *  @param shareType 平台类型
 *  @param shareTitle 标题
 *  @param shareUrl   分享链接
 *  @param shareTxt  分享内容
 *  @param shareImg 分享图片
 */
- (void)sharePushToPlatformWithButtonTag:(NSInteger)buttonTag
                              shareTitle:(NSString *)shareTitle
                                shareUrl:(NSString *)shareUrl
                               shareTxt:(NSString *)shareTxt
                              shareImg:(NSString *)shareImg {
    //需要自定义面板样式的开发者需要自己绘制UI，在对应的分享按钮中调用此接口
    [UMSocialData defaultData].extConfig.title = shareTitle;
    NSString *shareType;
    // 分享至@"QQ", @"QQ空间", @"微信", @"朋友圈", @"新浪微博", @"举报", @"删除"
    switch (buttonTag) {
        case 0:{
            // 分享到QQ
            shareType = UMShareToQQ;
            [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
        }
            break;
        case 1:{
            // 分享到QQ空间
            shareType = UMShareToQzone;
            [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
        }
            break;
        case 2:{
            // 微信
            shareType = UMShareToWechatSession;
            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
        }
            break;
        case 3:{
            // 朋友圈
            shareType = UMShareToWechatTimeline;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
        }
            break;
        case 4:{
            // 新浪微博
            shareType = UMShareToSina;

        }
            break;
    }
    [_imageView sd_setImageWithURL:kURLWithString(shareImg) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareType] content:shareTxt image:image location:nil urlResource:nil presentedController:nil completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    iToastText(@"分享成功！");
                }
            }];
        }
    }];
}

/**
 *  请求分享接口
 *  @param shareId 分享对应Id
 *  @param action  分享入口feed:朋友圈 shop:商城 period:礼券 exchange:兑换记录 award:中奖记
 *  @param buttonTag 点击对应按钮
 */

- (void)getParamsWithAction:(NSString *)action shareId:(NSInteger)shareId buttonTag:(NSInteger)buttonTag {
    [ShareModel getShareInfoWithAction:action shareId:shareId networkHUD:NetworkHUDMsg target:self.viewController success:^(StatusModel *response) {
        @weakify(self);
        if (response.code == 0) {
            ShareModel *model = (ShareModel *)response.data;
            @strongify(self);
            [self sharePushToPlatformWithButtonTag:buttonTag shareTitle:model.shareTitle shareUrl:model.shareUrl shareTxt:model.shareTxt shareImg:model.shareImg];
            
        } else {
            iToastText(response.msg);
        }
    }];
}

@end
