//
//  HotelDragRoomView.h
//  bee2clos
//
//  Created by 郭现强 on 2018/7/4.
//




#import <UIKit/UIKit.h>

#import "HotelDragGuestView.h"

@interface HotelDragRoomView : UIView

/** 第一入住人 */
@property (nonatomic, strong) id first;
/** 第二入住人 */
@property (nonatomic, strong) id second;


/** 第一入住人控件 */
@property (nonatomic, weak) HotelDragGuestView *firstGuestView;
/** 第二入住人控件 */
@property (nonatomic, weak) HotelDragGuestView *secondGuestView;

/**
 创建房间
 
 @param title 房间序号

 @return 分配好的单个房间
 */
- (instancetype)initWithTitle:(NSString *)title;

/**
 单个房间的入住分配
 @param first 第一个入住乘客
 @param second 第二个入住乘客
 */
- (void)updateWithfirstGuest:(id)first secondGuest:(id)second;

/**
 获取高度
 
 @return 展示出来的高度
 */
- (CGFloat)viewHeight;

@end
