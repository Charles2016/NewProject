//
//  DXChatBarMoreView.m
//  Share
//
//  Created by xieyajie on 14-4-15.
//  Copyright (c) 2014年 Share. All rights reserved.
//

#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
//#import "VoiceView.h"

#define CHAT_BUTTON_SIZE_WIDTH  (kScreenWidth-32-19*3)/4
#define CHAT_BUTTON_SIZE_HEIGHT (kScreenWidth-32-19*3)/4+20
#define INSETS_XX   19  //两按钮间隔
#define INSETS_X    16  //第一个按钮与左边的距离
#define INSETS_Y    (self.height-((kScreenWidth-32-19*3)/4+20)*2)/3//将Y轴间隔分成三等分

@implementation DXChatBarMoreView
{
    NSArray *_titileArray;
    NSArray *_imageArray;
    BOOL _isGroup;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self setBackgroundColor:UIColorHex(0xf7f5f5)];
    
    _titileArray = @[@"照片", @"拍照", @"位置", @"个人名片", @"我要求职", @"我要招聘"];
    _imageArray = @[@[@"chat_photo", @"chat_camera", @"chat_location", @"chat_personalcard", @"chat_resume", @"chat_recruitment"],
                    @[@"chat_photo_s", @"chat_camera_s", @"chat_location_s", @"chat_personalcard_s", @"chat_resume_s", @"chat_recruitment_s"]];
    _buttonArray = [[NSMutableArray alloc]initWithCapacity:0];
    int rank_X, column_Y;
    for (int i = 0; i < _titileArray.count; i++) {
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rank_X = i<4?INSETS_X+i*(CHAT_BUTTON_SIZE_WIDTH+INSETS_XX):INSETS_X+(i-4)*(CHAT_BUTTON_SIZE_WIDTH+INSETS_XX);//行X轴
        column_Y = i<4?INSETS_Y:INSETS_Y*2+CHAT_BUTTON_SIZE_HEIGHT;//列Y轴
        moreButton.frame = CGRectMake(rank_X, column_Y, CHAT_BUTTON_SIZE_WIDTH, CHAT_BUTTON_SIZE_HEIGHT);
        [moreButton setImage:[UIImage imageNamed:_imageArray[0][i]] forState:UIControlStateNormal];
        [moreButton setImage:[UIImage imageNamed:_imageArray[1][i]] forState:UIControlStateSelected];
        [moreButton setTitle:_titileArray[i] forState:UIControlStateNormal];
        moreButton.tag = 1900+i;
        [[self class] setButtonType:moreButton];
        [moreButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreButton];
        [_buttonArray addObject:moreButton];
    }
    
    if (!self.recordView) {
        self.recordView = [[DXRecordView alloc] init];
    }
    
}

//更多按钮会全部创建，这里是对按钮位置进行调整和屏蔽 isChatGroup1群聊 2单聊 3惠粉团队
- (void)isChatGroup:(int)isChatGroup {
    if (isChatGroup == 1) {
//        _videoButton.hidden = YES;
//        _atButton.frame = _videoButton.frame;
    }else if(isChatGroup == 2){
//        _atButton.hidden = YES;
    }else{
//        _videoButton.hidden = _atButton.hidden = YES;
    }
}

#pragma mark - action
- (void)buttonAction:(UIButton *)button {
    DLog(@"%ld", button.tag);
    switch (button.tag) {
        case 1900://照片
        {
            if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
                [_delegate moreViewPhotoAction:self];
            }
        }
            break;
        case 1901://拍照
        {
            if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
                [_delegate moreViewTakePicAction:self];
            }
        }
            break;
        case 1902://位置
        {
            if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
                [_delegate moreViewLocationAction:self];
            }
        }
            break;
        case 1903://个人名片
        {
            if (_delegate&&[_delegate respondsToSelector:@selector(moreViewBusinessCardAction:)]) {
                [_delegate moreViewBusinessCardAction:self];
            }
        }
            break;
        case 1904://我要求职
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(moreViewPersonalResumeAction:)]) {
                [self.delegate moreViewPersonalResumeAction:self];
            }
        }
            break;
        case 1905://我要招聘
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(moreViewPersonalRecruitmentAction:)]) {
                [self.delegate moreViewPersonalRecruitmentAction:self];
            }
        }
            break;
    }
}

+ (void)setButtonType:(UIButton*)button {
    //    button.backgroundColor = UIColorRGB(22, 160, 220);
    [button setTitleColor:kColorLightgray forState:UIControlStateNormal];
    button.titleLabel.font = kFontSize12;
    [button.titleLabel setContentMode:UIViewContentModeCenter];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    CGFloat imageInset = (button.width-button.imageView.image.size.width)/2;
    CGFloat titleInset = (button.width-[DataHelper widthWithString:button.titleLabel.text font:kFontSize12])/2-button.imageView.image.size.width;
    CGFloat separateInset = (button.height-button.imageView.image.size.width-20)/2;
    [button setImageEdgeInsets:UIEdgeInsetsMake(separateInset, imageInset, 0.0, 0.0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(button.imageView.image.size.width+separateInset+5, titleInset, 0.0, -5)];
}

@end
