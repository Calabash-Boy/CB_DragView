//
//  CB_DragView.m
//  圆角裁剪
//
//  Created by 郭现强 on 2018/6/22.
//  Copyright © 2018年 com.calabashboy. All rights reserved.
//

#import "CB_DragView.h"
#import "CB_MenuView.h"

@interface UIView (XYScreenShotExtend)

/**
 对当前view进行截图
 @param shadowOpacity 阴影不透明度
 @param shadowColor 阴影的颜色
 @return 生成新的UIImageView对象
 */
- (UIImageView *)screenshotViewWithShadowOpacity:(CGFloat)shadowOpacity shadowColor:(UIColor *)shadowColor;

@end

@interface CB_DragView()

/** 保存可拖动View */
@property (nonatomic, strong) NSMutableArray *menuViewArray;
/** 起始位置的frame */
@property (nonatomic, assign) CGPoint fromCenter;
/** 起始位置的Menu */
@property (nonatomic, weak) CB_MenuView *fromView;
/** 起始位置的数据索引 */
@property (nonatomic, assign) NSInteger fromIndex;

/** 终点位置的frame */
@property (nonatomic, assign) CGPoint toCenter;
/** 终点位置的Menu */
@property (nonatomic, weak) CB_MenuView *toView;
/** 终点位置的数据索引 */
@property (nonatomic, assign) NSInteger toIndex;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataArray;

/** 被拖动的动画View */
@property (nonatomic, strong) UIView *screenshotView;

@end

@implementation CB_DragView

#pragma mark - life cycle

- (void)awakeFromNib {
    _menuViewArray = [NSMutableArray array];
    [super awakeFromNib];
    
    //把所有的menuView集合到一个数组
    [self traverseAllSubviews:self];
    
    //更新一次界面
    [self updateDataLabel];
    
    //给每个Menu绑定一个长按手势
    for (CB_MenuView *menu in _menuViewArray) {
        //添加一个长按手势
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
        
        [menu addGestureRecognizer:longPress];
    }
}
#pragma mark - private methods
//此方法只是我为了把SB中的CB_MenuView快速集合到数组中 实际开发时布局的时候放到数组中即可
- (void)traverseAllSubviews:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[CB_MenuView class]]) {
            [_menuViewArray addObject:subView];
        }
        if (subView.subviews.count) {
            [self traverseAllSubviews:subView];
        }
    }
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPress {
    
    //首先校验当前的Menu是否可以拖动
    CB_MenuView *menu = (CB_MenuView *)longPress.view;
    UILabel *dataLabel = [menu viewWithTag:110];
    if (!dataLabel.text.length) return;
    
    //当前手指的位置
    CGPoint currentPoint = [longPress locationInView:self];

    if (longPress.state == UIGestureRecognizerStateBegan) {
        //记录刚开始的时候View的位置
        CGRect rect = [menu.superview convertRect:menu.frame toView:self]; //一定要把menu的坐标转换到自己的坐标上
        self.fromCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        self.fromView = menu;
        self.fromIndex = [_menuViewArray indexOfObject:menu];
        [self beginDragAnimation];
    }
    else if (longPress.state == UIGestureRecognizerStateChanged) {
        //拖动过程中移动动画View
        [UIView animateWithDuration:0.1 animations:^{
            CGPoint screenshotViewCenter = self.screenshotView.center;
            screenshotViewCenter.y = currentPoint.y;
            self.screenshotView.center = screenshotViewCenter;
        }];
    
    }
    else {
        self.toView = nil;
        CGRect rect = CGRectZero;
        //拖动结束 查看结束的位置是否处于某个Menu中 如果是 则交换位置
        for (CB_MenuView *menu in _menuViewArray) {
            rect = [menu.superview convertRect:menu.frame toView:self];
            if (CGRectContainsPoint(rect, currentPoint)) {
                self.toView = menu;
                self.toIndex = [_menuViewArray indexOfObject:menu];
                break;
            }
        }
        
        [self endDragAnimation];
    }
}
- (void)exchangeData {
    if (_fromIndex != _toIndex) {
        [self.dataArray exchangeObjectAtIndex:_fromIndex withObjectAtIndex:_toIndex];
        [self updateDataLabel];
    }
}
- (void)updateDataLabel {
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        NSString *data = self.dataArray[i];
        CB_MenuView *menu = _menuViewArray[i];
        UILabel *dataLabel = [menu viewWithTag:110];
        dataLabel.text = data;
    }
}
- (void)endDragAnimation {
    if (self.toView) {
        CGRect rect = [self.toView.superview convertRect:self.toView.frame toView:self];
        self.toCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        //截图 然后交换位置
        UIView *screenshotToView = [self.toView screenshotViewWithShadowOpacity:0.3 shadowColor:[UIColor blackColor]];
        [self addSubview:screenshotToView];
        [self insertSubview:screenshotToView belowSubview:self.screenshotView];
        self.toView.hidden = YES;
        screenshotToView.center = self.toCenter;
        screenshotToView.transform = CGAffineTransformMakeScale(1.03, 1.03);
        
        //此时去交换数据 更新界面
        [self exchangeData];

        //交换位置
        [UIView animateWithDuration:0.3 animations:^{
            //toView -> fromView
            screenshotToView.center = self.fromCenter;
            screenshotToView.transform = CGAffineTransformIdentity;
            
            //fromView -> toView
            self.screenshotView.transform = CGAffineTransformIdentity;
            self.screenshotView.center = self.toCenter;
            
        } completion:^(BOOL finished) {
            [screenshotToView removeFromSuperview];
            self.toView.hidden = NO;
            
            [self.screenshotView removeFromSuperview];
            self.screenshotView = nil;
            self.fromView.hidden = NO;
        }];
    } else {
        //不在任何一个位置 返回原处
        [UIView animateWithDuration:0.3 animations:^{
            self.screenshotView.transform = CGAffineTransformIdentity;
            self.screenshotView.center = self.fromCenter;
        } completion:^(BOOL finished) {
            [self.screenshotView removeFromSuperview];
            self.screenshotView = nil;
            self.fromView.hidden = NO;
            
        }];
    }
}
- (void)beginDragAnimation {
    if (self.screenshotView) {
        [self.screenshotView removeFromSuperview];
        self.screenshotView = nil;
    }
    //产生拖动的截图 隐藏原有截图
    UIView *screenshotView = [self.fromView screenshotViewWithShadowOpacity:0.3 shadowColor:[UIColor blackColor]];
    [self addSubview:screenshotView];
    [self bringSubviewToFront:screenshotView];
    self.screenshotView = screenshotView;
    self.screenshotView.center = self.fromCenter;
    self.fromView.hidden = YES;
    self.screenshotView.transform = CGAffineTransformMakeScale(1.03, 1.03);
}
#pragma mark - setter and getter
//最简单的数据源绑定 开发时请按时间业务来
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSArray *arr = @[@"小师妹",@"",@"大师兄",@"",@"三公主",@"",@"全真弟子1",@"全真弟子2"];
        _dataArray = [NSMutableArray arrayWithArray:arr];
    }
    return _dataArray;
}

@end

@implementation UIView (XYScreenShotExtend)

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
