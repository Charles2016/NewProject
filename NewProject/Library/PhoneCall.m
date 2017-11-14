//
//  PhoneCallViewController.h
//  打电话后返回程序
//
//  Created by Long on 14-7-22.
//  Copyright (c) 2014年 Long. All rights reserved.
//

#import "PhoneCall.h"

// the time required to launch the phone app and come back (will be substracted to the duration)
#define kCallSetupTime      3.0

@interface PhoneCall ()

@property (nonatomic, strong) NSDate *callStartTime;
@property (nonatomic, copy) void (^callBlock)();
@property (nonatomic, copy) void (^cancelBlock)();

@end

@implementation PhoneCall

+ (instancetype)sharedInstance {
    static PhoneCall *_instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (BOOL)callPhoneNumber:(NSString *)phoneNumber
                   call:(void(^)(NSTimeInterval duration))callBlock
                 cancel:(void(^)())cancelBlock {
    if ([self validPhone:phoneNumber]) {
         PhoneCall *telPrompt = [PhoneCall sharedInstance];
         // observe the app notifications
        [telPrompt setNotifications];
         // set the blocks
        telPrompt.callBlock = callBlock;
        telPrompt.cancelBlock = cancelBlock;
         // clean the phone number
        NSString *simplePhoneNumber =
        [[phoneNumber componentsSeparatedByCharactersInSet:
          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
         // call the phone number using the telprompt scheme
        NSString *stringURL = [@"telprompt://" stringByAppendingString:simplePhoneNumber];
        BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:stringURL]];
        if (canOpenURL) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
        } else {
            [HXFAlertView alertWithTitle:@"您的设备不支持拨打电话！" message:@"" cancelButton:@"确定" complete:^(NSInteger buttonIndex) {
            }];
        }
         return YES;
    }
    return NO;
}

+ (BOOL)validPhone:(NSString*)phoneString {
    NSTextCheckingType type = [[NSTextCheckingResult phoneNumberCheckingResultWithRange:NSMakeRange(0, phoneString.length) phoneNumber:phoneString] resultType];
    return type == NSTextCheckingTypePhoneNumber;
}


#pragma mark - Notifications
- (void)setNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}


#pragma mark - Events
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // save the time of the call
    self.callStartTime = [NSDate date];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // now it's time to remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     if (self.callStartTime != nil) {
         // I'm coming back after a call
        if (self.callBlock != nil) {
            self.callBlock(-([self.callStartTime timeIntervalSinceNow]) - kCallSetupTime);
        }
         // reset the start timer
        self.callStartTime = nil;
     } else if (self.cancelBlock != nil) {
         // user didn't start the call
        self.cancelBlock();
    }
}

@end
