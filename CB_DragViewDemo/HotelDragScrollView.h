//
//  HotelDragScrollView.h
//  bee2clos
//
//  Created by 郭现强 on 2018/8/3.
//


#import <UIKit/UIKit.h>


@interface HotelDragScrollView : UIView
/**
 入住旅客房间分配的界面
 
 @param roomCount 房间数
 @param guestArray 旅客入住顺序
 @return 排序好的入住房间
 */
- (instancetype)initWithRoomCount:(NSInteger)roomCount
                  guestIndexArray:(NSArray *)guestArray;

/** 点击确定后的回调 */
@property (nonatomic , copy) void(^updateIndexArrayBlock)(NSMutableArray *indexArray);

@end
