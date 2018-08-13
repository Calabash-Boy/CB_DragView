//
//  HotelDragScrollView.m
//  bee2clos
//
//  Created by 郭现强 on 2018/8/3.
//


#import "HotelDragScrollView.h"
#import "HotelDragRoomView.h"

#import "HotelDragViewTool.h"
#import "UIView+CB_ScreenShotExtend.h"
#import "Masonry.h"

typedef NS_ENUM(NSInteger, HotelDragScrollViewAutoScrollDirection) {
    kHotelDragScrollViewAutoScrollDirectionNone = 0,     // 选中cell的截图没有到达父控件边缘
    kHotelDragScrollViewAutoScrollDirectionTop,          // 选中cell的截图到达父控件顶部边缘
    kHotelDragScrollViewAutoScrollDirectionBottom,       // 选中cell的截图到达父控件底部边缘
};

typedef NS_ENUM(NSInteger, HotelDragScrollViewScrollDirection) {
    kHotelDragScrollViewScrollDirectionNone = 0,     // 不滚动
    kHotelDragScrollViewScrollDirectionUp,          // 向上滚动
    kHotelDragScrollViewScrollDirectionDown,       // 向下滚动
};

@interface HotelDragScrollView ()
/** 原始的排布顺序 */
@property (nonatomic, strong) NSArray *oriIndexArray;

/** 操作时的排布顺序 */
@property (nonatomic, strong) NSMutableArray *operateIndexArray;

/** 所有的可操作View的集合 */
@property (nonatomic, strong) NSMutableArray *guestViewArray;

/** 起始位置的frame */
@property (nonatomic, assign) CGPoint fromCenter;
/** 起始位置的Menu */
@property (nonatomic, weak) HotelDragGuestView *fromView;
/** 起始位置的数据索引 */
@property (nonatomic, assign) NSInteger fromIndex;

/** 过渡过程中的Menu */
@property (nonatomic, weak) HotelDragGuestView *middleView;
/** 过渡过程的数据索引 */
@property (nonatomic, assign) NSInteger middleIndex;
/** 过渡过程的截图 */
@property (nonatomic, weak) UIView *middleSreenShotView;


/** 终点位置的frame */
@property (nonatomic, assign) CGPoint toCenter;
/** 终点位置的Menu */
@property (nonatomic, weak) HotelDragGuestView *toView;
/** 终点位置的数据索引 */
@property (nonatomic, assign) NSInteger toIndex;
/** 被拖动的动画View */
@property (nonatomic, strong) UIView *screenshotView;

/** scrollView */
@property (nonatomic, weak) UIScrollView *scroll;

/** 定时器 */
@property (nonatomic, strong) CADisplayLink *displayLink;

/** 滚动速率 */
@property (nonatomic, assign) CGFloat autoSpeed;

/** 滚动到顶部 */
@property (nonatomic, assign) HotelDragScrollViewAutoScrollDirection scrollDirection;

/** 滚动方向 */
@property (nonatomic, assign) HotelDragScrollViewScrollDirection dragDirection;

/** 当前的滚动点 */
@property (nonatomic, assign) CGFloat lastPointY;

@end

@implementation HotelDragScrollView
- (instancetype)initWithRoomCount:(NSInteger)roomCount guestIndexArray:(NSArray *)guestArray{
    self = [super init];
    if (self) {
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH - RATENUM(16));
        }];
        
        self.backgroundColor = [UIColor clearColor];
        _oriIndexArray = guestArray;
        _operateIndexArray = [NSMutableArray arrayWithArray:guestArray];
        _guestViewArray = [NSMutableArray array];
        _autoSpeed = 10.0;
        //头部的提示标题
        UILabel *tipLabel = [HotelDragViewTool createCommonLabel:CGRectZero
                                                        fontSize:RATENUM(12)
                                                           color:[UIColor whiteColor]
                                                            text:@"长按旅客可以拖动到指定房间"
                                                           align:NSTextAlignmentCenter
                                                   needSizeToFit:YES];
        [self addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(RATENUM(12));
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top);
        }];
        
        //这个位置使用scrollView
        CGFloat scrollH = 0;
        CGFloat viewHeight = 0;
        UIScrollView *scroll = [[UIScrollView alloc] init];
        [self addSubview:scroll];
        self.scroll = scroll;
        [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(tipLabel.mas_bottom).offset(RATENUM(8));
        }];
        
        UIView *lastView = nil;
        NSString *roomTitle = nil;
        id first = nil;
        id second = nil;
        if (roomCount > 0 && guestArray.count >= roomCount * 2) {
            for (NSInteger i = 0; i < roomCount; i++) {
                roomTitle = [NSString stringWithFormat:@"房间%zd",i + 1];
                HotelDragRoomView *roomView = [[HotelDragRoomView alloc] initWithTitle:roomTitle];
                first = guestArray[i * 2];
                second = guestArray[i * 2 + 1];
                [roomView updateWithfirstGuest:first secondGuest:second];
                [_guestViewArray addObject:roomView.firstGuestView];
                [_guestViewArray addObject:roomView.secondGuestView];
                [scroll addSubview:roomView];
                scrollH += [roomView viewHeight];
                viewHeight = [roomView viewHeight];
                [roomView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(self);
                    if (lastView) {
                        make.top.equalTo(lastView.mas_bottom).offset(RATENUM(8));
                    } else {
                        make.top.equalTo(scroll.mas_top);
                    }
                    make.width.equalTo(scroll.mas_width);
                }];
                lastView = roomView;
            }
            if (roomCount > 1) {
                scrollH += (RATENUM(8) * (roomCount - 1));
            }
            if (scrollH > viewHeight * 5 + 4 * RATENUM(8)) { //最大高度5间房
                scrollH = viewHeight * 5 + 4 * RATENUM(8);
            }
            [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(scroll.mas_bottom);
            }];
        }
        
        [scroll mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(scrollH);
        }];
        
        scroll.clipsToBounds = YES;
        
        //添加手势
        for (HotelDragGuestView *guest in _guestViewArray) {
            //添加一个长按手势
            UILongPressGestureRecognizer *longPress =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(longPressGestureRecognized:)];
            longPress.minimumPressDuration = 0.2;
            
            [guest addGestureRecognizer:longPress];
        }
        
        //底部的两个按钮
        UIButton *resetBtn = [HotelDragViewTool getCommonButtonWithTitle:@"重置"
                                                              titleColor:UIColorFromRGB(0x666666)
                                                               titleFolt:[UIFont boldSystemFontOfSize:RATENUM(16)]
                                                         backgroundColor:UIColorFromRGB(0xededed)];
        [self addSubview:resetBtn];
        [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(scroll.mas_bottom).offset(RATENUM(14));
            make.height.mas_equalTo(RATENUM(44));
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_centerX).offset(-RATENUM(4));
            make.bottom.equalTo(self.mas_bottom);
        }];
        [resetBtn addTarget:self action:@selector(resetIndex) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *sureBtn = [HotelDragViewTool getCommonButtonWithTitle:@"确定"
                                                             titleColor:[UIColor whiteColor]
                                                              titleFolt:[UIFont boldSystemFontOfSize:RATENUM(16)]
                                                        backgroundColor:UIColorFromRGB(0x1ea5ff)];
        [self addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(resetBtn);
            make.right.equalTo(self.mas_right);
            make.left.equalTo(self.mas_centerX).offset(RATENUM(4));
        }];
        [sureBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)resetIndex {
    [_operateIndexArray removeAllObjects];
    [_operateIndexArray addObjectsFromArray:_oriIndexArray];
    [self updateWithGuestIndexArray:_operateIndexArray];
}

- (void)sureClick {
    //如果头部有空房间 需要把空房间移动到最后
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    HotelDragGuestView *firstMenu = nil;
    HotelDragGuestView *secondMenu = nil;
    for (NSInteger i = 0; i < _guestViewArray.count / 2; i++) {
        firstMenu = _guestViewArray[i * 2];
        secondMenu = _guestViewArray[i * 2 + 1];
        if ([firstMenu isEmptyGuest] && [secondMenu isEmptyGuest]) { //该房间是空房
            [set addIndex:i * 2];
            [set addIndex:i * 2 + 1];
        }
    }
    if (set.count) {
        [_operateIndexArray removeObjectsAtIndexes:set];
        for (NSInteger i = 0; i < set.count; i++) {
            [_operateIndexArray addObject:@""];
        }
    }
    
    if (self.updateIndexArrayBlock) {
        self.updateIndexArrayBlock(_operateIndexArray);
    }
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPress {
    
    //首先校验当前的Menu是否可以拖动
    HotelDragGuestView *menu = (HotelDragGuestView *)longPress.view;
    if ([menu isEmptyGuest]) return;
    
    //当前手指的位置
    CGPoint currentPoint = [longPress locationInView:self.scroll];
    
    //判断滚动方向
    if (currentPoint.y > self.lastPointY) {
        self.dragDirection = kHotelDragScrollViewScrollDirectionDown;
    } else if (currentPoint.y < self.lastPointY) {
        self.dragDirection = kHotelDragScrollViewScrollDirectionUp;
    } else {
        self.dragDirection = kHotelDragScrollViewScrollDirectionNone;
    }
    self.lastPointY = currentPoint.y;
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        //记录刚开始的时候View的位置
        CGRect rect = [menu.superview convertRect:menu.frame toView:self.scroll];
        self.fromCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        self.fromView = menu;
        self.fromIndex = [_guestViewArray indexOfObject:menu];
        [self beginDragAnimation];
    }
    else if (longPress.state == UIGestureRecognizerStateChanged) {
        
        if ((self.dragDirection == kHotelDragScrollViewScrollDirectionUp && self.scrollDirection != kHotelDragScrollViewAutoScrollDirectionTop) ||
            (self.dragDirection == kHotelDragScrollViewAutoScrollDirectionBottom && self.scrollDirection != kHotelDragScrollViewAutoScrollDirectionBottom) ) {
            //拖动过程中移动动画View
            [UIView animateWithDuration:0.1 animations:^{
                CGPoint screenshotViewCenter = self.screenshotView.center;
                screenshotViewCenter.y = currentPoint.y;
                self.screenshotView.center = screenshotViewCenter;
            }];
        }
        
        //检查是否到达边界 让scrollView开始自动滚动
        if ([self checkIfScreenshotViewMeetsEdge]) {
            [self startAutoScroll];
        } else {
            [self endAutoScroll];
        }
        
    }
    else {
        self.toView = nil;
        CGRect rect = CGRectZero;
        //拖动结束 查看结束的位置是否处于某个Menu中 如果是 则交换位置
        for (HotelDragGuestView *menu in _guestViewArray) {
            rect = [menu.superview convertRect:menu.frame toView:self.scroll];
            if (CGRectContainsPoint(rect, currentPoint)) {
                if (menu != self.fromView) {
                    self.toView = menu;
                    self.toIndex = [_guestViewArray indexOfObject:menu];
                }
                break;
            }
        }
        
        [self endDragAnimation];
    }
}

- (BOOL)checkIfScreenshotViewMeetsEdge {
    
    CGFloat minY = CGRectGetMinY(self.screenshotView.frame);
    CGFloat maxY = CGRectGetMaxY(self.screenshotView.frame);
    if (minY < self.scroll.contentOffset.y) {
        self.scrollDirection = kHotelDragScrollViewAutoScrollDirectionTop;
        return YES;
    }
    if (maxY > self.scroll.bounds.size.height + self.scroll.contentOffset.y) {
        self.scrollDirection = kHotelDragScrollViewAutoScrollDirectionBottom;
        return YES;
    }

    self.scrollDirection = kHotelDragScrollViewAutoScrollDirectionNone;
    
    return NO;
}

- (void)startAutoScroll {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScroll)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)endAutoScroll {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)autoScroll {
    // 设置自动滚动速度
    if (self.autoSpeed == 0.0) {
        self.autoSpeed = 10.0;
    }
    CGFloat autoRollCellSpeed = self.autoSpeed;
    
    if (self.scrollDirection == kHotelDragScrollViewAutoScrollDirectionTop) { //滚动到顶部
        //向上滚动最大范围限制
        if (self.scroll.contentOffset.y > 0) {
            
            self.scroll.contentOffset = CGPointMake(0, self.scroll.contentOffset.y - autoRollCellSpeed);
            self.screenshotView.center = CGPointMake(self.screenshotView.center.x, self.screenshotView.center.y - autoRollCellSpeed);
        }
    } else if (self.scrollDirection == kHotelDragScrollViewAutoScrollDirectionBottom) { // 向下滚动
        //向下滚动最大范围限制
        if (self.scroll.contentOffset.y + self.scroll.bounds.size.height < self.scroll.contentSize.height) {
            
            self.scroll.contentOffset = CGPointMake(0, self.scroll.contentOffset.y + autoRollCellSpeed);
            self.screenshotView.center = CGPointMake(self.screenshotView.center.x, self.screenshotView.center.y + autoRollCellSpeed);
        }
    }
}


- (void)beginDragAnimation {
    if (self.screenshotView) {
        [self.screenshotView removeFromSuperview];
        self.screenshotView = nil;
    }
    //产生拖动的截图 隐藏原有截图
    UIView *screenshotView = [self.fromView screenshotViewWithShadowOpacity:0.3 shadowColor:[UIColor blackColor]];
    [self.scroll addSubview:screenshotView];
    [self.scroll bringSubviewToFront:screenshotView];
    self.screenshotView = screenshotView;
    self.screenshotView.center = self.fromCenter;
    self.fromView.hidden = YES;
    self.screenshotView.transform = CGAffineTransformMakeScale(1.03, 1.03);
}
- (void)endDragAnimation {
    
    [self endAutoScroll];
    
    if (self.toView) {
        CGRect rect = [self.toView.superview convertRect:self.toView.frame toView:self.scroll];
        self.toCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        //截图 然后交换位置
        UIView *screenshotToView = [self.toView screenshotViewWithShadowOpacity:0.3 shadowColor:[UIColor blackColor]];
        [self.scroll insertSubview:screenshotToView belowSubview:self.screenshotView];
        screenshotToView.center = self.toCenter;
        screenshotToView.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self.toView.hidden = YES;
        
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
            
            //从隐藏出来后再显示一遍
            [self updateWithGuestIndexArray:self.operateIndexArray];
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

- (void)exchangeData {
    if (_fromIndex != _toIndex) {
        [_operateIndexArray exchangeObjectAtIndex:_fromIndex withObjectAtIndex:_toIndex];
    }
}
- (void)updateWithGuestIndexArray:(NSArray *)guestIndex {
    for (NSInteger i = 0; i < guestIndex.count; i++) {
        id guest = guestIndex[i];
        HotelDragGuestView *menu = _guestViewArray[i];
        [menu updateWithGuest:guest];
    }
}

@end
