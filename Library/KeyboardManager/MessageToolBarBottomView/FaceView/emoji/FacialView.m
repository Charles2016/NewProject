//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kLineNum 3          //行数
#define kFaceNumPerLine 7   //每行表情数
#define kFaceHeight 30      //正方形

#import "FacialView.h"
#import "FaceMap.h"

@implementation EmoticonView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

@end

@interface FacialView()
{
    //横向间距
    CGFloat _spaceH;
    //纵向间距
    CGFloat _spaceV;
    BOOL _isLoadFacial;
}

@end

@implementation FacialView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _spaceH = (frame.size.width - kFaceHeight * kFaceNumPerLine) / (kFaceNumPerLine + 1);
        _spaceV = (frame.size.height - kFaceHeight * kLineNum) / (kLineNum + 1);

    }
    return self;
}

-(void)loadFacialView:(int)page
{
    if (_isLoadFacial) {
        return;
    }
	for (int i=0; i< kLineNum; i++) {
		for (int y=0; y < kFaceNumPerLine; y++) {
            UIView *view=[[UIView alloc] initWithFrame:CGRectMake(y * (kFaceHeight + _spaceH) + _spaceH - 2, i * (kFaceHeight + _spaceV) + _spaceV - 3, kFaceHeight + 7, kFaceHeight + 5)];
            EmoticonView *imageView=[[EmoticonView alloc] initWithFrame:CGRectMake(2, 2, kFaceHeight, kFaceHeight)];
            [imageView setBackgroundColor:[UIColor clearColor]];
            if (i == kLineNum -1 && y== kFaceNumPerLine - 1) {
                [imageView setImage:[UIImage imageNamed:@"face_delete"]];
                imageView.tag=10000;
                imageView.emoticonName = @"删除";
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                
                NSInteger index = page != 0 ? (page * (kLineNum * kFaceNumPerLine) - 1) + (kFaceNumPerLine * i + y) : (kFaceNumPerLine * i + y) ;
                
                NSString *indexStr = index <= 9 ? [NSString stringWithFormat:@"f00%ld", (long)index] : [NSString stringWithFormat:@"f0%ld", (long)index];
                imageView.emoticonName = [FaceMap compareValueInDictionary:indexStr];
                [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", indexStr]]];
                imageView.tag = page != 0 ? (page * (kLineNum * kFaceNumPerLine) - 1) + (i * kFaceNumPerLine + y) : (i * kFaceNumPerLine + y);
            }
            
            [view addSubview:imageView];
            view.tag = imageView.tag + 1000;
            imageView.userInteractionEnabled = NO;
            [self addTapGestureForView:view];
			[self addSubview:view];
		}
    }
    _isLoadFacial = YES;
}
//添加手势
- (void)addTapGestureForView:(UIView *)view {
    UITapGestureRecognizer *tapGez = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tapGez];
}
//点击视图
- (void)viewTapped:(UITapGestureRecognizer *)sender {
    EmoticonView * view =(EmoticonView *)[sender.view viewWithTag:sender.view.tag - 1000];  
    if (_delegate && [_delegate respondsToSelector:@selector(faciaView:selectedEmoticonView:)]) {
        [_delegate faciaView:self selectedEmoticonView:view];
    }
}

@end
