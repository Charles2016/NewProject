//
//  ReportVC.m
//  GoodHappiness
//
//  Created by chaolong on 16/6/20.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "ReportVC.h"

#import "ShareModel.h"

@interface ReportVC ()< UITableViewDelegate, UITableViewDataSource> {
    UITableView *_reportTable;
    NSArray *_reasonArray;
    NSString *_reasonStr;
}

@end

@implementation ReportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColorWhite;
    self.navigationItem.title = @"举报";
    _reasonArray = @[@"色情低俗", @"政治敏感", @"违法", @"广告", @"其他"];
    [self setUI];
}

- (void)setUI {
    _reportTable = InsertTableView(self.view, self.view.bounds, self, self, UITableViewStylePlain, UITableViewCellSeparatorStyleNone);
    UIView *headView = InsertView(self.view, CGRectMake(0, 0, kScreenWidth, 50), kColorWhite);
    InsertLabel(headView, CGRectMake(10, 0, kScreenWidth - 20, 50), NSTextAlignmentLeft, @"请选择举报原因", kFontSize13, kColorLightBlack, NO);
    InsertView(headView, CGRectMake(0, 49.5, kScreenWidth, 0.5), kColorSeparatorline);
    _reportTable.tableHeaderView = headView;
    
    
    UIView *footerView = InsertView(self.view, CGRectMake(0, 0, kScreenWidth, 90), kColorWhite);
    // 提交按钮
    UIButton *commit = InsertButtonWithType(footerView, CGRectMake((kScreenWidth - 173) / 2, 50, 173, 44), 106209, self, @selector(commitAction:), UIButtonTypeCustom);
    commit.titleLabel.font = kFontSize13;
    [commit setTitleColor:kColorBlack forState:UIControlStateNormal];
    [commit setTitle:@"确定" forState:UIControlStateNormal];
    [commit setBackgroundImage:kButtonImage(@"button_image_black") forState:UIControlStateNormal];
    _reportTable.tableFooterView = footerView;

}

- (void)commitAction:(UIButton *)button {
    if (!_reasonStr.length) {
        iToastText(@"请选择举报原因！");
        return;
    }
    @weakify(self);
    [ShareModel getReportWithReason:_reasonStr postId:_postId type:_type networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        if (response.code == 0) {
            @strongify(self);
            iToastText(@"举报成功！");
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            iToastText(response.msg);
        }
    }];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reasonArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        InsertLabel(cell, CGRectMake(10, 0, kScreenWidth / 2, 40), NSTextAlignmentLeft, _reasonArray[indexPath.row], kFontSize13, kColorBlack, NO);
        UIImageView *imageView = InsertImageView(cell, CGRectMake(kScreenWidth - 30, 10, 20, 20), nil);
        imageView.tag = indexPath.row + 106200;
        InsertImageView(cell, CGRectMake(10, 39.5, kScreenWidth - 10, 0.5), [UIImage imageWithColor:kColorSeparatorline]);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for (int i = 0; i < _reasonArray.count; i++) {
        UIImageView *imageView = [self.view viewWithTag:106200 + i];
        imageView.image = i == indexPath.row ? [UIImage imageNamed:@"photo_choose_s"] : nil;
    }
    switch (indexPath.row) {
        case 0:
            _reasonStr = @"obscene";
            break;
        case 1:
            _reasonStr = @"policy";
            break;
        case 2:
            _reasonStr = @"illegal";
            break;
        case 3:
            _reasonStr = @"advert";
            break;
        case 4:
            _reasonStr = @"other";
            break;
    }
}


@end
