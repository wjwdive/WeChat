//
//  WCNavigationController.m
//  WeChat
//
//  Created by wjw on 16/6/22.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCNavigationController.h"

@interface WCNavigationController ()


@end

@implementation WCNavigationController


+ (void)initialize {
   //设置导航样式
    
}

//设置导航主题  
+ (void)setupNavTheme {
    UINavigationBar *navBar = [UINavigationBar appearance];
    //1.设置导航条的背景 （高度不会拉伸 但是宽度会拉伸）
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    //2.设置栏的字体
    NSMutableDictionary *att = [NSMutableDictionary dictionary];
    att[NSForegroundColorAttributeName] = [UIColor whiteColor];
    att[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    [navBar setTitleTextAttributes:att];
    
    //3.设置状态栏的样式
    //默认的话，状态栏的样式由控制决定
    //Plist 里添加一个状态 view .... 值为NO 下面这条语句就好了
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

//设置状态栏的样式 （如果控制器是由导航控制器管理，设置状态栏的样式时，要在导航控制器里设置）
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
