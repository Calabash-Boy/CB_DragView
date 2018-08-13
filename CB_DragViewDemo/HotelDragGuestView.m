//
//  HotelDragGuestView.m
//  bee2clos
//
//  Created by 郭现强 on 2018/7/4.
//


#define MaxLabelW (SCREEN_WIDTH - RATENUM(170))

#import "HotelDragGuestView.h"

#import "HotelDragViewTool.h"
#import "UIView+Extension.h"

#import "Masonry.h"

@interface HotelDragGuestView ()

/** 姓名 */
@property (nonatomic, weak) UILabel *nameLabel;

/** 占位label */
@property (nonatomic, weak) UILabel *placeLabel;

@end

@implementation HotelDragGuestView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        //占位文字
        UILabel *placeLabel = [HotelDragViewTool createCommonLabel:CGRectZero
                                                   fontSize:RATENUM(16)
                                                      color:UIColorFromRGB(0xdddddd)
                                                       text:@"拖动游客到此"
                                                      align:NSTextAlignmentLeft
                                                     needSizeToFit:YES];
        [self addSubview:placeLabel];
        self.placeLabel = placeLabel;
        [placeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(RATENUM(16));
            make.left.equalTo(self.mas_left).offset(RATENUM(8));
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        //姓名
        UILabel *nameLabel = [HotelDragViewTool createCommonLabel:CGRectZero
                                                  fontSize:RATENUM(16)
                                                     color:UIColorFromRGB(0x3f3f3f)
                                                      text:nil
                                                     align:NSTextAlignmentLeft
                                                    needSizeToFit:YES];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(RATENUM(16));
            make.left.equalTo(self.mas_left).offset(RATENUM(8));
            make.centerY.equalTo(self.mas_centerY);
        }];
        
    }
    return self;
}

- (void)updateWithGuest:(id)guest {
    if (!guest) return;
    _guest = guest;
    if ([guest isKindOfClass:[NSDictionary class]]) {
        self.nameLabel.hidden = NO;
        self.placeLabel.hidden = YES;
        
        NSDictionary *infoDict = (NSDictionary *)guest;
        
        NSString *ownerName = infoDict[@"name"];
        if (!ownerName.length) {
            ownerName = @"";
        }

        self.nameLabel.text = ownerName;
        CGSize size = [self.nameLabel sizeThatFits:CGSizeMake(MAXFLOAT, self.nameLabel.height)];
        CGFloat w = size.width >= MaxLabelW ? MaxLabelW : size.width;
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(w);
        }];
        
    } else {
        self.placeLabel.hidden = NO;
        self.nameLabel.hidden = YES;
    }
}
- (BOOL)isEmptyGuest {
    return ![_guest isKindOfClass:[NSDictionary class]];
}
@end
