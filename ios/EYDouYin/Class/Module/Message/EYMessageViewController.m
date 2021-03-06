//
//  EYMessageViewController.m
//  EYDouYin
//
//  Created by 李二洋 on 2018/7/23.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import "EYMessageViewController.h"

@interface EYMessageViewController ()

@end

@implementation EYMessageViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    EYLog(@"EYMessageViewController--viewDidLoad");
    
    //1. 初始化界面
    [self setupUI];
}

//1. 初始化界面
- (void)setupUI {
    self.gk_navLineHidden = YES;
    self.view.backgroundColor = EYColorRandom;
    
    //1.底部 view
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, EYScreenHeight - EYTabBarHomeIndicatorHeight, EYScreenWidth, EYTabBarHomeIndicatorHeight)];
    bottomView.backgroundColor = EYColorBlack;
    [self.view addSubview:bottomView];
}

@end
