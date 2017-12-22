//
//  CollectionMenuView.m
//  GameTerrace
//
//  Created by Charles on 2017/11/29.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "CollectionMenuView.h"

@interface CollectionMenuView () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation CollectionMenuView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    if (_dataArray.count) {
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [_collectionView reloadData];
    }
}

- (void)setUI {
    _layout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:self.frame collectionViewLayout:_layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[CollectionMenuCell class] forCellWithReuseIdentifier:@"CollectionMenuCell"];
    _collectionView.backgroundColor = kColorWhite;
    [self addSubview:_collectionView];
}

/**
 * 类方法获取滑动嵌套view
 * @param frame             frame值
 * @param cellType          item样式 0一张图样式 1一张图一个标题样式
 * @param data              item数据
 * @param itemSize          itemSize
 * @param lineSpacing       item间隔
 * @itemBlock               点击item回调block
 * @return 滑动嵌套view
 */
+ (id)getMenuViewWithFrame:(CGRect)frame cellType:(NSInteger)cellType data:(NSArray *)data itemSize:(CGSize)itemSize lineSpacing:(CGFloat)lineSpacing itemBlock:(void(^)(id model))itemBlock {
    CollectionMenuView *menuView = [[CollectionMenuView alloc]initWithFrame:frame];
    menuView.layout.minimumLineSpacing = lineSpacing;
    menuView.layout.itemSize = itemSize;
    menuView.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    menuView.collectionView.showsHorizontalScrollIndicator = YES;
    menuView.collectionView.bounces = YES;
    menuView.dataArray = data;
    menuView.cellType = cellType;
    menuView.itemBlock = itemBlock;
    return menuView;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
//返回分区个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回每个分区的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

//返回每个item
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionMenuCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionMenuCell" forIndexPath:indexPath];
    //待完善数据cell
    return cell;
}

// 点击item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_itemBlock) {
        _itemBlock(_dataArray[indexPath.row]);
    }
}

@end

@implementation CollectionMenuCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI {
    _imageView = InsertImageViewM(self, nil);
    _label = InsertLabel(self, CGRectZero, NSTextAlignmentCenter, @"", kFontSize14, kColorBlack, NO);
    _detailLabel = InsertLabel(self, CGRectZero, NSTextAlignmentCenter, @"", kFontSize12, kColorLightBlack, NO);
}

@end
