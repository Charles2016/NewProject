//
//  UserInfoVC.m
//  CarMango
//
//  Created by chaolong on 16/4/13.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "UserInfoVC.h"
#import "NickNameVC.h"

#import "ChooseGrandView.h"
#import "DatePickerView.h"

#import "PhonePermission.h"

@interface UserInfoVC () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UITableView *_userInfoTable;
    NSArray *_dataArray;
    UIImageView *_headView;
    UILabel *_nickname;
    UILabel *_grand;
    UILabel *_birth;
}

@end

@implementation UserInfoVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_dataArray) {
        _nickname.text = GetDataUserInfo.Nickname;
        _birth.text = GetDataUserInfo.Birthday;
        _grand.text = GetDataUserInfo.Grand == 2 ? @"未设置" : (GetDataUserInfo.Grand == 0 ? @ "女" : @"男");
        [_headView sd_setImageWithURL:[NSURL URLWithString:GetDataUserInfo.HeadPortrait] placeholderImage:kImageName(@"userinfo_head_default")];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人资料";
    [self setUI];
}

- (void)setUI {
    _dataArray = @[@"头像", @"昵称", @"性别", @"生日"];
    _userInfoTable = InsertTableView(self.view, CGRectMake(0, 0, kScreenWidth, kBodyHeight), self, self, UITableViewStylePlain, UITableViewCellSeparatorStyleNone);
    _userInfoTable.backgroundColor = kColorViewBg;
    
}

#pragma mark - privateMethod
- (void)sendImageUpLoad:(UIImage *)image {
    [_headView setImage:image];
}

- (void)loadData:(NSString *)hash image:(UIImage *)image{
    
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 55 *H_Unit : 42 * H_Unit;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UILabel *infoName = InsertLabel(cell, CGRectMake(10, 0, (kScreenWidth - 10 - 27) / 2, 60), NSTextAlignmentLeft, _dataArray[indexPath.row], kFontSize13, kColorBlack, NO);
        [infoName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.mas_left).offset(15);
            make.centerY.equalTo(cell.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(60, 40));
        }];
        
        UIImageView *arrow = InsertImageView(cell, CGRectZero, [UIImage imageNamed:@"mine_arrow"]);
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.mas_right).offset(-10);
            make.centerY.equalTo(cell.mas_centerY);
            make.size.mas_equalTo(arrow.image.size);
        }];
        
        UILabel *info;
        if (indexPath.row == 0) {
            _headView = InsertImageView(cell, CGRectZero, nil);
            [_headView sd_setImageWithURL:kURLWithString(GetDataUserInfo.HeadPortrait) placeholderImage:kImageName(@"head_default_image")];
            _headView.clipsToBounds = YES;
            _headView.layer.cornerRadius = 18 * W_Unit;
            [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(arrow.mas_left).offset(-10);
                make.centerY.equalTo(arrow.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(36 * W_Unit, 36 * W_Unit));
            }];
        } else {
            info = InsertLabel(cell, CGRectZero, NSTextAlignmentRight, @"", kFontSize13, kColorDarkgray, NO);
            info.tag = indexPath.row + 104220;
            switch (indexPath.row) {
                case 1:
                    info.text = GetDataUserInfo.Nickname.length ?  GetDataUserInfo.Nickname : @"未设置";
                    _nickname = info;
                    break;
                case 2:
                    info.text = GetDataUserInfo.Grand == 2 ? @"未设置" : (GetDataUserInfo.Grand == 0 ? @ "女" : @"男");
                    _grand = info;
                    break;
                case 3:
                    info.text = GetDataUserInfo.Birthday.length ?  GetDataUserInfo.Birthday : @"未设置";
                    _birth = info;
                    break;
            }
            [info mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(arrow.mas_left).offset(-10);
                make.centerY.equalTo(arrow.mas_centerY);
                make.width.mas_equalTo(200);
                make.height.mas_equalTo(42);
            }];
        }
        if (indexPath.row != 3) {
            InsertImageView(cell, CGRectMake(15, (indexPath.row == 0 ? 55 * H_Unit : 42 * H_Unit) - 0.5, kScreenWidth, 0.5), [UIImage imageWithColor:kColorSeparateline]);
        }
    }
    cell.backgroundColor = kColorWhite;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        @weakify(self);
        [HXFAlertView actionSheetWithTitle:@"" message:@"" cancelButton:@"取消" otherButtons:@[@"从相册选择", @"拍照"] otherColors:@[kColorBlue, kColorRed] alertViewType:AlertViewSheet complete:^(NSInteger buttonIndex) {
            @strongify(self);
            if (buttonIndex > 0) {
                [self choosePhotoWithType:buttonIndex];
            }
        }];
    } else if (indexPath.row == 1) {
        // 昵称
        NickNameVC *VC = [[NickNameVC alloc]init];
        [self.navigationController pushViewController:VC animated:YES];
    } else if (indexPath.row == 2) {
        // 性别
        @weakify(self);
        [ChooseGrandView alertWithChooseGrandComplete:^(NSInteger buttonIndex) {
            @strongify(self);
            // buttonIndex 0女 1男
            self->_grand.text = buttonIndex == 0 ? @"女" : @"男";
            // 调用接口更新性别信息
            [self changeUserInfoWithKey:@"Grand" value:@(buttonIndex)];
        }];
    } else if (indexPath.row == 3) {
        // 生日选择
        @weakify(self);
        [DatePickerView initDatePickerViewWithComplete:^(NSString *dateStr) {
            if (dateStr.length) {
                // 调用接口更新生日信息
                @strongify(self);
                self->_birth.text = dateStr;
                [self changeUserInfoWithKey:@"Birth" value:dateStr];
            }
        }];
    }
}

- (void)choosePhotoWithType:(NSInteger)type {
    //检测相册访问权限
    if (![[PhonePermission sharedInstance] checkAccessPermissions:PermissionPhotoType]) {
        return;
    }
    NSUInteger sourceType;
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 1相册 2相机
        sourceType = type == 1 ?  UIImagePickerControllerSourceTypeSavedPhotosAlbum : UIImagePickerControllerSourceTypeCamera;
    } else {
        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    imagePickerController.navigationBar.barTintColor = kColorNavBgFrist;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = [DataHelper originImage:image scaleToSize:CGSizeMake(600, 600)];
    
    @weakify(self);
    [UserInfoModel uploadImageDataWithImage:image networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        if (response.Success) {
            @strongify(self);
            self->_headView.image = image;
            [self updateHeadPictureWithPath:response.Data];
        } else {
            iToastText(response.Msg);
        }
    }];
    
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://192.168.0.112:99/api/FileUpLoad/CommentFileUpLoad" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:info[@"UIImagePickerControllerReferenceURL"]
//                                   name:@"file"
//                               fileName:@"filename.jpg"
//                               mimeType:@"image/jpeg" error:nil];
//    } error:nil];
//    
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    
//    ((AFHTTPResponseSerializer *)(manager.responseSerializer)).acceptableContentTypes = [NSSet setWithObjects:@"application/json",
//                                                                                         @"text/html",
//                                                                                         @"image/jpeg",
//                                                                                         @"image/png",
//                                                                                         @"application/octet-stream",
//                                                                                         @"text/json",
//                                                                                         nil];
//    
//    NSURLSessionUploadTask *uploadTask;
//    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
//                      // This is not called back on the main queue.
//                      // You are responsible for dispatching to the main queue for UI updates
//  
//                  }
//                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//                      if (error) {
//                          NSLog(@"Error: %@", error);
//                      } else {
//                          NSLog(@"%@ %@", response, responseObject);
//                      }
//                  }];
//    
//    [uploadTask resume];
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSURL *URL = [NSURL URLWithString:@"http://192.168.0.112:99/api/FileUpLoad/CommentFileUpLoad"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURL *filePath = info[@"UIImagePickerControllerReferenceURL"];//[NSURL fileURLWithPath:@"file://path/to/image.png"];
//    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"Success: %@ %@", response, responseObject);
//        }
//    }];
//    [uploadTask resume];
    
    /*AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         nil];
    
    NSURLSessionDataTask *task = [manager POST:@"http://192.168.0.112:99/FileUpLoad/CommentFileUpLoad" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
        NSData *imageData =UIImageJPEGRepresentation(image, 0.5);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imageData
                                    name:@"file"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress *uploadProgress) {
        //打印下上传进度
        DLog(@"上传中：%@", uploadProgress);
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        //上传成功
        DLog(@"上传成功");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //上传失败
        DLog(@"上传失败");
    }];
    [task resume];*/
}

- (void)updateHeadPictureWithPath:(NSString *)path {
    [UserInfoModel updateUserImageWithPathStr:path networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        if (response.Success) {
            DLog(@"上传成功");
            GetDataUserInfo.HeadPortrait = path;
            [GetDataUserInfo updateToDB];
        } else {
            iToastText(response.Msg);
        }
    }];
}

- (void)changeUserInfoWithKey:(NSString *)key value:(id)value {
    [UserInfoModel changeUserInfoWithKey:key value:value networkHUD:NetworkHUDMsg target:self success:^(StatusModel *response) {
        if (response.Success) {
            if ([key isEqualToString:@"Birth"]) {
                GetDataUserInfo.Birthday = value;
            } else if ([key isEqualToString:@"Grand"]) {
                GetDataUserInfo.Grand = [value integerValue];
            }
            [GetDataUserInfo updateToDB];
        } else {
            iToastText(response.Msg);
        }
    }];
}

@end
