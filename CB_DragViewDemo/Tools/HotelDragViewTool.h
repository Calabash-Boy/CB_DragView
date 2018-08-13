//
//  HotelDragViewTool.h
//  CB_DragViewDemo
//
//  Created by 郭现强 on 2018/8/3.
//  Copyright © 2018年 com.calabashboy. All rights reserved.
//

#define iphone4 SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 480
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define RATENUM(...)  ceil(SCREEN_WIDTH /375 * (__VA_ARGS__))
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import <UIKit/UIKit.h>


@interface HotelDragViewTool : NSObject

+ (UILabel *)createCommonLabel:(CGRect)frame fontSize:(float)size color:(UIColor *)color
                          text:(NSString *)text align:(int)align needSizeToFit:(BOOL)need;

+ (void)drawDashLine:(UIView *)lineView lineWidth:(int)lineW lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

//快速创建按钮
+ (UIButton *)getCommonButtonWithTitle:(NSString *)title
                            titleColor:(UIColor *)titleColor
                             titleFolt:(UIFont *)font
                       backgroundColor:(UIColor *)backgroundColor;
@end
