//
//  HomeVC.m
//  NewProject
//
//  Created by chaolong on 31/10/2016.
//  Copyright © 2016 Charles. All rights reserved.
//

#import "HomeVC.h"
#import "HomeModel.h"

@interface HomeVC ()

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"商城";
    self.view.backgroundColor = kColorWhite;
    [HUDManager showHUDWithMessage:@"加载数据中..."];
    [HomeModel getHomeDataWithSuccess:^(StatusModel *response) {
        [HUDManager hiddenHUD];
        DLog(@"%@", response);
    }];
    
    /*// 1、创建URL资源地址
    NSURL *url = [NSURL URLWithString:@"https://open.weibo.cn/2/statuses/update.json"];
    // 2、创建Reuest请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 3、配置Request
    // 设置请求超时
    [request setTimeoutInterval:10.0];
    // 设置请求方法
    [request setHTTPMethod:@"POST"];
    // 设置头部参数
    [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    // 4、构造请求参数
    // 4.1、创建字典参数，将参数放入字典中，可防止程序员在主观意识上犯错误，即参数写错。
    NSDictionary *parametersDict = @{@"access_token":@"2.00NofgBD0L1k4pc584f79cc48SKGdD",@"count":@"10"};
    // 4.2、遍历字典，以“key=value&”的方式创建参数字符串。
    NSMutableString *parameterString = [[NSMutableString alloc]init];
    int pos =0;
    for (NSString *key in parametersDict.allKeys) {
        // 拼接字符串
        [parameterString appendFormat:@"%@=%@", key, parametersDict[key]];
        if(pos<parametersDict.allKeys.count-1){
            [parameterString appendString:@"&"];
        }
        pos++;
    }
    // 4.3、NSString转成NSData数据类型。
    NSData *parametersData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
    // 5、设置请求报文
    [request setHTTPBody:parametersData];
    // 6、构造NSURLSessionConfiguration
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 7、创建网络会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    // 8、创建会话任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 10、判断是否请求成功
        if (error) {
            NSLog(@"post error :%@",error.localizedDescription);
        }else {
            // 如果请求成功，则解析数据。
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            // 11、判断是否解析成功
            if (error) {
                NSLog(@"post error :%@",error.localizedDescription);
            }else {
                // 解析成功，处理数据，通过GCD获取主队列，在主线程中刷新界面。
                NSLog(@"post success :%@",object);
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 刷新界面...
                });
            }
        }
        
    }];
    // 9、执行任务
    [task resume];*/
    UIButton *button = InsertButton(self.view, CGRectMake(20, 80, kScreenWidth - 40, 40), 2001, self, @selector(pushAction), UIButtonTypeCustom);
    [button setBackgroundColor:kColorBlue];
    
    UIButton *button1 = InsertButton(self.view, CGRectMake(20, 80 + 60, kScreenWidth - 40, 40), 2001, self, @selector(pushAction1), UIButtonTypeCustom);
    [button1 setBackgroundColor:kColorBlue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushAction {
    SuperVC *VC = [[SuperVC alloc]init];
    VC.navigationItem.title = @"下一页";
    VC.view.backgroundColor = kColorWhite;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)pushAction1 {
    SuperVC *VC = [[SuperVC alloc]init];
    VC.navigationItem.title = @"下下页";
    VC.view.backgroundColor = kColorWhite;
    [self.navigationController pushViewController:VC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
