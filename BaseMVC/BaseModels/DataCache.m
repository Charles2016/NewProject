//
//  DataCache.m
//  BaseDemo
//
//  Created by chaolong on 16/8/4.
//  Copyright © 2016年 Charles. All rights reserved.
//

#import "DataCache.h"

@implementation DataCache

#pragma mark - memoryCache
+ (NSMutableDictionary*)memoryCache {
    static NSMutableDictionary* cache;
    if (!cache) {
        cache = [NSMutableDictionary dictionary];
    }
    return cache;
}

+ (DataCache *)getMemoryCache:(NSString*)path parameter:(NSString*)parameter {
    DataCache *model = [self memoryCache][[self getKey:path parameter:parameter]];
    return model;
}

+ (BOOL)setMemoryCache:(DataCache *)netCache {
    DataCache *model = [self getMemoryCache:netCache.path parameter:netCache.parameter];
    if ([model.content isEqualToString:netCache.content] && [model.updateDate isEqualToDate:netCache.updateDate]) {
        return NO;
    }
    [self memoryCache][[self getKey:netCache.path parameter:netCache.parameter]] = netCache;
    return YES;
}

+ (NSString*)getKey:(NSString*)path parameter:(NSString*)parameter {
    return [NSString stringWithFormat:@"%@,%@",path,parameter];
}

#pragma mark - DataCacheMethod
+ (LKDBHelper *)getUsingLKDBHelper {
    static LKDBHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        NSArray *paths =
        NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"DataCache.db"];
        helper = [[LKDBHelper alloc] initWithDBPath:path];
    });
    return helper;
}

+ (NSArray *)getPrimaryKeyUnionArray {
    return @[@"path", @"parameter" ];
}

+ (void)queryWithPath:(NSString *)path
            parameter:(NSDictionary *)parameter
               result:(void (^) (DataCache *))block {
    NSString *pathMD5 = [self getMd5_32Bit_String:path uppercase:NO];
    NSString *parameterMD5 = [self getMd5_32Bit_String:[self transformMethodByDictionaryOrJsonStr:parameter] uppercase:NO];
    NSString *where = [NSString stringWithFormat:@"path = '%@' and parameter = '%@'", pathMD5, parameterMD5];
    NSLog (@"queryWithPath%@", parameter);
    [[self getUsingLKDBHelper] search:[self class] where:where orderBy:nil offset:0 count:1 callback:^(NSMutableArray *array) {
        dispatch_async (GetMainQueue, ^{
            DataCache *cache;
            if (array.count > 0) {
                cache = array.firstObject;
            }
            block (cache);
        });
    }];
}

- (instancetype)initWithPath:(NSString *)path
                   parameter:(NSDictionary *)parameter
                     content:(id)content {
    self = [super init];
    if (self) {
        self.path = [[self class] getMd5_32Bit_String:path uppercase:NO];
        self.content = [[self class] contentHandler:content];
        self.parameter = [[self class] getMd5_32Bit_String:[[self class] transformMethodByDictionaryOrJsonStr:parameter] uppercase:NO];
        self.updateDate = [NSDate date];
    }
    return self;
}

+ (void)cacheWithPath:(NSString *)path parameter:(NSDictionary *)parameter content:(id)content {
    DataCache *cache = [[DataCache alloc] initWithPath:path parameter:parameter content:content];
    [[self getUsingLKDBHelper] insertToDB:cache
                                 callback:^(BOOL result){
                                     DLog(@"保存成功");
                                 }];
}

+ (NSString *)contentHandler:(id)content {
    if ([content isKindOfClass:[NSString class]]) {
        return content;
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        return [[self class] transformMethodByDictionaryOrJsonStr:content];
    }
    return @"";
}

@end
