//
//  ViewController.m
//  CB_DragViewDemo
//
//  Created by 郭现强 on 2018/6/28.
//  Copyright © 2018年 com.calabashboy. All rights reserved.
//

#import "ViewController.h"
#import "HotelDragScrollView.h"
#import "HotelDragViewTool.h"

#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xaaaaaa);
    
    NSInteger roomCount = 9;
    NSArray *arr = [self testArrayWithRoomCount:roomCount];
    HotelDragScrollView *dragView = [[HotelDragScrollView alloc] initWithRoomCount:roomCount guestIndexArray:arr];
    [self.view addSubview:dragView];
    [dragView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
    }];
}


- (NSArray *)testArrayWithRoomCount:(NSInteger)roomCount {
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger i = 0; i < roomCount; i++) {
        NSString *name = [NSString stringWithFormat:@"张%zd丰",i + 1];
        NSDictionary *dic = @{@"name" : name};
        [arrM addObject:dic];
        [arrM addObject:@""];
    }
    return [NSArray arrayWithArray:arrM];
}


@end
