//
//  BaseModel+HUD.m
//  HuiXin
//
//  Created by 文俊 on 15/11/6.
//  Copyright © 2015年 CarMango. All rights reserved.
//

#import "BaseModel+HUD.h"
#import "StatusModel.h"
#import "HUDManager.h"

@implementation BaseModel (HUD)

+ (void)startHUD:(NetworkHUD)networkHUD target:(id)target
{
    
    if (networkHUD > 2 && networkHUD < 6)
    {
        [HUDManager showHUD:MBProgressHUDModeIndeterminate hide:NO afterDelay:kHUDTime enabled:YES message:kNetworkWaitting];
    } else if (networkHUD >= 6 && networkHUD <= 8) {
        if ([target isKindOfClass:[UIViewController class]]) {
            
            [HUDManager showHUDWithMessage:kNetworkWaitting onTarget:((UIViewController *)target).view];
        }
    }
}

+ (void)handleResponse:(StatusModel *)statusModel networkHUD:(NetworkHUD)networkHUD {
    NSString *message = statusModel.Msg;
    NSInteger code = statusModel.Success;
    switch ((NSInteger)networkHUD) {
        case NetworkHUDBackground:
            break;
        case NetworkHUDMsg:
        {
            if (message.length) {
//                [iToast alertWithTitle:message];
            }
        }
            break;
        case NetworkHUDError:
        {
            if (code != 0 && message.length) {
//                [iToast alertWithTitle:message];
            }
        }
            break;
        case NetworkHUDLockScreen:
        {
            [HUDManager hiddenHUD];
        }
            break;
        case NetworkHUDLockScreenButNavWithMsg:
        case NetworkHUDLockScreenAndMsg:
        {
            [HUDManager hiddenHUD];
            if (message.length) {
                
//                [iToast alertWithTitle:message];
            }
        }
            break;
        case NetworkHUDLockScreenButNavWithError:
        case NetworkHUDLockScreenAndError:
        {
            [HUDManager hiddenHUD];
            if (code != 0 && message.length) {
//                [iToast alertWithTitle:message];
            }
        }
            break;
    }
}

@end
