//
//  EYHomeViewController.m
//  EYDouYin
//
//  Created by 李二洋 on 2018/7/23.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import "EYHomeViewController.h"
#import "EYHomeCityViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EYHomePlayViewController.h"

@interface EYHomeViewController () <UIScrollViewDelegate>

// 滚动视图
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) EYHomePlayViewController *toptopVC;//上
@property (weak, nonatomic) EYHomePlayViewController *centerVC;//中
@property (weak, nonatomic) EYHomePlayViewController *bottomVC;//下

@property (strong, nonatomic) NSMutableArray <EYVideoModel *>*arrarM;

// 当前屏幕所处的下标
@property (assign, nonatomic) NSUInteger currentVideoIndex;

// 当前屏幕所属的控制器
@property (weak, nonatomic, readwrite) EYHomePlayViewController *currentPlayViewController;

@end

@implementation EYHomeViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //0.当前播放下标
    self.currentVideoIndex = 0;
    
    //1.初始化界面
    [self setupUI];
    
    //2.添加通知
    [self addNotification];
    
    //3.模拟网络数据
    [self requestVideo];
}

//1.初始化界面
- (void)setupUI {
    //1.隐藏导航
    self.gk_navigationBar.hidden = YES;
    //    self.gk_navigationBar.backgroundColor = EYColorRed;
    //    [self.view clipsCornerRadius:UIRectCornerAllCorners cornerRadii:5.0];
    
    //2.添加系统声音控件
    [self.view addSubview:[self getSystemVolumSlider]];
    
    //3.底层颜色
    self.view.backgroundColor = EYColorBlack;
    
    //4.滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:EYScreenBounds];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(EYScreenWidth, EYScreenHeight * 3);
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    //4.1 上
    EYHomePlayViewController *toptopVC = [[EYHomePlayViewController alloc] init];
    [self addChildViewController:toptopVC];
    self.toptopVC = toptopVC;
    toptopVC.view.frame = EYScreenBounds;
    [scrollView addSubview:toptopVC.view];
    
    //4.1 中
    EYHomePlayViewController *centerVC = [[EYHomePlayViewController alloc] init];
    [self addChildViewController:centerVC];
    self.centerVC = centerVC;
    centerVC.view.frame = CGRectMake(0, EYScreenHeight, EYScreenWidth, EYScreenHeight);
    [scrollView addSubview:centerVC.view];
    
    //4.1 下
    EYHomePlayViewController *bottomVC = [[EYHomePlayViewController alloc] init];
    [self addChildViewController:bottomVC];
    self.bottomVC = bottomVC;
    bottomVC.view.frame = CGRectMake(0, EYScreenHeight * 2, EYScreenWidth, EYScreenHeight);
    [scrollView addSubview:bottomVC.view];
}

//2.添加通知
- (void)addNotification {
    //1.程序变为活跃状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //2.程序进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.currentPlayViewController.isPlaying) {
        [self.currentPlayViewController pausePlay];
    }
}

#pragma mark - HTTP
//3.请求网络数据
- (void)requestVideo {
    NSMutableArray *array = [EYVideoModel mj_objectArrayWithFilename:@"EYVideoArray.plist"];
    [self.arrarM addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, 11)]];
    
    //首次设置 contentSize
    NSUInteger count = self.arrarM.count;
    if (count > 3) { count = 3; }
    self.scrollView.contentSize = CGSizeMake(EYScreenWidth, EYScreenHeight * count);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //1.设置图片&缓存视频
        self.toptopVC.videoModel = self.arrarM.firstObject;
        self.centerVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
//        self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex + 2];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //2.开始播放第0个
            [self.toptopVC resumePlay];
        });

        //3.设置当前控制器
        self.currentPlayViewController = self.toptopVC;
    });
}

//请求更多数据(修改滚动范围)
- (void)getMoreVideoChangeContentSize {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *array = [EYVideoModel mj_objectArrayWithFilename:@"EYVideoArray.plist"];
        [self.arrarM addObjectsFromArray:[array subarrayWithRange:NSMakeRange(self.arrarM.count, 3)]];
        //再次设置 contentSize
        NSUInteger count = self.arrarM.count;
        EYLog(@"请求更多数据(修改滚动范围)现在数组个数为**%lu**", count);
        if (count > 3) { count = 3; }
        self.scrollView.contentSize = CGSizeMake(EYScreenWidth, EYScreenHeight * count);
    });
}

// 获取更多视频
- (void)requestMoreVideo {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *array = [EYVideoModel mj_objectArrayWithFilename:@"EYVideoArray.plist"];
        [self.arrarM addObjectsFromArray:[array subarrayWithRange:NSMakeRange(self.arrarM.count, 6)]];
    });
}

#pragma mark - Notification
- (void)appDidBecomeActive:(NSNotification *)noti {
    EYLog(@"程序已经变成活跃状态");
    
    if (self.gk_visibleViewControllerIfExist == self) {
        [self.currentPlayViewController resumePlay];
    }
}

- (void)appWillResignActive:(NSNotification *)noti {
    EYLog(@"程序将会失去活跃状态");
    
    if (self.currentPlayViewController.isPlaying) {
        [self.currentPlayViewController pausePlay];
    }
}

#pragma mark - Private Methods

//动画
- (void)changeFrameWithPOP:(UIView *)view offsetY:(CGFloat)y {
    POPBasicAnimation * anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.fromValue = @(view.centerY);
    anim.toValue = @(view.centerY + y);
    anim.duration = 0.5;
    [view pop_addAnimation:anim forKey:nil];
}

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    if (self.arrarM.count <= 3) {//小于等于3个只处理逻辑不处理界面
        if (contentOffsetY == 0) {
            self.currentVideoIndex = 0;
            self.currentPlayViewController = self.toptopVC;
            EYLog(@"小于等于3个第%lu个视频", self.currentVideoIndex);
        } else if(contentOffsetY == EYScreenHeight) {
            self.currentVideoIndex = 1;
            self.currentPlayViewController = self.centerVC;
            EYLog(@"小于等于3个第%lu个视频", self.currentVideoIndex);
            // 获取更多数据
            [self getMoreVideoChangeContentSize];
        } else if(contentOffsetY == EYScreenHeight * 2) {
            self.currentVideoIndex = 2;
            self.currentPlayViewController = self.bottomVC;
            EYLog(@"小于等于3个第%lu个视频", self.currentVideoIndex);
        } else {
//            EYLog(@"小于等于3个其他位置==%f", contentOffsetY);
        }
        
        //不处理界面交换
        return;
    }
    
    //正常看 第一个
    if (self.currentVideoIndex == 0 && contentOffsetY < EYScreenHeight) {
        return;
    }
    
    // 正常看 第二个
    if (self.currentVideoIndex == 0 && contentOffsetY == EYScreenHeight) {
        self.currentVideoIndex++;
        [self topCenterBottom];
        EYLog(@"第二个视频==%lu", self.currentVideoIndex);
        return;
    }
    
    //回看倒数第二个
    if (self.currentVideoIndex == self.arrarM.count - 1 && contentOffsetY == EYScreenHeight) {
        self.currentVideoIndex--;
        
        EYLog(@"看完最后一个 回看倒数第二个**%lu**", self.currentVideoIndex);
        [self goBackToPenultimateVideo];
        return;
    }
    
    //最后一个
    if (self.currentVideoIndex == self.arrarM.count - 1) {
        return;
    }
    
    if (contentOffsetY >= 2 * EYScreenHeight) {//下一个视频
        self.currentVideoIndex++;
        
        if (self.currentVideoIndex == self.arrarM.count - 1) {//最后一个
            EYLog(@"向下看 看到最后一个**%lu**", self.currentVideoIndex);
            [self lastVideo];
        } else {
            if (self.toptopVC.view.mj_y == 0) {// 上(中)下 -> 中(下)上
                [self centerBottomTop];
            } else if (self.toptopVC.view.mj_y == EYScreenHeight) {// 下(上)中 -> 上(中)下
                [self topCenterBottom];
            } else {// 中(下)上 -> 下(上)中
                [self bottomTopCenter];
            }
            EYLog(@"下一个视频**%lu**", self.currentVideoIndex);
        }
    } else if (contentOffsetY <= 0) {//上一个视频
        if (self.currentVideoIndex == 1) {
            self.currentVideoIndex = 0;
            EYLog(@"回翻到第一个视频**%lu**,可以进行下拉刷新的操作了", self.currentVideoIndex);
            [self goBackToFirstVideo];
        } else {
            self.currentVideoIndex--;
            EYLog(@"上一个视频**%lu**", self.currentVideoIndex);
            
            if (self.toptopVC.view.mj_y == 0) {// 上(中)下 -> 下(上)中
                [self bottomTopCenter];
            } else if (self.toptopVC.view.mj_y == EYScreenHeight) {// 下(上)中 -> 中(下)上
                [self centerBottomTop];
            } else {// 中(下)上 -> 上(中)下
                [self topCenterBottom];
            }
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {// 滚动停止了
    
    //1.播放当前界面显示的对应视频
    EYVideoModel *videoModel = self.arrarM[self.currentVideoIndex];
    EYLog(@"需要播放的下标为**%lu**%@", self.currentVideoIndex, videoModel.ey_video_name);
    [self.currentPlayViewController resumePlay];
    
    if ([videoModel.ey_video_name isEqualToString:self.currentPlayViewController.videoModel.ey_video_name]) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"播放的视频正确"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"播放的视频错误"];
    }
}

#pragma mark - Private Methods
// 上 + 中 + 下
- (void)topCenterBottom {
    //1.修改位置
    self.toptopVC.view.mj_y = 0;
    self.centerVC.view.mj_y = EYScreenHeight;
    self.bottomVC.view.mj_y = EYScreenHeight * 2;
    self.scrollView.contentOffset = CGPointMake(0, EYScreenHeight);
    
    //2.(1.先停止播放2.设置图片+缓存)
    [self.toptopVC stopPlay];
    self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
    
    self.centerVC.videoModel = self.arrarM[self.currentVideoIndex];
    
    [self.bottomVC stopPlay];
    self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
    
    //3.设置当前播放器
    self.currentPlayViewController = self.centerVC;
}

// 中 + 下 + 上
- (void)centerBottomTop {
    //1.修改位置
    self.centerVC.view.mj_y = 0;
    self.bottomVC.view.mj_y = EYScreenHeight;
    self.toptopVC.view.mj_y = EYScreenHeight * 2;
    self.scrollView.contentOffset = CGPointMake(0, EYScreenHeight);
    
    //2.(1.先停止播放2.设置图片+缓存)
    [self.centerVC stopPlay];
    self.centerVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
    
    self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex];
    
    [self.toptopVC stopPlay];
    self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
    
    //3.设置当前播放器
    self.currentPlayViewController = self.bottomVC;
}

// 下 + 上 + 中
- (void)bottomTopCenter {
    //1.修改位置
    self.bottomVC.view.mj_y = 0;
    self.toptopVC.view.mj_y = EYScreenHeight;
    self.centerVC.view.mj_y = EYScreenHeight * 2;
    self.scrollView.contentOffset = CGPointMake(0, EYScreenHeight);
    
    //2.(1.先停止播放2.设置图片+缓存)
    [self.bottomVC stopPlay];
    self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
    
    self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex];
    
    [self.centerVC stopPlay];
    self.centerVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
    
    //2.设置当前播放器
    self.currentPlayViewController = self.toptopVC;
}

#pragma mark - 正常看
- (void)lastVideo {
    NSUInteger remainder = self.arrarM.count % 3;
    if (remainder == 1) {//多一个
        [self.centerVC stopPlay];
        self.centerVC.videoModel = self.arrarM[self.currentVideoIndex - 2];
        
        [self.bottomVC stopPlay];
        self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
        
        self.currentPlayViewController = self.toptopVC;
    } else if (remainder == 2) {//多两个
        [self.bottomVC stopPlay];
        self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex - 2];
        
        [self.toptopVC stopPlay];
        self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
        
        self.currentPlayViewController = self.centerVC;
    } else {//正好
        [self.toptopVC stopPlay];
        self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex - 2];
        
        [self.centerVC stopPlay];
        self.centerVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
        
        self.currentPlayViewController = self.bottomVC;
    }
}

#pragma mark - 回看
// 回翻到倒数第二个视频
- (void)goBackToPenultimateVideo {
    NSUInteger remainder = self.arrarM.count % 3;
    if (remainder == 1) {//多一个
        [self.centerVC stopPlay];
        self.centerVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
        
        self.currentPlayViewController = self.bottomVC;
        
        [self.toptopVC stopPlay];
        self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
    } else if (remainder == 2) {//多两个
        [self.bottomVC stopPlay];
        self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
        
        self.currentPlayViewController = self.toptopVC;
        
        [self.centerVC stopPlay];
        self.centerVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
    } else {//正好
        [self.toptopVC stopPlay];
        self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex - 1];
        
        self.currentPlayViewController = self.centerVC;
        
        [self.bottomVC stopPlay];
        self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
    }
}

// 回翻到第一个视频
- (void)goBackToFirstVideo {
    //1.修改位置
    self.toptopVC.view.mj_y = 0;
    self.centerVC.view.mj_y = EYScreenHeight;
    self.bottomVC.view.mj_y = EYScreenHeight * 2;
    
    //2.(1.先停止播放2.设置图片+缓存)
    self.toptopVC.videoModel = self.arrarM[self.currentVideoIndex];
    
    [self.centerVC stopPlay];
    self.centerVC.videoModel = self.arrarM[self.currentVideoIndex + 1];
    
    [self.bottomVC stopPlay];
    self.bottomVC.videoModel = self.arrarM[self.currentVideoIndex + 2];
    
    //3.设置当前播放器
    self.currentPlayViewController = self.toptopVC;
}

#pragma mark - 懒加载
- (NSMutableArray<EYVideoModel *> *)arrarM {
    if (nil == _arrarM) {
        _arrarM = [NSMutableArray array];
    }
    return _arrarM;
}

#pragma mark - 音量控制
/*
 * 获取系统音量滑块
 */
- (UIView *)getSystemVolumSlider{
    UIView * view = nil;
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    for (UIView *newView in volumeView.subviews) {
        if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
            newView.frame = CGRectMake(-300, -300, 1, 1);
            view = newView;
            break;
        }
    }
    return view;
}

@end
