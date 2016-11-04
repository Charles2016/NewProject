//
//  FacialView.h
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmoticonView : UIImageView
@property (nonatomic, strong) NSString *emoticonName;
@end

//----------------------------------

@protocol FacialViewDelegate;
@interface FacialView : UIView

@property (nonatomic, weak) id<FacialViewDelegate> delegate;
@property (nonatomic, strong) NSDictionary *facesDic;

-(void)loadFacialView:(int)page;
@end

@protocol FacialViewDelegate <NSObject>

-(void)faciaView:(FacialView *)faciaView selectedEmoticonView:(EmoticonView *)view;

@end