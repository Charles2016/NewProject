//
//  DataHelper.h
//  CarShop
//
//  Created by Charles on 4/19/17.
//  Copyright © 2017 Charles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHelper : NSObject

/// 根据最小尺寸转换图片
+ (UIImage *)scaleImage:(UIImage *)image toMinSize:(float)size;

/// 根据比例转换图片
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/// 将图片转换成所需尺寸
+ (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size;

/// 获取图片某一点的颜色
+ (UIColor *)getColorAtPoint:(CGPoint)point image:(UIImage *)image;

/// 保存图片到Cache
+ (void)saveImage:(UIImage *)tempImage WithPath:(NSString *)path;

/// 从文档目录下获取路径
+ (NSString *)cachesFolderPathWithName:(NSString *)imageName;

/// 指定路径删除文件
+ (void)removeCachesFolderAtPath:(NSString*)filePath;

/// 获取现在时间
+ (NSString *)getCurrentTime;

/// tableView隐藏多余的线
+ (void)setExtraCellLineHidden:(UITableView *)tableView;

/// 转化DeviceToken
+ (NSString *)conversionDeviceToken:(NSData *)deviceToken;

/// 获取一个随机整数，范围在[from,to），包括from，不包括to
+(int)getRandomNumber:(int)from to:(int)to;

/// 判断gps是否有效
+ (BOOL)gpsIsValidLongitude:(double)longitude latitude:(double)latitude;

/// 唯一字符串
+(NSString *)generateUUID;

/// 颜色设置
+ (UIColor *)colorWithHexString:(NSString *)color;

/// 计算高度
+ (CGFloat)heightWithString:(NSString *)string font:(UIFont *)font constrainedToWidth:(CGFloat)width;

/// 计算宽度
+ (CGFloat)widthWithString:(NSString *)string font:(UIFont *)font;

/// 当需要改变Label中的多段字体多个属性时调用 经改良后单个也可以
+ (NSMutableAttributedString *)getColorsInLabel:(NSString *)allStr colorStrs:(NSArray *)colorStrs colors:(NSArray *)colors fontSizes:(NSArray *)sizes;
+ (NSMutableAttributedString *)getColorsInLabelWithMiddleLine:(NSString *)allStr colorStrs:(NSArray *)colorStrs colors:(NSArray *)colors fontSizes:(NSArray *)sizes;
/// 获得绘制虚线方法
+ (UIView *)getLineWithSize:(CGSize)lineSize separateW:(CGFloat)separateW imaginaryW:(CGFloat)imaginaryW color:(UIColor *)color;

/// 设置textfiled左边的空白
+ (void)setEmptyLeftViewForTextField:(UITextField *)textField withFrame:(CGRect)rect;

/// 给谁谁发信息
+ (NSString *)showPromptMessage:(NSString *)phone;

///  限制textfild 小数位数为2位
+ (BOOL)setRadixPointForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/// 金额输入限制位数，可自定义整数位
+ (BOOL)setlimitForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string number:(int)number;

/// 金额输入限制（首位不能为0）
+ (BOOL)setlimitForTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string number:(int)number shouldBiggerThanOne:(BOOL)bigger;

/// 密码输入长度限制
+ (BOOL)setlimitPwdForTextField:(UITextField *)textField number:(int)number min:(BOOL)min;

/// string to number
+ (NSNumber *)stringToNum:(NSString *)string;

/// 加密手机号
+ (NSString *)getSecretStylePhone:(NSString *)phoneStr;

/// 替换frame 的高度
+ (CGRect)changeFrame:(CGRect)frame setHeight:(CGFloat)height;

/// 设置view的边框属性
+ (void)setlayerWithView:(UIView *)view radius:(CGFloat)radius borderColor:(UIColor *)bordercolor borderWidth:(CGFloat)borderwidth;

/// 获取当前app版本
+ (NSString *)getAppCurrentVersion;

/// 获取当前app包名
+ (NSString *)getBundleIdentifier;

/// 清除本地缓存文件
+ (void)clearCacheFile;

/// 计算本地缓存文件大小
+ (double)getCacheFileSize;

/// 把格式化的JSON格式的字符串转换成字典or数组
+ (id)objectWithJsonString:(NSString *)jsonString;

/// 把数组or字典转换成JSON字符串
+ (NSString *)objectToJsonString:(id)objct;

/// 图片拉伸
+ (UIImage *)resizableImage:(UIImage *)image;

/// 计算时间差（date计算后返回秒）
+ (int)getTimeInterval:(NSDate *)currentDate sinceDate:(NSDate *)sinceDate;

/// 是否是手机号码的字符串
+ (BOOL)isNumberString:(NSString *)string;

/// 网络请求是否异常（如404，500等）
+ (BOOL)webRequestStatus:(NSString *)infoStr;

///判断字符串是否为空
+ (BOOL)isEmptyOrNull:(NSString *) string;
/**
 *  获取文件各项属性方法
 *  @param fileName 文件流
 */
+ (NSData *)applicationDataFromFile:(NSString *)fileName;
///获取图片存储路径
+ (NSString *)getChatImagePathWithName:(NSString *)imageName;

/// 逗号分隔表示金额的字符串
+ (NSString *)spliteMoneyString:(NSString *)moneyStr;

/// 截取小数点后几位方法 moneyStr：金额字符串 nuberCount：保留小数点后几位不做四舍五入
/// 如剧情需要可设置基数加100即可 例：102表示保留2位小数 当值为0.00时自动转换为0
+ (NSString *)interceptMoneyString:(NSString *)moneyStr numberCount:(NSInteger)nuberCount;

///获取星星
+ (NSString *)getStarStr:(NSUInteger)starNum;

/// 是否包含emoj表情
+ (BOOL)stringContainsEmoji:(NSString *)string;

/// 数组中相同的元素只保留一个
+ (NSArray *)arrayWithMemberIsOnly:(NSArray *)array;

/// 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;
/// 是否把keywindow放到最前端
+ (void)bringKeyWindowInFront:(BOOL)isFront;

@end
