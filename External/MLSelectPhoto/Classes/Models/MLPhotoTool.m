//
//  MLPhotoTool.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "MLPhotoTool.h"

@implementation MLPhotoTool

static MLPhotoTool *sharePhotoTool = nil;


+ (instancetype)sharePhotoTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [[self alloc] init];
    });
    return sharePhotoTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [super allocWithZone:zone];
    });
    return sharePhotoTool;
}

- (ALAssetsLibrary *)library {
    if (!_library) {
        _library = [[ALAssetsLibrary alloc] init];
    }
    return _library;
}

/// 获取最新一张图片
- (void)getLatestDataWithReturnType:(MLReturnType)returnType sourceType:(MLSourceType)sourceType complete:(void(^)(id asset))complete {
    if (ML_ISIOS8) {
        // 获取所有资源的集合，并按资源的创建时间排序
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHAssetMediaType mediaType;
        if (sourceType == MLSourceVideo) {
            mediaType = PHAssetMediaTypeVideo;
        } else if (sourceType == MLSourcePhoto) {
            mediaType = PHAssetMediaTypeImage;
        } else if (sourceType == MLSourceAudio) {
            mediaType = PHAssetMediaTypeAudio;
        } else {
            mediaType = PHAssetMediaTypeUnknown;
        }
        PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithMediaType:mediaType options:options];
        if (returnType == MLReturnTypeAsset) {
            complete([assetsFetchResults firstObject]);
        } else if (returnType == MLReturnTypeImage) {
            [self getThumbImageWithAsset:[assetsFetchResults firstObject] complete:^(UIImage *thumbImage) {
                complete(thumbImage);
            }];
        } else if (returnType == MLReturnTypeURL) {
            
        }
    } else {
        [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:sourceType == MLSourceVideo ? [ALAssetsFilter allVideos] : [ALAssetsFilter allPhotos]];
                [group enumerateAssetsWithOptions:NSEnumerationReverse/*遍历方式*/ usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        if (returnType == MLReturnTypeAsset) {
                            complete(result);
                        } else {
                            [self getThumbImageWithAsset:result complete:^(UIImage *thumbImage) {
                                complete(thumbImage);
                            }];
                        }
                        *stop = YES;
                    }
                }];
                *stop = YES;
            }
        } failureBlock:^(NSError *error) {
            DLog(@"error:%@", error);
        }];
    }
}

/// 获取所有相册列表，sourceType资源类型
- (void)getAllDataWithSourceType:(MLSourceType)sourceType complete:(void(^)(NSArray *photoAblumList))complete {
    __block NSMutableArray *photoAblumLists = [NSMutableArray array];
    if (ML_ISIOS8) {
        mWeakSelf;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusNotDetermined && status != PHAuthorizationStatusDenied) {
                [weakSelf getSourceWithSourceType:sourceType photoAblumLists:photoAblumLists complete:complete];
            }
        }];
    } else {
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
            if (assetsGroup) {
                if (sourceType == MLSourcePhoto) {
                    // 筛选图片资源
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                    [self getPhotoAssetsInfo:assetsGroup photoAblumLists:photoAblumLists sourceType:sourceType];
                } else if (sourceType == MLSourceVideo) {
                    // 筛选视频资源
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                    [self getPhotoAssetsInfo:assetsGroup photoAblumLists:photoAblumLists sourceType:sourceType];
                } else {
                    // 筛选声音资源
                }
            } else {
              complete(photoAblumLists);
            }
        } failureBlock:^(NSError *error) {
            if (error.code == -3311) {
                // ALAssetsLibraryAccessUserDeniedError
                DLog(@"用户拒绝访问相册");
            }
        }];
    }
}

/// 传入相册集，获取该相册集中所有asset，sourceType资源类型
- (void)getAllDataWithAssetsGroup:(id)assetsGroup sourceType:(MLSourceType)sourceType isAscending:(BOOL)isAscending complete:(void(^)(NSArray *photoAsset))complete {
    NSMutableArray *assets = [NSMutableArray array];
    mWeakSelf;
    if (ML_ISIOS8) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:assetsGroup ascending:isAscending];
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MLSourceType type = [weakSelf getSourceTypeWithAsset:obj];
            // 过滤掉不同类型
            if (sourceType == type) {
                [assets addObject:obj];
            }
        }];
    } else {
        [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset) {
                MLSourceType type = [weakSelf getSourceTypeWithAsset:asset];
                // 过滤掉不同类型
                if (sourceType == type) {
                    [assets addObject:asset];
                }
            }
        }];
        if (!isAscending) {
            assets = [[[assets reverseObjectEnumerator] allObjects] copy];
        }
    }
    complete(assets);
}

/// 传入单张图片asset获取对应信息后返回
- (void)getPhotoInfo:(id)asset complete:(void(^)(MLSelectPhotoAssets *photoAsset))complete {
    MLSelectPhotoAssets *photoAsset = [[MLSelectPhotoAssets alloc] init];
    photoAsset.asset = asset;
    photoAsset.sourceType = [self getSourceTypeWithAsset:asset];
    [self getFullImageWithAsset:asset complete:^(UIImage *fullImage) {
        photoAsset.fullImage = fullImage;
    }];
    [self getThumbImageWithAsset:asset complete:^(UIImage *thumbImage) {
        photoAsset.thumbImage = thumbImage;
    }];
    complete(photoAsset);
}

/// 传入asset获取文件类型
- (MLSourceType)getSourceTypeWithAsset:(id)asset {
    MLSourceType sourceType;
    if (ML_ISIOS8) {
        PHAssetMediaType type = ((PHAsset *)asset).mediaType;
        if (type == PHAssetMediaTypeImage) {
            sourceType = MLSourcePhoto;
        } else if (type == PHAssetMediaTypeVideo) {
            sourceType = MLSourceVideo;
        } else if (type == PHAssetMediaTypeAudio) {
            sourceType = MLSourceAudio;
        } else {
            sourceType = MLSourceOthers;
        }
    } else {
        NSString *type = (NSString *)[asset valueForProperty:ALAssetPropertyType];
        if ([type isEqualToString:ALAssetTypeVideo]) {
            sourceType = MLSourceVideo;
        } else if ([type isEqualToString:ALAssetTypePhoto]) {
            sourceType = MLSourcePhoto;
        } else {
            sourceType = MLSourceAudio;
        }
    }
    return sourceType;
}

/// 传入asset获取缩略图
- (void)getThumbImageWithAsset:(id)asset complete:(void(^)(UIImage *thumbImage))complete {
    [self getThumbImageWithGifAsset:asset gifCare:NO complete:complete];
}

// 传入asset获取缩略图(若是gif格式&&gifCare则返回imageData, 若是普通格式图片则返回image)
- (void)getThumbImageWithGifAsset:(id)asset gifCare:(BOOL)gifCare complete:(void(^)(id thumbImage))complete {
    if (ML_ISIOS8) {
        [self requestImageWitGifForAsset:asset gifCare:gifCare size:CGSizeMake(200, 200) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(id image, NSDictionary *info) {
            complete(image);
        }];
    } else {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte *)malloc((unsigned long)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
        NSData *imageData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        MLSourceType type = [self getSourceTypeWithAsset:asset];
        if (gifCare && [self isGifAsset:asset]) {
            complete(imageData);
        } else if (type == MLSourceVideo) {
            complete([UIImage imageWithCGImage:[asset thumbnail]]);
        } else {
            complete([UIImage imageWithData:imageData]);
        }
    }
}

/// 传入asset获取原图
- (void)getFullImageWithAsset:(id)asset complete:(void(^)(UIImage *fullImage))complete {
    [self getFullImageWithGifAsset:asset gifCare:NO complete:complete];
}

// 传入asset获取原图(若是gif格式&&gifCare则返回imageData, 若是普通格式图片则返回image)
- (void)getFullImageWithGifAsset:(id)asset gifCare:(BOOL)gifCare complete:(void(^)(id fullImage))complete {
    if (ML_ISIOS8) {
        [self requestImageWitGifForAsset:asset gifCare:gifCare size:PHImageManagerMaximumSize resizeMode:PHImageRequestOptionsResizeModeFast completion:^(id image, NSDictionary *info) {
            if (info[@"PHImageFileURLKey"]) {
                complete(image);
            }
        }];
    } else {
        id image;
        if (gifCare && [self isGifAsset:asset]) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
            image = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        } else {
            image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        }
        complete(image);
    }
}

/// 传入相册集取到相册第一张缩略图
- (void)getFirstThumbWithAssetGroup:(id)assetGroup sourceType:(MLSourceType)sourceType complete:(void(^)(UIImage *thumbImage))complete {
    if (ML_ISIOS8) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:assetGroup ascending:YES];
        if (result.count > 0) {
            [self requestImageForAsset:result.lastObject size:CGSizeMake(200, 200) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
                complete(image);
            }];
        }
    } else {
        complete([UIImage imageWithCGImage:[((ALAssetsGroup *)assetGroup) posterImage]]);
    }    
}

/// 传入相册集取到该相册标题，图片或视频数量等信息suorce筛选的类型
- (void)getPhotoAssetsInfo:(id)assets photoAblumLists:(NSMutableArray *)photoAblumLists sourceType:(MLSourceType)sourceType {
    NSString *title;
    NSInteger assetsCount = 0;
    if (ML_ISIOS8) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:assets ascending:YES];
        PHAssetMediaType type;
        if (sourceType == MLSourcePhoto) {
            type = PHAssetMediaTypeImage;
        } else if (sourceType == MLSourceVideo) {
            type = PHAssetMediaTypeVideo;
        } else if (sourceType == MLSourceAudio) {
            type = PHAssetMediaTypeAudio;
        } else {
            type = PHAssetMediaTypeUnknown;
        }
        assetsCount = [result countOfAssetsWithMediaType:type];
        title = ((PHAssetCollection *)assets).localizedTitle;
    } else {
        assetsCount = [assets numberOfAssets];
        title = (NSString *)[assets valueForProperty:@"ALAssetsGroupPropertyName"];
    }
    // 包装一个模型来赋值
    if (assetsCount) {
        MLSelectPhotoPickerGroup *photoAblumList = [[MLSelectPhotoPickerGroup alloc] init];
        photoAblumList.assetsGroup = assets;
        photoAblumList.title = title;
        photoAblumList.assetsCount = assetsCount;
        [self getFirstThumbWithAssetGroup:assets sourceType:sourceType complete:^(UIImage *thumbImage) {
            photoAblumList.thumbImage = thumbImage;
        }];
        [photoAblumLists addObject:photoAblumList];
    }
}

/// 传入asset判断是否是同一个用于小图和原图时的比较
- (BOOL)isSameAsset:(id)asset asset:(id)otherAsset {
    BOOL isSame = NO;
    if (ML_ISIOS8) {
        // 取到名字，判断名字是否一样
        NSString *assetName = [asset valueForKey:@"filename"];
        NSString *otherName = [otherAsset valueForKey:@"filename"];
        isSame = [assetName isEqualToString:otherName];
    } else {
        NSString *urlStr = [((ALAsset *)asset) defaultRepresentation].url.absoluteString;
        NSString *otherStr = [((ALAsset *)otherAsset) defaultRepresentation].url.absoluteString;
        isSame = [urlStr isEqualToString:otherStr];
    }
    return isSame;
}

/// 判断gif资源图片
- (BOOL)isGifAsset:(id)asset {
    if (ML_ISIOS8) {
        // gif后缀or图片名检测
        NSString *suffixStr = [asset valueForKey:@"uniformTypeIdentifier"];
        NSString *nameStr = [asset valueForKey:@"filename"];
        if ([nameStr rangeOfString:@".GIF"].length || [suffixStr rangeOfString:@".gif"].length) {
            return YES;
        }
    } else {
        // iOS7通过图片张数来判断是否为gif图片
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
        NSData *imageData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        CGImageSourceRef gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
        NSInteger imageCount = CGImageSourceGetCount(gifSourceRef);
        return imageCount > 1 ? YES : NO;
    }
    return NO;
}

/// 传URL取到对应的图片信息
- (id)getAssetWithURL:(NSURL *)url {
    __block id photoAsset;
    if (ML_ISIOS8) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        photoAsset = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:option].lastObject;
    } else {
        [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
            photoAsset = asset;
        } failureBlock:nil];
    }
    return photoAsset;
}

/// 传入图片or视频进行保存，返回指定类型asset或url
- (void)saveSourceWithData:(id)data isVideo:(BOOL)isVideo returnType:(MLReturnType)returnType complete:(void(^)(id source))complete {
    __block id photoSource;
    // 判断是否获得所需资源，防止回调两次
    __block BOOL isGetSource;
    if (ML_ISIOS8) {
        __block NSString *assetId = nil;
        // 1. 存储图片到"相机胶卷"
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{ // 这个block里保存一些"修改"性质的代码
            // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
            // 返回PHAsset(图片)的字符串标识
            PHAssetChangeRequest *changeRequest;
            if (isVideo) {
                NSURL *url = [data isKindOfClass:[NSString class]] ? [NSURL URLWithString:data] : data;
                // 保存视频到相册
                changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            } else {
                if ([data isKindOfClass:[UIImage class]]) {
                    //保存图片到相册
                    changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:data];
                }/* else if ([data isKindOfClass:[NSArray class]]) {
                    NSData *tempData = [NSKeyedArchiver archivedDataWithRootObject:data];
                    imageData = [UIImage imageWithData:tempData];
                }*/ else {
                    id imageData;
                    NSURL *url = [data isKindOfClass:[NSString class]] ? [NSURL URLWithString:data] : data;
                    NSData *tempData = [NSData dataWithContentsOfURL:url];                    
//                    imageData = [UIImage imageWithData:tempData];
                    imageData = [UIImage animatedImageWithAnimatedGIFData:tempData];
                    //保存图片到相册
                    changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:imageData];
                }
            }
            assetId = changeRequest.placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError *error) {
            if (error) {
                // 保存图片到相机胶卷中失败
                complete(nil);
            } else {
                // 成功保存图片到相机胶卷中
                // 2. 获得相册对象
                [self collection:^(id collection) {
                    // 3. 将“相机胶卷”中的图片添加到新的相册
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                        // 根据唯一标示获得相片对象
                        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                        // 添加图片到相册中
                        [request addAssets:@[asset]];
                        [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                            if (returnType == MLReturnTypeURL) {
                                photoSource = contentEditingInput.fullSizeImageURL;
                            } else {
                                photoSource = asset;
                            }
                            if (photoSource && !isGetSource) {
                                isGetSource = YES;
                                complete(photoSource);
                            }
                        }];
                    } completionHandler:^(BOOL success, NSError *error) {
                        if (error) {
                            // 保存照片到自定义相册失败
                            complete(nil);
                        } else {
                            // 保存照片到自定义相册成功带回照片信息
                            if (photoSource && !isGetSource ) {
                                isGetSource = YES;
                                complete(photoSource);
                            }
                        }
                    }];
                }];
            }
        }];
    } else {
        @weakify(self);
        if (isVideo) {
            // 保存视频到相册
            NSURL *videoUrl = [data isKindOfClass:[NSString class]] ? [NSURL URLWithString:data] : data;
            [self.library writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
                @strongify(self);
                [self saveDataResultWithURL:assetURL error:error returnType:returnType complete:complete];
            }];
        } else {
            // 保存图片到相册
            if ([data isKindOfClass:[UIImage class]]) {
                UIImage *image = data;
                [self.library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
                    @strongify(self);
                    [self saveDataResultWithURL:assetURL error:error returnType:returnType complete:complete];
                }];
            } else {
                // 把image以data保存到相册
                NSData *imageData = [NSData dataWithContentsOfURL:data];
                [self.library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    @strongify(self);
                    [self saveDataResultWithURL:assetURL error:error returnType:returnType complete:complete];
                }];
//                UIImageWriteToSavedPhotosAlbum() 
            }
        }
    }
}

- (void)saveDataResultWithURL:(NSURL *)assetURL error:(NSError *)error returnType:(MLReturnType)returnType complete:(void(^)(id source))complete {
    if (error) {
        NSLog(@"Save image fail：%@",error);
        // 保存照片到自定义相册失败
        complete(nil);
    } else {
        if (returnType == MLReturnTypeURL) {
            complete(assetURL);
        } else {
            @weakify(self)
            [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                @strongify(self);
                [self collection:^(id collection) {
                    [(ALAssetsGroup *)collection addAsset:asset];
                    complete(asset);
                }];
            } failureBlock:nil];
        }
    }
    
}

/// 保存图片到指定相册
- (void)saveImage:(UIImage *)image {
    if (ML_ISIOS8) {
        /*
         PHAsset : 一个PHAsset对象就代表一个资源文件,比如一张图片
         PHAssetCollection : 一个PHAssetCollection对象就代表一个相册
         */
        __block NSString *assetId = nil;
        // 1. 存储图片到"相机胶卷"
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{ // 这个block里保存一些"修改"性质的代码
            // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
            // 返回PHAsset(图片)的字符串标识
            assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError *error) {
            if (error) {
                DLog(@"保存图片到相机胶卷中失败");
            } else {
                DLog(@"成功保存图片到相机胶卷中");
                // 2. 获得相册对象
                [self collection:^(id collection) {
                    // 3. 将“相机胶卷”中的图片添加到新的相册
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                        // 根据唯一标示获得相片对象
                        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                        // 添加图片到相册中
                        [request addAssets:@[asset]];
                    } completionHandler:^(BOOL success, NSError *error) {
                        if (error) {
                            DLog(@"添加图片到相册中失败");
                            return;
                        } else {
                            DLog(@"保存成功");
                        }
                    }];
                }];
            }
        }];
    } else {
        [self.library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                DLog(@"保存失败");
            } else {
                DLog(@"保存成功");
            }
        }];
    }
    
}

/// 查找或创建相册
- (void)collection:(void(^)(id collection))complete {
    if (ML_ISIOS8) {
        // 先获得之前创建过的相册
        PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in collectionResult) {
            if ([collection.localizedTitle isEqualToString:@"扑多相册"]) {
                complete(collection);
                return;
            }
        }
        // 如果相册不存在,就创建新的相册(文件夹)
        // 这个方法会在相册创建完毕后才会返回
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
            NSString *collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"扑多相册"].placeholderForCreatedAssetCollection.localIdentifier;
            complete([PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject);
        } error:nil];
    } else {
        // 获取相册
        @weakify(self);
        [self getGroupWithName:@"扑多相册" complete:^(id getGroup) {
            if (!getGroup) {
                // 若获取不到相册，则创建相册
                @strongify(self);
                [self createGroupWithName:@"扑多相册" complete:^(id createGroup) {
                    if (createGroup) {
                        complete(createGroup);
                    }
                }];
            } else {
                complete(getGroup);
            }
        }];
    }
}

/// 相册标题转换方法
- (NSString *)transformAblumTitle:(NSString *)title {
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    } else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    }
    return nil;
}

#pragma mark - iOS7的相册操作
// iOS7获取对应相册方法
- (void)getGroupWithName:(NSString *)groupName complete:(void(^)(id getGroup))complete {
    __block BOOL isGetSource;
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        NSString *name = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        if ([groupName isEqual:name]) {
            *stop = YES;// 找到相册后停止遍历
            isGetSource = YES;
            complete(assetsGroup);
        }
        if (!assetsGroup) {
            complete(assetsGroup);
        }
    } failureBlock:^(NSError *error) {
        if (error.code == -3311) {
            // ALAssetsLibraryAccessUserDeniedError
            DLog(@"用户拒绝访问相册");
        }
    }];
}

// iOS7创建对应相册方法
- (void)createGroupWithName:(NSString *)groupName complete:(void(^)(id createGroup))complete {
    [self.library addAssetsGroupAlbumWithName:groupName resultBlock:^(ALAssetsGroup *group) {
        complete(group);
    } failureBlock:^(NSError *error) {
    }];
}

#pragma mark - iOS8及以上的相册操作
/// 判断第一次授权情况再取所有相册
- (void)getSourceWithSourceType:(MLSourceType)sourceType photoAblumLists:(NSMutableArray *)photoAblumLists complete:(void(^)(NSArray *photoAblumList))complete  {
    // 获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    mWeakSelf;
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        // 过滤掉视频和最近删除
        if (![collection.localizedTitle isEqualToString:@"Recently Deleted"] && ![collection.localizedTitle isEqualToString:@"最近删除"]) {
            if (sourceType == MLSourcePhoto) {
                // 筛选图片资源
                if (![collection.localizedTitle isEqualToString:@"Videos"] && ![collection.localizedTitle isEqualToString:@"视频"]) {
                    [weakSelf getPhotoAssetsInfo:collection photoAblumLists:photoAblumLists sourceType:sourceType];
                }
            } else if (sourceType == MLSourceVideo) {
                // 筛选视频资源
                if ([collection.localizedTitle isEqualToString:@"Videos"] || [collection.localizedTitle isEqualToString:@"视频"]) {
                    [weakSelf getPhotoAssetsInfo:collection photoAblumLists:photoAblumLists sourceType:sourceType];
                }
            } else {
                // 筛选声音资源
            }
        }
    }];
    // 获取用户创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        [weakSelf getPhotoAssetsInfo:collection photoAblumLists:photoAblumLists sourceType:sourceType];
    }];
    complete(photoAblumLists);
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

/// 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image, NSDictionary *info))completion {
    [self requestImageWitGifForAsset:asset gifCare:NO size:size resizeMode:resizeMode completion:completion];
}


/// 获取asset对应的图片(若是gif格式&&gifCare则返回imageData, 若是普通格式图片则返回image)
- (void)requestImageWitGifForAsset:(PHAsset *)asset gifCare:(BOOL)gifCare size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(id image, NSDictionary *info))completion {
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = resizeMode;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    //option.synchronous = YES;
    option.networkAccessAllowed = YES;
    if (gifCare && [self isGifAsset:asset]) {
        [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            completion(imageData, info);
        }];
    } else {
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        //contetModel
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *image, NSDictionary *info) {
            completion(image, info);
        }];
    }
}


@end
