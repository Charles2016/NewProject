//
//  UIView+Shake.m
//  UIView+Shake
//
//  Created by Andrea Mazzini on 08/02/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "UIView+Shake.h"

@implementation UIView (Shake)

- (void)shake {
    [self _shake:10 direction:1 currentTimes:0 withDelta:5 speed:0.03 UIViewShakeDirection:UIViewShakeDirectionHorizontal completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 UIViewShakeDirection:UIViewShakeDirectionHorizontal completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta completion:(void(^)())handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:0.03 UIViewShakeDirection:UIViewShakeDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval UIViewShakeDirection:UIViewShakeDirectionHorizontal completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void(^)())handler {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval UIViewShakeDirection:UIViewShakeDirectionHorizontal completion:handler];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval UIViewShakeDirection:(UIViewShakeDirection)UIViewShakeDirection {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval UIViewShakeDirection:UIViewShakeDirection completion:nil];
}

- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval UIViewShakeDirection:(UIViewShakeDirection)UIViewShakeDirection completion:(void (^)(void))completion {
    [self _shake:times direction:1 currentTimes:0 withDelta:delta speed:interval UIViewShakeDirection:UIViewShakeDirection completion:completion];
}

- (void)_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval UIViewShakeDirection:(UIViewShakeDirection)UIViewShakeDirection completion:(void (^)(void))completionHandler {
    [UIView animateWithDuration:interval animations:^{
        self.layer.affineTransform = (UIViewShakeDirection == UIViewShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (completionHandler != nil) {
                    completionHandler();
                }
            }];
            return;
        }
        [self _shake:(times - 1)
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
               speed:interval
      UIViewShakeDirection:UIViewShakeDirection
          completion:completionHandler];
    }];
}

@end
