//
//  EYMeViewController.m
//  EYDouYin
//
//  Created by 李二洋 on 2018/7/23.
//  Copyright © 2018年 李二洋. All rights reserved.
//

#import "EYMeViewController.h"
#import "EYExcelTool.h"
#import "EYDouYin-Swift.h"
#import "EYFlutterViewController.h"

@interface EYMeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *array;

@end

@implementation EYMeViewController

static NSString *EYMeViewControllerCellID = @"EYMeViewControllerCellID";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.array = [EYManager manager].meArray;
    
    //1. 初始化界面
    [self setupUI];
    
    [self.tableView reloadData];
    
    // [EYExcelTool startParseExcel];
 }

//1. 初始化界面
- (void)setupUI {
    //1.隐藏分割线
    self.gk_navLineHidden = YES;
    self.gk_navTitle = @"我的";
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.array[section] valueForKeyPath:@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EYMeViewControllerCellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EYMeViewControllerCellID];
        cell.backgroundColor = EYColorClear;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = EYColorWhite;
    }

    NSArray *items = [self.array[indexPath.section] valueForKeyPath:@"items"];
    NSDictionary *item = items[indexPath.row];
    cell.textLabel.text = item[@"name"];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *group = self.array[section];
    return group[@"groupName"];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.array valueForKeyPath:@"groupName"];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self pushFlutterViewController];
    return;
    NSArray *items = [self.array[indexPath.section] valueForKeyPath:@"items"];
    NSDictionary *item = items[indexPath.row];
    NSString *vcName = item[@"vcName"];
    GKNavigationBarViewController *vc = [[NSClassFromString(vcName) alloc] init];
    if ([vc isKindOfClass:GKNavigationBarViewController.class]) {
       vc.gk_navTitle = item[@"name"];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushFlutterViewController {
    FlutterViewController *flutterViewController = [[FlutterViewController alloc] initWithNibName:nil bundle:nil];
    [flutterViewController setFlutterViewDidRenderCallback:^{
        EYLog(@"setFlutterViewDidRenderCallback");
    }];
    
    __weak typeof(self) weakSelf = self;

    // 要与main.dart中一致
    NSString *channelName = @"com.pages.your/native_get";
    FlutterMethodChannel *methodChannel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:flutterViewController];
    [methodChannel setMethodCallHandler:^(FlutterMethodCall* _Nonnull call, FlutterResult  _Nonnull result) {
        // call.method 获取 flutter 给回到的方法名，要匹配到 channelName 对应的多个 发送方法名，一般需要判断区分
        // call.arguments 获取到 flutter 给到的参数，（比如跳转到另一个页面所需要参数）
        // result 是给flutter的回调， 该回调只能使用一次
        NSLog(@"flutter 给到我：\nmethod=%@ \narguments = %@", call.method, call.arguments);
        if([call.method isEqualToString:@"toNativeSomething"]) {
            //添加提示框
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"成功" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction * actionDetermine = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // 回调给flutter
                if(result) {
                    result(@10);
                }
            }];

            [alert addAction:actionDetermine];

            [self presentViewController:alert animated:YES completion:nil];
        } else if([call.method isEqualToString:@"toNativePush"]) {

        } else if([call.method isEqualToString:@"toNativePop"]) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {

        }
    }];
    [self.navigationController pushViewController:flutterViewController animated:YES];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, EYStatusBarAndNaviBarHeight, EYScreenWidth, EYScreenHeight - EYStatusBarAndNaviBarHeight - EYTabBarHeight - EYHomeIndicatorHeight) style:UITableViewStyleGrouped];
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = EYColorClear;
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

@end
