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
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation WCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //设置TextField 和 Btn 的样式
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    /*
       UIImageView *lockView = [[UIImageView alloc] init];
    lockView.bounds = CGRectMake(0, 0, 30, 30);
    lockView.image = [UIImage imageNamed:@"Card_Lock"];
//    self.pwdField.leftViewMode = UITextFieldViewModeAlways;//没有这个显示模式就不会显示图片
    
    self.pwdField.leftView = lockView;
    */
    //TextField 的分类 一句代码搞定 textFiled 左图标
    [self.pwdField addLeftViewWithImage:@"Card_Lock"];
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
    //设置用户名为上次登录的用户名
    //从沙盒获取用户名
//    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    //从 单例获取用户数据
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
//    NSString *pwd = [WCUserInfo sharedWCUserInfo].pwd;
    self.userLabel.text = user;
}
- (IBAction)loginBtnClick:(id)sender {
    //保存数据到单例
    WCUserInfo *userInfo = [WCUserInfo sharedWCUserInfo];
    userInfo.user = self.userLabel.text;
    userInfo.pwd = self.pwdField.text;
    //调用父类的登录
    [super login];
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
