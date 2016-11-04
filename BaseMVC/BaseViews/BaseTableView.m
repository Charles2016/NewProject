//
//  BaseTableView.m
//  WEIBO-X
//
//  Created by Mctu on 13-12-31.
//  Copyright (c) 2013年 XIAO. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate   = self;
        self.dataSource = self;
        self.accessibilityLabel = @"businessTable";
        self.isShowHeadView = NO;
        self.backgroundColor = kBackgroundColor;
     }
    return self;
}


#pragma mark -tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isDelete) {
        return YES;
    }
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isShowHeadView) {
        return 31;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        [self.data removeObjectAtIndex:indexPath.row];
        [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


- (void)reloadData {
    [super reloadData];
    [self.header endRefreshing];
    [self.footer endRefreshing];
}


/**
 *  使得UITableView 的Header和footer 不跟随TableView 滚动而滚动
 *  在方法：scrollViewDidScroll中实现即可
 *  @param heightHeader header  高度
 *  @param heightFooter Footer 高度
 */
+ (void)makeFootOrHeaderNotScollow:(UIScrollView *)scrollView headerHeight:(CGFloat)heightHeader footerHeight:(CGFloat) heightFooter {
    UITableView *tableview = (UITableView *)scrollView;
    CGFloat sectionHeaderHeight = heightHeader;
    CGFloat sectionFooterHeight = heightFooter;
    CGFloat offsetY = tableview.contentOffset.y;
    if (offsetY >= 0 && offsetY <= sectionHeaderHeight) {
        tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -sectionFooterHeight, 0);
    } else if (offsetY >= sectionHeaderHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight) {
        tableview.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, -sectionFooterHeight, 0);
    } else if (offsetY >= tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight && offsetY <= tableview.contentSize.height - tableview.frame.size.height) {
        tableview.contentInset = UIEdgeInsetsMake(-offsetY, 0, -(tableview.contentSize.height - tableview.frame.size.height - sectionFooterHeight), 0);
    }
}


@end
