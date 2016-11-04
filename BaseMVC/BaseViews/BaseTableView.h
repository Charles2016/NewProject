//
//  BaseTableView.h
//  WEIBO-X
//
//  Created by Mctu on 13-12-31.
//  Copyright (c) 2013年 XIAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@interface BaseTableView : UITableView<UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray *data;//提供数据
@property (nonatomic, assign) BOOL isDelete; //是否删除
@property (nonatomic, assign) BOOL isShowHeadView;

/**
 *  使得UITableView 的Header和footer 不跟随TableView 滚动而滚动
 *  在方法：scrollViewDidScroll中实现即可
 *  @param heightHeader header  高度
 *  @param heightFooter Footer 高度
 */
+ (void)makeFootOrHeaderNotScollow:(UIScrollView *)scrollView headerHeight:(CGFloat)heightHeader footerHeight:(CGFloat)heightFooter;

@end
