//
//  UITextField+Shake.m
//  UITextField+Shake
//
//  Created by Andrea Mazzini on 08/02/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "UITextField+Shake.h"

@implementation UITextField (Shake)

- (void)shake {
    [self shake:10 withDelta:5 completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta {
    [self shake:times withDelta:delta completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta completion:(void(^)())handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 UITextFieldShakeDirection:UITextFieldShakeDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval {
    [self shake:times withDelta:delta speed:interval completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void(^)())handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval UITextFieldShakeDirection:UITextFieldShakeDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval UITextFieldShakeDirection:(UITextFieldShakeDirection)UITextFieldShakeDirection {
    [self shake:times withDelta:delta speed:interval UITextFieldShakeDirection:UITextFieldShakeDirection completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval UITextFieldShakeDirection:(UITextFieldShakeDirection)UITextFieldShakeDirection completion:(void(^)())handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval UITextFieldShakeDirection:UITextFieldShakeDirection completion:handler];
}

- (void)_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval UITextFieldShakeDirection:(UITextFieldShakeDirection)UITextFieldShakeDirection completion:(void(^)())handler {
    [UIView animateWithDuration:interval animations:^{
        self.transform = (UITextFieldShakeDirection == UITextFieldShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (handler) {
                    handler();
                }
            }];
            return;
        }
        [self _shake:(times - 1)
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
               speed:interval
      UITextFieldShakeDirection:UITextFieldShakeDirection
          completion:handler];
    }];
}

@end