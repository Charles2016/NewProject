//
//  CollectionMenuView.h
//  GameTerrace
//
//  Created by Charles on 2017/11/29.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionMenuView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger cellType;//collectioncell样式 0图片列表滚动样式 1游戏专区一张图一个标题样式
@property (nonatomic, copy) void (^itemBlock)(id model);

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
+ (id)getMenuViewWithFrame:(CGRect)frame cellType:(NSInteger)cellType data:(NSArray *)data itemSize:(CGSize)itemSize lineSpacing:(CGFloat)lineSpacing itemBlock:(void(^)(id model))itemBlock;

@end

@interface CollectionMenuCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *imageView;

//待完善数据cell方法

@end
