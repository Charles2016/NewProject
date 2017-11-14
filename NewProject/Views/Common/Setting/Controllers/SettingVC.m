//
//  SettingVC.m
//  RacingCarLottery
//
//  Created by Charles on 6/9/16.
//  Copyright © 2016 Charles. All rights reserved.
//

#import "SettingVC.h"
#import "OpinionVC.h"

@interface SettingVC ()<UITableViewDelegate, UITableViewDataSource> {
    UITableView *_settingTable;
    NSArray *_dataArray;
}

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    _dataArray = @[@[@"意见反馈", @"清除缓存"]];
    [self setUI];
}

- (void)setUI {
    _settingTable = InsertTableView(self.view, CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTabbarHeight), self, self, UITableViewStylePlain, UITableViewCellSeparatorStyleNone);
    _settingTable.backgroundColor = kColorViewBg;
}

#pragma mark - privateMethod
- (void)loginOutAction:(UIButton *)button {
    @weakify(self);
    [HXFAlertView alertWithTitle:@"确定要退出登录吗？" message:@"" cancelButton:@"取消" otherButton:@"确定" complete:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            @strongify(self);
            [self loginOut];
        }
    }];
}
#pragma mark - privateMethod
- (void)loginOut {
    /*// 退出账号
    @weakify(self);
    [UserModel getLogoutWithNetworkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        @strongify(self);
        if (response.Success) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            iToastText(response.Msg);
        }
    }];*/
    
    NSArray *userArray = [UserModel searchWithWhere:[NSString stringWithFormat:@"uid = '%@'", kUid] orderBy:nil offset:0 count:100];
    for (UserModel *userModel in userArray) {
        if (userModel.isLogin) {
            userModel.isLogin = NO;
            [userModel updateToDB];
            break;
        }
    }
    GetDataUserModel = nil;
    kUserDefaults(@"kUid", @"");
    kUserDefaults(@"kLIV", @"");
    kSynchronize;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42 * H_Unit;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = kColorWhite;
        UILabel *tipLable = InsertLabel(cell, CGRectZero, NSTextAlignmentLeft, _dataArray[indexPath.section][indexPath.row], kFontSize13, kColorBlack, NO);
        [tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.mas_left).offset(15);
            make.centerY.equalTo(cell.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(100, 20));
        }];
        
        UIImageView *arrow = InsertImageView(cell, CGRectZero, [UIImage imageNamed:@"mine_arrow"]);
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.mas_right).offset(-10);
            make.centerY.equalTo(cell.mas_centerY);
            make.size.mas_equalTo(arrow.image.size);
        }];
        if (indexPath.row == 0) {
            InsertImageView(cell, CGRectMake(15, 42 * H_Unit - 0.5, kScreenWidth - 15, 0.5), [UIImage imageWithColor:kColorSeparatorline]);
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        // 意见反馈
        OpinionVC *VC = [[OpinionVC alloc]init];
        [self.navigationController pushViewController:VC animated:YES];
    } else {
        // 清除缓存
        [HXFAlertView actionSheetWithTitle:@"是否确认清除缓存" message:nil cancelButton:@"取消" otherButtons:@[@"清空缓存数据"] otherColors:@[kColorRed] alertViewType:AlertViewSheet complete:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [DataHelper clearCacheFile];
            }
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = InsertView(nil, CGRectMake(0, 0, kScreenWidth, 10), kColorViewBg);
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = InsertView(nil, CGRectMake(0, 0, kScreenWidth, 120), kColorViewBg);
    UIButton *loginOut = InsertButtonWithType(footerView, CGRectZero, 104213, self, @selector(loginOutAction:), UIButtonTypeCustom);
    [loginOut setTitle:@"退出登录" forState:UIControlStateNormal];
    [loginOut setBackgroundColor:kColorNavBgFrist];
    loginOut.layer.cornerRadius = 5;
    [loginOut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(footerView);
        make.width.equalTo(footerView.mas_width).offset(-40);
        make.height.mas_equalTo(40 * H_Unit);
    }];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 120;
}

// 防止sectionView跟着表格滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 10;
    if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
