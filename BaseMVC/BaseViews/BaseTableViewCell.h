//
//  BaseTableViewCell.h
//  ZQB
//
//  Created by YangXu on 14-7-18.
//
//

#import <UIKit/UIKit.h>

#define kDefaultShortLineInset 10
#define kSPLineH 0.5

// 分割线样式
typedef NS_ENUM(NSInteger, SeperateStyle)
{
    SeperateStyle_LTLB = 3,   // 上下长线
    SeperateStyle_LTSB,       // 上长下短线
    SeperateStyle_LTNB,       // 上长下无线
    SeperateStyle_NTLB,       // 上无下长线
    SeperateStyle_NTSB        // 上无下短线
};

@protocol CellHeightProtocol <NSObject>

@optional
+ (CGFloat)cellDefaultHeight;
+ (CGFloat)cellHeightWithContent:(NSString *)content;
+ (CGFloat)sectionHeaderDefaultHeight;
+ (CGFloat)sectionHeaderHeightWithContent:(NSString *)content;

@end

@interface BaseTableViewCell : UITableViewCell <CellHeightProtocol>

/// 短线默认缩进 15px
- (void)setSeperateStyle:(SeperateStyle)style;
/// 自定义短线缩进
- (void)setSeperateStyle:(SeperateStyle)style shortLineInset:(CGFloat)inset;
/// 一般的上长中短下长风设置
- (void)setSeperateStyleWithDataSourceCount:(NSInteger)count rowIndex:(NSInteger)rowIndex;
/// 没有缩进
- (void)setSeperateNoInsetStyleWithDataSourceCount:(NSInteger)count rowIndex:(NSInteger)rowIndex;
/// 自定义缩进
- (void)setSeperateCustomInsetStyleWithDataSourceCount:(NSInteger)count rowIndex:(NSInteger)rowIndex inset:(CGFloat)inset;
@end
