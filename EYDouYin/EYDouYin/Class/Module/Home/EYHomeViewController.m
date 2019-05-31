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
#import "EYVideoModel.h"

@interface EYHomeViewController () <UIScrollViewDelegate>

// 滚动视图
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) EYHomePlayViewController *toptopVC;//上
@property (weak, nonatomic) EYHomePlayViewController *centerVC;//中
@property (weak, nonatomic) EYHomePlayViewController *bottomVC;//下

@property (strong, nonatomic) NSMutableArray <EYVideoModel *>*arrarM;

// 当前屏幕所处的下标
@property (assign, nonatomic) int currentVideoIndex;
// 当前屏幕所属的控制器
@property (weak, nonatomic) EYHomePlayViewController *currentPlayViewController;

@end

@implementation EYHomeViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //0.当前播放下标
    self.currentVideoIndex = 0;
    
    //1.初始化界面
    [self setupUI];
    
    //2.模拟网络数据
    [self loadNetData];
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
    toptopVC.view.backgroundColor = EYColorRed;
    [scrollView addSubview:toptopVC.view];
    
    //4.1 中
    EYHomePlayViewController *centerVC = [[EYHomePlayViewController alloc] init];
    [self addChildViewController:centerVC];
    self.centerVC = centerVC;
    centerVC.view.frame = CGRectMake(0, EYScreenHeight, EYScreenWidth, EYScreenHeight);
    centerVC.view.backgroundColor = EYColorGreen;
    [scrollView addSubview:centerVC.view];
    
    //4.1 下
    EYHomePlayViewController *bottomVC = [[EYHomePlayViewController alloc] init];
    [self addChildViewController:bottomVC];
    self.bottomVC = bottomVC;
    bottomVC.view.frame = CGRectMake(0, EYScreenHeight * 2, EYScreenWidth, EYScreenHeight);
    bottomVC.view.backgroundColor = EYColorBlue;
    [scrollView addSubview:bottomVC.view];
}

//2.请求网络数据
- (void)loadNetData {
    
    NSMutableArray *array = [EYVideoModel mj_objectArrayWithFilename:@"EYVideoArray.plist"];
    
    if (array.count < 3) {
        return;
    }
    
    [self.arrarM addObjectsFromArray:array];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //开始播放第0个
        self.currentPlayViewController = self.toptopVC;
        [self.currentPlayViewController startPlayWithURLString:self.arrarM.firstObject.tt_video_name];
    });
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
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    EYLog(@"scrollView滚动到顶部了");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.arrarM.count <= 3) {//小于等于3个不做处理
        return;
    }
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    // 第二个
    if (self.currentVideoIndex == 0 && contentOffsetY == EYScreenHeight) {
        self.currentVideoIndex++;
        EYLog(@"第二个视频=%lu", self.currentVideoIndex);
        self.currentPlayViewController = self.centerVC;
        return;
    }
    
    // 倒数第二个
    if (self.currentVideoIndex == self.arrarM.count - 1 && contentOffsetY == EYScreenHeight) {
        self.currentVideoIndex--;
        EYLog(@"看完最后一个 回看倒数第二个**%lu**", self.currentVideoIndex);
        NSUInteger remainder = self.arrarM.count % 3;
        if (remainder == 1) {//多一个
            self.currentPlayViewController = self.bottomVC;
        } else if (remainder == 2) {//多两个
            self.currentPlayViewController = self.toptopVC;
        } else {//正好
            self.currentPlayViewController = self.centerVC;
        }
        return;
    }
    
    if (contentOffsetY >= 2 * EYScreenHeight) {//下一个视频
        self.currentVideoIndex++;
        if (self.currentVideoIndex == self.arrarM.count - 1) {//最后一个
            EYLog(@"向下看 看到最后一个**%lu**", self.currentVideoIndex);
            NSUInteger remainder = self.arrarM.count % 3;
            if (remainder == 1) {//多一个
                self.currentPlayViewController = self.toptopVC;
            } else if (remainder == 2) {//多两个
                self.currentPlayViewController = self.centerVC;
            } else {//正好
                self.currentPlayViewController = self.bottomVC;
            }
            return;
        }
        
        //1.修改位置
        if (self.toptopVC.view.mj_y == 0) {// 上(中)下 -> 中(下)上
            self.centerVC.view.mj_y = 0;
            self.bottomVC.view.mj_y = EYScreenHeight;
            self.toptopVC.view.mj_y = EYScreenHeight * 2;
            self.currentPlayViewController = self.bottomVC;
        } else if (self.toptopVC.view.mj_y == EYScreenHeight) {// 下(上)中 -> 上(中)下
            self.toptopVC.view.mj_y = 0;
            self.centerVC.view.mj_y = EYScreenHeight;
            self.bottomVC.view.mj_y = EYScreenHeight * 2;
            self.currentPlayViewController = self.centerVC;
        } else {// 中(下)上 -> 下(上)中
            self.bottomVC.view.mj_y = 0;
            self.toptopVC.view.mj_y = EYScreenHeight;
            self.centerVC.view.mj_y = EYScreenHeight * 2;
            self.currentPlayViewController = self.toptopVC;
        }
        //2.滚动位置
        scrollView.contentOffset = CGPointMake(0, EYScreenHeight);
        
        EYLog(@"下一个视频**%lu**", self.currentVideoIndex);
    } else if (contentOffsetY <= 0) {//上一个视频
        if (self.currentVideoIndex == 1) {
            self.currentVideoIndex = 0;
            self.currentPlayViewController = self.toptopVC;
            EYLog(@"上滑到第一个视频**%lu**,可以进行下拉刷新的操作了", self.currentVideoIndex);
            return;
        }
        
        self.currentVideoIndex--;
        
        //1.修改位置
        if (self.toptopVC.view.mj_y == 0) {// 上(中)下 -> 下(上)中
            //EYLog(@"777777777777");
            self.bottomVC.view.mj_y = 0;
            self.toptopVC.view.mj_y = EYScreenHeight;
            self.centerVC.view.mj_y = EYScreenHeight * 2;
            self.currentPlayViewController = self.toptopVC;
        } else if (self.toptopVC.view.mj_y == EYScreenHeight) {// 下(上)中 -> 中(下)上
            //EYLog(@"8888888888888");
            self.centerVC.view.mj_y = 0;
            self.bottomVC.view.mj_y = EYScreenHeight;
            self.toptopVC.view.mj_y = EYScreenHeight * 2;
            self.currentPlayViewController = self.bottomVC;
        } else {// 中(下)上 -> 上(中)下
            //EYLog(@"9999999999999");
            self.toptopVC.view.mj_y = 0;
            self.centerVC.view.mj_y = EYScreenHeight;
            self.bottomVC.view.mj_y = EYScreenHeight * 2;
            self.currentPlayViewController = self.centerVC;
        }
        
        //2.滚动位置
        scrollView.contentOffset = CGPointMake(0, EYScreenHeight);
        EYLog(@"上一个视频**%lu**", self.currentVideoIndex);
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView  {// 开始拖拽
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {// 结束拖拽
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {//结束拖拽后立即开始减速
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {// 滚动停止了
    EYVideoModel *videoModel = self.arrarM[self.currentVideoIndex];
    
    EYLog(@"需要播放的下标为**%lu**%@", (unsigned long)self.currentVideoIndex, videoModel);
    
    //1.清除之前的播放
    if (self.toptopVC == self.currentPlayViewController) {
        [self.centerVC stopPlay];
        [self.bottomVC stopPlay];
    } else if (self.centerVC == self.currentPlayViewController) {
        [self.toptopVC stopPlay];
        [self.bottomVC stopPlay];
    } else if (self.bottomVC == self.currentPlayViewController) {
        [self.toptopVC stopPlay];
        [self.centerVC stopPlay];
    } else {
        [self.toptopVC stopPlay];
        [self.centerVC stopPlay];
        [self.bottomVC stopPlay];
    }
    
    if (self.currentPlayViewController.videoPlayer.isPlaying) {//正在播放当前的视频(小幅度滑动)
        return;
    }
    
    //2.播放当前界面显示的对应视频
    [self.currentPlayViewController startPlayWithURLString:videoModel.tt_video_name];
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
