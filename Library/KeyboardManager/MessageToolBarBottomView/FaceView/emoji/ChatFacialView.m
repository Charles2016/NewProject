//
//  ChatFacialView.m
//  HuiXin
//
//  Created by 文俊 on 13-11-26.
//  Copyright (c) 2013年 mypuduo. All rights reserved.
//

#define kPageControlHeight  40   // scrollviewPageControl的高度
#define kFaceCategoryNormal @"face_category_normal"

#import "ChatFacialView.h"
#import "FacialView.h"

@interface ChatFacialView() <UIScrollViewDelegate, FacialViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    UIButton *_faceSendButton;
    UIButton *_deleteEmoji;
    NSMutableArray *_dataArray;
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    NSInteger _horizontalCount;// 表情水平行数
    NSInteger _verticalCount;// 表情竖直行数
    NSInteger _lastSectionCount;// 最后一页个数
    NSInteger _sectionCount;// section个数
}

@end

@implementation ChatFacialView

- (void)setReturnKeyType:(FaceReturnKeyType)returnKeyType {
    if (FaceReturnKeyTypeDone == returnKeyType) {
        [_faceSendButton setTitle:@"完成" forState:UIControlStateNormal];
    } else if (FaceReturnKeyTypeSend == returnKeyType) {
        [_faceSendButton setTitle:@"发送" forState:UIControlStateNormal];
    }
}

- (void)setIsEmoji:(BOOL)isEmoji {
    _isEmoji = isEmoji;
    if (_isEmoji) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emojiMap" ofType:@"plist"];
        NSDictionary *emojiDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        _dataArray = [NSMutableArray arrayWithCapacity:0];
        NSArray *keyArray = @[@"people", @"nature", @"places", @"objects"];
        for (int i = 0; i < keyArray.count; i++) {
            [_dataArray addObjectsFromArray:emojiDic[keyArray[i]]];
        }
        _lastSectionCount = 0;//_dataArray.count % (_horizontalCount * _verticalCount) == 0 ? 0 : _dataArray.count % (_horizontalCount * _verticalCount);
        _sectionCount = _lastSectionCount == 0 ? _dataArray.count / (_horizontalCount * _verticalCount) : _dataArray.count / (_horizontalCount * _verticalCount) + 1;
        _pageControl.numberOfPages = _sectionCount;//指定页面个数
        [_collectionView reloadData];
    }
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _horizontalCount = (self.width - 20) / 40;
        _verticalCount = (self.height - 40) / 40;
        
        //collectionView布局
        _layout = [[UICollectionViewFlowLayout alloc]init];
        //设置行列间距
        _layout.minimumLineSpacing= 0 ;
        _layout.minimumInteritemSpacing = 0;
        //水平布局
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize=CGSizeMake(40, 40);
//        //计算每个分区的左右边距
        float xOffset = (kScreenWidth - _horizontalCount * 40) / 2;
//        //设置分区的内容偏移
        _layout.sectionInset = UIEdgeInsetsMake(5, xOffset, 5, xOffset);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height - kPageControlHeight) collectionViewLayout:_layout];
        //打开分页效果
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = kColorLightgray;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"biaoqing"];
        [self addSubview:_collectionView];

        
//        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//        [_scrollView setShowsHorizontalScrollIndicator:NO];
//        [_scrollView setShowsVerticalScrollIndicator:NO];
//        _scrollView.contentSize = CGSizeMake(self.width * kPageNum, self.height);
//        _scrollView.backgroundColor = [UIColor clearColor];
//        _scrollView.pagingEnabled = YES;
//        _scrollView.delegate = self;
//        
//        for (int i=0; i < kPageNum; i++) {
//            FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(i * frame.size.width, 0, frame.size.width, self.height - kPageControlHeight)];
//            [fview setBackgroundColor:[UIColor clearColor]];
//            fview.delegate=self;
//            fview.tag = 800 + i;
//            if (i < 2) {
//                [fview loadFacialView:i];
//            }
//            [_scrollView addSubview:fview];
//        }
//        [self addSubview:_scrollView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _collectionView.bottom, frame.size.width, kPageControlHeight)];
        _pageControl.pageIndicatorTintColor = kColorLightgray;
        _pageControl.currentPageIndicatorTintColor = kColorNavBground;
        [_pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.pageControl];
        
        _deleteEmoji = [[UIButton alloc]initWithFrame:CGRectMake(self.width - 12.5 - 20, _collectionView.bottom + (kPageControlHeight - 15) / 2, 20, 15)];
        _deleteEmoji.tag = 105110;
        _deleteEmoji.backgroundColor = kColorWhite;
        [_deleteEmoji setImage:[UIImage imageNamed:@"chat_face_delete"] forState:UIControlStateNormal];
        [_deleteEmoji addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteEmoji];
//        if (!_isEmoji) {
//            //分隔线
//            UIView *separateLine = InsertView(self, CGRectMake(0, _pageControl.bottom, kScreenWidth, 0.5), UIColorHex(0xdcdcdc));
//            
//            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, separateLine.bottom, kScreenWidth, 44)];
//            bottomView.backgroundColor = [UIColor clearColor];
//            
//            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            faceButton.frame = CGRectMake(0, 0, 78, bottomView.height);
//            [faceButton setImage:[UIImage imageNamed:kFaceCategoryNormal] forState:UIControlStateNormal];
//            [bottomView addSubview:faceButton];
//            //分隔线
//            InsertView(bottomView, CGRectMake(faceButton.right, faceButton.top, 0.5, faceButton.height), UIColorHex(0xdcdcdc));
//            
//            _faceSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            _faceSendButton.frame = CGRectMake(bottomView.right - 65, 0, 65, bottomView.height);
//            _faceSendButton.backgroundColor = kColorNavBground;
//            [_faceSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [_faceSendButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//            [_faceSendButton addTarget:self action:@selector(faceSendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            self.returnKeyType = FaceReturnKeyTypeSend;
//            [bottomView addSubview:_faceSendButton];
//            [self addSubview:bottomView];
//        }
        
    }
    return self;
}

- (void)changePage:(id)sender {
    int page = (int)_pageControl.currentPage;//获取当前pagecontroll的值
    [_scrollView setContentOffset:CGPointMake(kScreenWidth * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}

//发送表情
- (void)buttonAction:(UIButton *)button {
    if (button.tag == 105110) {
        // 这里手动将表情符号添加到textField上
        if (_delegate && [_delegate respondsToSelector:@selector(chatFaciaView:emojiStr:)]) {
            [_delegate chatFaciaView:self emojiStr:@""];
        }
    }
}

- (void)loadFace:(int)page {
    FacialView *fview = (FacialView*)[_scrollView viewWithTag:800+page];
    if (fview) {
        [fview loadFacialView:page];
    }
}

#pragma mark -
//每页_horizontalCount * _verticalCount个表情
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_lastSectionCount > 0 && section == _sectionCount - 1) {
        return _lastSectionCount;
    } else {
        return _horizontalCount * _verticalCount;
    }
}
//返回页数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _sectionCount;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"biaoqing" forIndexPath:indexPath];
    for (int i  = 0; i < cell.contentView.subviews.count; i++) {
        [cell.contentView.subviews[i] removeFromSuperview];
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    label.font = [UIFont systemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    label.text =_dataArray[indexPath.row + indexPath.section * (_horizontalCount * _verticalCount)] ;
    [cell.contentView addSubview:label];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = _dataArray[indexPath.section * (_horizontalCount * _verticalCount) + indexPath.row];
    // 这里手动将表情符号添加到textField上
    if (_delegate && [_delegate respondsToSelector:@selector(chatFaciaView:emojiStr:)]) {
        [_delegate chatFaciaView:self emojiStr:str];
    }
}
// 翻页后对分页控制器进行更新
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat contenOffset = scrollView.contentOffset.x;
    int page = contenOffset / scrollView.frame.size.width+((int)contenOffset%(int)scrollView.frame.size.width == 0 ? 0 : 1);
    _pageControl.currentPage = page;
    
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    int page = floor(_scrollView.contentOffset.x / kScreenWidth);// 通过滚动的偏移量来判断目前页面所对应的小白点
//    _pageControl.currentPage = page;// pagecontroll响应值的变化
//    [self loadFace:page - 1];
//    [self loadFace:page];
//    [self loadFace:page + 1];
//    
//}

#pragma mark - FacialViewDelegate
-(void)faciaView:(FacialView *)faciaView selectedEmoticonView:(EmoticonView *)view {
    if (_delegate && [_delegate respondsToSelector:@selector(chatFaciaView:selectedEmoticonView:)]) {
        [_delegate chatFaciaView:self selectedEmoticonView:view];
    }
}

@end
