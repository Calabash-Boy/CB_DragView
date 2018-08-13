//
//  UIView+CB_ScreenShotExtend.h
//  bee2clos
//
//  Created by 郭现强 on 2018/7/9.
//

#import <UIKit/UIKit.h>

@interface UIView (CB_ScreenShotExtend)

/**
 对当前view进行截图
 @param shadowOpacity 阴影不透明度
 @param shadowColor 阴影的颜色
 @return 生成新的UIImageView对象
 */
- (UIImageView *)screenshotViewWithShadowOpacity:(CGFloat)shadowOpacity shadowColor:(UIColor *)shadowColor;

@end
