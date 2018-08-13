//
//  UIView+CB_ScreenShotExtend.m
//  bee2clos
//
//  Created by 郭现强 on 2018/7/9.
//

#import "UIView+CB_ScreenShotExtend.h"

@implementation UIView (CB_ScreenShotExtend)
- (UIImageView *)screenshotViewWithShadowOpacity:(CGFloat)shadowOpacity shadowColor:(UIColor *)shadowColor {
    
    // 开启图形上下文
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 通过图形上下文生成的图片，创建一个和图片尺寸相同大小的imageView，将其作为截图返回
    UIImageView *screenshotImageView = [[UIImageView alloc] initWithImage:image];
    screenshotImageView.center = self.center;
    screenshotImageView.layer.masksToBounds = NO;
    screenshotImageView.layer.cornerRadius = 0.0;
    screenshotImageView.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    screenshotImageView.layer.shadowRadius = 5.0;
    screenshotImageView.layer.shadowOpacity = shadowOpacity;
    screenshotImageView.layer.shadowColor = shadowColor.CGColor;
    return screenshotImageView;
}
@end
