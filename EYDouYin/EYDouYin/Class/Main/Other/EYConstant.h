//
//  EYConstant.h
//  EYDouYin
//
//  Created by lieryang on 2016/11/5.
//  Copyright © 2016年 lieryang. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 通用枚举

typedef NS_ENUM(NSInteger, EYJumpType) {
    EYJumpTypeDefault,      // 默认值
    
    #pragma mark - 界面上的按钮
    
    
    #pragma mark - 跳转方式
    //其他地方--->首页
    
    //其他地方--->我的
    EYJumpTypeHomeToMe,     // 首页--->我的
};

#pragma mark - 阿里云

UIKIT_EXTERN NSString *const TTOSSAPPStoreEndpoint;
UIKIT_EXTERN NSString *const TTTXVodPlayConfigPath;
