//
//  HotelDragViewTool.m
//  CB_DragViewDemo
//
//  Created by 郭现强 on 2018/8/3.
//  Copyright © 2018年 com.calabashboy. All rights reserved.
//

#import "HotelDragViewTool.h"

@implementation HotelDragViewTool

+ (UILabel *)createCommonLabel:(CGRect)frame fontSize:(float)size color:(UIColor *)color
                          text:(NSString *)text align:(int)align needSizeToFit:(BOOL)need {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textAlignment = align;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:size];
    if(need){
        [label sizeToFit];
    }
    return label;
}
+ (void)drawDashLine:(UIView *)lineView lineWidth:(int)lineW lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2.0, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineW], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}
//快速创建按钮
+ (UIButton *)getCommonButtonWithTitle:(NSString *)title
                            titleColor:(UIColor *)titleColor
                             titleFolt:(UIFont *)font
                       backgroundColor:(UIColor *)backgroundColor {
    
    UIButton *menuBtn = [[UIButton alloc] init];
    [menuBtn setTitle:title forState:UIControlStateNormal];
    [menuBtn setTitleColor:titleColor forState:UIControlStateNormal];
    [menuBtn setTitleColor:titleColor forState:UIControlStateHighlighted];
    menuBtn.titleLabel.font = font;
    [menuBtn setBackgroundColor:backgroundColor];
    menuBtn.layer.cornerRadius = RATENUM(5);
    
    return menuBtn;
}
@end
