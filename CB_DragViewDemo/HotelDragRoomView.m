//
//  HotelDragRoomView.m
//  bee2clos
//
//  Created by 郭现强 on 2018/7/4.
//

#define ViewHeight (iphone4 ? RATENUM(70) : RATENUM(88))

#import "HotelDragRoomView.h"

#import "HotelDragViewTool.h"

#import "Masonry.h"

@interface HotelDragRoomView()



@end

@implementation HotelDragRoomView

- (instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        
        self.backgroundColor = UIColorFromRGB(0x1fa4ff);
        self.layer.cornerRadius = RATENUM(5);
        self.clipsToBounds = YES;
        _first = @"";
        _second = @"";

        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ViewHeight);
        }];
        UIView *titleView = [[UIView alloc] init];
        titleView.backgroundColor = [UIColor whiteColor];
        [self addSubview:titleView];
        [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.width.mas_equalTo(RATENUM(75));
        }];
        
        UILabel *roomIndexLabel = [HotelDragViewTool createCommonLabel:CGRectZero
                                                              fontSize:RATENUM(10)
                                                                 color:UIColorFromRGB(0x999999)
                                                                  text:title
                                                                 align:NSTextAlignmentCenter
                                                         needSizeToFit:YES];
        roomIndexLabel.layer.cornerRadius = RATENUM(12);
        roomIndexLabel.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
        roomIndexLabel.layer.borderWidth = 0.5;
        [titleView addSubview:roomIndexLabel];
        [roomIndexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(RATENUM(24));
            make.width.mas_equalTo(RATENUM(50));
            make.centerY.equalTo(titleView.mas_centerY);
            make.left.equalTo(titleView.mas_left).offset(RATENUM(10));
        }];
        
        //中间分隔线
        UIView *dashSeparator = [[UIView alloc] init];
        dashSeparator.frame = CGRectMake(0, 0, SCREEN_WIDTH - RATENUM(110), 1.0);
        [self addSubview:dashSeparator];
        dashSeparator.backgroundColor = [UIColor whiteColor];
        [HotelDragViewTool drawDashLine:dashSeparator lineWidth:1 lineSpacing:3 lineColor:UIColorFromRGB(0xdddddd)];
        [dashSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1.0);
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(titleView.mas_right);
            make.right.equalTo(self.mas_right);
        }];
        
        //第一个入住人
        HotelDragGuestView *firstGuestView = [[HotelDragGuestView alloc] init];
        [self addSubview:firstGuestView];
        self.firstGuestView = firstGuestView;
        [firstGuestView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleView.mas_right);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(dashSeparator.mas_top);
        }];
        
        //第二个入住人
        HotelDragGuestView *secondGuestView = [[HotelDragGuestView alloc] init];
        [self addSubview:secondGuestView];
        self.secondGuestView = secondGuestView;
        [secondGuestView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleView.mas_right);
            make.right.equalTo(self.mas_right);
            make.top.equalTo(dashSeparator.mas_bottom);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    
    return self;
}
#pragma mark - 对外的公共方法
- (void)updateWithfirstGuest:(id)first secondGuest:(id)second {
    if (!first || !second) return;
    _first = first;
    _second = second;
    [self.firstGuestView updateWithGuest:first];
    [self.secondGuestView updateWithGuest:second];
}
- (CGFloat)viewHeight {
    return ViewHeight;
}

@end
