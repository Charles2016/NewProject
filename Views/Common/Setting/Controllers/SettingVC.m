//
//  SettingVC.m
//  GoodHappiness
//
//  Created by Charles on 6/9/16.
//  Copyright © 2016 Charles. All rights reserved.
//

#import "SettingVC.h"
#import "AboutUsVC.h"

@interface SettingVC ()<UITableViewDelegate, UITableViewDataSource> {
    UITableView *_settingTable;
    NSArray *_dataArray;
}

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColorBgWhite;
    self.navigationItem.title = @"个人中心";
    _dataArray = @[@[@"常见问题"],
                   @[@"联系我们", @"关于我们", @"清空缓存"],
                   @[@"退出账号"]];
    [self setUI];
}

- (void)setUI {
    _settingTable = InsertTableView(self.view, CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTabbarHeight), self, self, UITableViewStylePlain, UITableViewCellSeparatorStyleNone);
}
#pragma mark - privateMethod
- (void)loginOut {
    [self loadingStartBgClear];
    // 退出账号
    @weakify(self);
    [UserModel getLogoutWithNetworkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        @strongify(self);
        if (response.code == 0) {
            self.taBarIndex = 4;
            [self.navigationController popViewControllerAnimated:YES];
            // 退出登录发出通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kLogout object:@{@"isChangeTab" : @"NO"}];
        } else {
            iToastText(response.msg);
        }
        [self loadingSuccess];
    }];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UILabel *tipLable = InsertLabel(cell, CGRectMake(10, 0, kScreenWidth / 2, 50), NSTextAlignmentLeft, _dataArray[indexPath.section][indexPath.row], kFontSize13, kColorBlack, NO);
        if ((indexPath.section == 1 && indexPath.row < 2) || indexPath.section == 2) {
            CGFloat left = indexPath.section == 2 ? 0 : 10;
            CGFloat width = indexPath.section == 2 ? kScreenWidth : kScreenWidth - 10;
            InsertImageView(cell, CGRectMake(left, 49.5, width, 0.5), [UIImage imageWithColor:kColorSeparatorline]);
        }
        if (indexPath.section == 2) {
            tipLable.width = kScreenWidth - 20;
            tipLable.textAlignment = NSTextAlignmentCenter;
        } else {
            InsertImageView(cell, CGRectMake(kScreenWidth - 13.5, 22, 3.5, 6), [UIImage imageNamed:@"detail_cell_arrow"]);
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
       // 常见问题
        WebviewController *VC = [[WebviewController alloc]init];
        VC.urlStr = [NSString stringWithFormat:@"%@v1/user/insrallnormal", kH5HostURL];
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [HXFAlertView alertWithTitle:@"拨打客服电话" message:[NSString stringWithFormat:@"%@\n（服务时间9：30 – 18：30）", kPhoneNumber] cancelButton:@"取消" otherButton:@"呼叫" complete:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@", kPhoneNumber];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                }
            }];
        } else if (indexPath.row == 1) {
            // 关于我们
            AboutUsVC *VC = [[AboutUsVC alloc]init];
            [self.navigationController pushViewController:VC animated:YES];
        } else {
            NSString *cacheSize = [NSString stringWithFormat:@"目前缓存大小为%.2lfM", [DataHelper getCacheFileSize]];
            [HXFAlertView alertWithTitle:@"确定要清空缓存吗?" message:cacheSize cancelButton:@"取消" otherButton:@"确定" complete:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [DataHelper clearCacheFile];
                }
            }];
        }
    }  else if (indexPath.section == 2) {
        [HXFAlertView alertWithTitle:@"确定要退出账号吗？" message:@"" cancelButton:@"取消" otherButton:@"确定" complete:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self loginOut];
            }
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = InsertView(nil, CGRectMake(0, 0, kScreenWidth, section == 0 ? 0.5 : 10), kColorLightgray);
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.5 : 10;
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
