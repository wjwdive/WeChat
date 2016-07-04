//
//  WCLoginViewController.m
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCLoginViewController.h"
#import "WCRegisterViewController.h"
#import "WCNavigationController.h"

@interface WCLoginViewController ()<WCRegisterViewControllerDelegate>
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

//连线 点击“其他方式登录” present Modely 推出 “其他方式登录界面”。跳转之前，通过segue 判断跳转的目标控制器是否是 nav 控制器，再判断是否是注册控制器，如果是，则设置代理。如果不是，那就是点击的其他按钮，如登录，注册。。。   好好理解。。。。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //获取注册控制器
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[WCNavigationController class]]) {
        
        WCNavigationController *nav = destVc;
        //判断 栈顶控制器 是否是注册控制器
        if ([nav.topViewController isKindOfClass:[WCRegisterViewController class]]) {
            WCRegisterViewController *registerVc = (WCRegisterViewController *)nav.topViewController;
            //设置注册控制器的代理
            registerVc.delegate = self;
        }
    }
    //设置注册控制器的代理
}

#pragma mark -- 代理方法
- (void)registerViewControllerDidFinishRegister {
    WCLog(@"完成注册");
    //完成注册 userLabel 显示注册的用户名
    self.userLabel.text = [WCUserInfo sharedWCUserInfo].registerUser;
    //提示
    [MBProgressHUD showSuccess:@"请重新输入密码进行登录" toView:self.view];
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
