//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"
#import "HUDManager.h"
#import "AppDelegate.h"

@interface MJPhotoToolbar()
{
    AppDelegate * app;
    // 显示页码
    UILabel *_indexLabel;
//    UIButton *_saveImageBtn;
}
@end

@implementation MJPhotoToolbar

@synthesize Delegate;
@synthesize DeleteImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    // 保存图片按钮
    if (photos.count) {
        CGFloat btnWidth = self.bounds.size.height;
        _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveImageBtn.frame = CGRectMake(20, 0, btnWidth, btnWidth);
        _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _saveImageBtn.userInteractionEnabled = YES;
        [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png"] forState:UIControlStateNormal];
        [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
        [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveImageBtn];
    }
    //1张以上显示索引
    if (_photos.count > 1) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }
}

-(void)deleteThisImage
{
    if ( [Delegate respondsToSelector:@selector(DeleteThisImage:)] ) {
        [Delegate DeleteThisImage:_currentPhotoIndex];
    }
}

- (void)saveImage {
     [HUDManager showHUD:MBProgressHUDModeDeterminate onTarget:self.window hide:YES afterDelay:2.0f enabled:YES message:@"图片保存中..."];
    //关闭保存按钮
    _saveImageBtn.enabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo = _photos[_currentPhotoIndex];
        @weakify(self);
        BOOL isGif = photo.fileType == 4;
        id data = isGif ? photo.url : photo.image;
        if (!data) {
            return;
        }
        if (isGif) {
            // 把image以data保存到相册
            NSData *imageData = [NSData dataWithContentsOfURL:data];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
            [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                @strongify(self);
                [self saveResultWithSource:assetURL];
            }];
        } else {
            [[MLPhotoTool sharePhotoTool] saveSourceWithData:data isVideo:NO returnType:MLReturnTypeAsset complete:^(id source) {
                @strongify(self);
                [self saveResultWithSource:source];
            }];
        }
    });
}

- (void)saveResultWithSource:(id)source {
    dispatch_async(dispatch_get_main_queue(), ^{
        //关闭保存按钮
        _saveImageBtn.enabled = YES;
        if (source) {
            MJPhoto *photo = _photos[_currentPhotoIndex];
            photo.save = YES;
        }
    });
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%zd / %zd", _currentPhotoIndex + 1, _photos.count];
    _saveImageBtn.hidden =!_showSaveBtn;
    _saveImageBtn.enabled = YES;
}

@end
