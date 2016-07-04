//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCRegisterViewController.h"
#import "AppDelegate.h"

@interface WCRegisterViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation WCRegisterViewController
@synthesize delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    
    //判断当前设备的类型 改变左右两天的约束
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
}

- (IBAction)registerBtnClick {
    
    //键盘隐藏
    [self.view endEditing:YES];
    
    //判断用户输入的是否为手机号码
    if(![self.userField isTelphoneNum]){
        [MBProgressHUD showError:@"请输入正确的手机号" toView:self.view];
        return;
    }
    //1、 把用户注册的数据保存到单例
    WCUserInfo *userInfo = [WCUserInfo sharedWCUserInfo];
    userInfo.registerUser = self.userField.text;
    userInfo.registerPwd = self.pwdField.text;
    
    //2、调用Appdelegate 的xmppUserRegister
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    app.registerOperation = YES;
    
    //3.重构之后 调用XMPPTool 的xmppUserRegister
    [WCXMPPTool sharedWCXMPPTool].registerOperation = YES;
    
    //提示
    [MBProgressHUD showMessage:@"正在注册..." toView:self.view];
    __weak typeof(self) selfVc = self;
    [[WCXMPPTool sharedWCXMPPTool] xmppUserRegister:^(XMPPResultType type) {
        [selfVc handleResultType:type];
    }];
}

/**
 *  处理注册的结果
 */
- (void)handleResultType:(XMPPResultType)type{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case XMPPResultTypeNetErr:
                [MBProgressHUD showError:@"网络不稳定" toView:self.view];
                break;
            case XMPPResultTypeRegisterSuccess:
                [MBProgressHUD showError:@"注册成功" toView:self.view];
                //回到上一个窗口 上一个界面的label显示注册的用户名
                [self dismissViewControllerAnimated:YES completion:nil];
                //注册成功后，用代理传递用户名
                if ([self.delegate respondsToSelector:@selector(registerViewControllerDidFinishRegister)]) {
                    [self.delegate registerViewControllerDidFinishRegister];
                }
                break;
            case XMPPResultTypeRegisterFailure:
                [MBProgressHUD showError:@"用户名或密码重复,注册失败" toView:self.view];
                break;
            default:
                break;
        }
    });
    
}


- (IBAction)cancle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textChange {
    WCLog(@"文本内容发生变化");
    //设置注册按钮的可用状态
    BOOL enable = (self.userField.text.length != 0 && self.pwdField.text.length != 0);
    self.registerBtn.enabled = enable;
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
