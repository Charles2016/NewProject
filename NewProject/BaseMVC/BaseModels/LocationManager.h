//
//  LocationManager.h
//  CarShop
//
//  Created by dary on 2017/5/12.
//  Copyright © 2017年 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject

@property (nonatomic, copy) void (^locationBlock)(CLLocationCoordinate2D currentLocation);
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

+ (LocationManager *)sharedManager;

@end
