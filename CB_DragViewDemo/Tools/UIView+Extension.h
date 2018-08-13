//
//  UIView+Extension.h
//  快速设置控件frame
//
//  Created by SMART on 15/9/2.
//  Copyright (c) 2015年 SMART. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat bottom_offset;
@property (nonatomic, assign) CGSize size;
+ (instancetype)viewFromXib;
@end
