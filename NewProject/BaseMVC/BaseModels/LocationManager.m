//
//  LocationManager.m
//  CarShop
//
//  Created by dary on 2017/5/12.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>      //添加定位服务头文件（不可缺少）
@interface LocationManager ()<CLLocationManagerDelegate>{//添加代理协议 CLLocationManagerDelegate
    CLLocationManager *_locationManager;//定位服务管理类
    CLGeocoder * _geocoder;//初始化地理编码器
    BOOL _isHaveLocation;// 判断是否定位成功
}
@end

@implementation LocationManager

+ (LocationManager *)sharedManager {
    static LocationManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[LocationManager alloc] init];
        assert(sharedManager != nil);
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        // 初始化定位管理器
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestWhenInUseAuthorization];
        // [_locationManager requestAlwaysAuthorization];// iOS8必须，这两行必须有一行执行，否则无法获取位置信息，和定位
        // 设置代理
        _locationManager.delegate = self;
        // 设置定位精确度到米
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置过滤器为无
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        // 开始定位
        [_locationManager startUpdatingLocation];// 开始定位之后会不断的执行代理方法更新位置会比较费电所以建议获取完位置即时关闭更新位置服务
        //初始化地理编码器
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)setLocationBlock:(void (^)(CLLocationCoordinate2D))locationBlock {
    [_locationManager startUpdatingLocation];
    _isHaveLocation = NO;
    _locationBlock = locationBlock;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"%lu",(unsigned long)locations.count);
    CLLocation *location = locations.lastObject;
    // 纬度
    CLLocationDegrees latitude = location.coordinate.latitude;
    // 经度
    CLLocationDegrees longitude = location.coordinate.longitude;
    _currentLocation = CLLocationCoordinate2DMake(latitude, longitude);
    // 防止多次调用block
    if (!_isHaveLocation && (latitude != 0 && longitude != 0) && _locationBlock) {
        _isHaveLocation = YES;
        _locationBlock(_currentLocation);
    }

    NSLog(@"%@",[NSString stringWithFormat:@"%lf", location.coordinate.longitude]);
    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f", location.coordinate.longitude, location.coordinate.latitude,location.altitude,location.course,location.speed);
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@",placemark.name);
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            // 位置名
            NSLog(@"name,%@",placemark.name);
            // 街道
            NSLog(@"thoroughfare,%@",placemark.thoroughfare);
            // 子街道
            NSLog(@"subThoroughfare,%@",placemark.subThoroughfare);
            // 市
            NSLog(@"locality,%@",placemark.locality);
            // 区
            NSLog(@"subLocality,%@",placemark.subLocality);
            // 国家
            NSLog(@"country,%@",placemark.country);
        }else if (error == nil && [placemarks count] == 0) {
            NSLog(@"No results were returned.");
        } else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
    }];
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    // 防止多次调用block,定位出错也要把错误信息返回
    if (!_isHaveLocation && _locationBlock) {
        _isHaveLocation = YES;
        _locationBlock(_currentLocation);
    }
}

- (void)geocodeAddressString:(NSString *)addressString completionHandler:(CLGeocodeCompletionHandler)completionHandler {
    
}

- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CLGeocodeCompletionHandler)completionHandler {
    
}

@end
