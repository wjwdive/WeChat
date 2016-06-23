//
//  WCLoginViewController.m
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCLoginViewController.h"

@interface WCLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@end

@implementation WCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置用户名为上次登录的用户名
    //从沙盒获取用户名
//    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    //从 单例获取用户数据
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
//    NSString *pwd = [WCUserInfo sharedWCUserInfo].pwd;
    self.userLabel.text = user;
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
