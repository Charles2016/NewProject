#ifndef HKMember_Image_h
#define HKMember_Image_h



#endif
// 图片方法简写
#define kImageName(str) [UIImage imageNamed:str]
// 拉伸图片边框处理
#define kButtonImage(str) [[UIImage imageNamed:str] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]

// 确定按钮
#define button_image     @"button_image"
#define button_image_s   @"button_image_s"

#define MAX_SIZE 120 //　图片最大显示大小
