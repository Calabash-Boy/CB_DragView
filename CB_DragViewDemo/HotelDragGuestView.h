//
//  HotelDragGuestView.h
//  bee2clos
//
//  Created by 郭现强 on 2018/7/4.
//

#import <UIKit/UIKit.h>

@interface HotelDragGuestView : UIView

/** 当前持有的入住人数据 */
@property (nonatomic, strong) id guest;


- (void)updateWithGuest:(id)guest;

/**
 当前位置没有入住人
 
 @return Y/N
 */
- (BOOL)isEmptyGuest;
@end
