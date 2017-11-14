//
//  DataCache.h
//  BaseDemo
//
//  Created by chaolong on 16/8/4.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "BaseModel.h"

@interface DataCache : BaseModel

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *parameter;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSDate *updateDate;

+ (void)queryWithPath:(NSString *)path
            parameter:(NSDictionary *)parameter
               result:(void (^)(DataCache *))block;

- (instancetype)initWithPath:(NSString *)path
                   parameter:(NSDictionary *)parameter
                     content:(id)content;

+ (void)cacheWithPath:(NSString *)path
            parameter:(NSDictionary *)parameter
              content:(id)content;


@end
