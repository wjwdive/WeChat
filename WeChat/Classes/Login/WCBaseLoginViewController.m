//
//  WCBaseLoginViewController.m
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCBaseLoginViewController.h"
#import "AppDelegate.h"

@implementation WCBaseLoginViewController

- (void)login{
    /*
     1.把用户名和密码放在沙盒
     2.调用 AppDelegate 的一个connect 连接服务器并登陆
     */
    //    NSString *user = self.userField.text;
    //    NSString *pwd = self.pwdField.text;
    
    //隐藏键盘
    [self.view endEditing:YES];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:user forKey:@"user"];
//    [defaults setObject:pwd forKey:@"pwd"];
//    [defaults synchronize];
    
    //登录之前给个提示 必须有后面的参数 否则 loading  不在屏幕中间
    [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
    
    //block 里面有 self 的时候  就要用弱引用 否则 会出现循环引用
    __weak typeof(self) selfVc = self;
    
    //app 是 AppDelegate 的类
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app xmppUserLogin:^(XMPPResultType type){
        //调用处理登录结果的方法
        [selfVc handleResultType:type];
    }];
    
    
}

- (void)handleResultType:(XMPPResultType)type {
    //主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case XMPPResultTypeLoginSuccess:
                NSLog(@"登录成功");
                //登陆成功来到主界面
                //此方法是在子线程中被调用的，所以要在主线程中刷新UI
                [self enterMainPage];
                break;
            case XMPPResultTypeLonginFailure:
                NSLog(@"登录失败");
                [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
                break;
            case XMPPResultTypeNetErr:
                NSLog(@"网络不给力");
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
                break;
            default:
                break;
        }
    });
}

//登陆成功来到主界面
//此方法是在子线程中被调用的，所以要在主线程中刷新UI
- (void)enterMainPage {
    //更改用户的登录状态为 YES
    [WCUserInfo sharedWCUserInfo].loginStatus = YES;
    
    //把用户登录成功的数据保存到沙盒
    [[WCUserInfo sharedWCUserInfo] saveUserInfoToSandbox];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //                  self.window.rootViewController = storyboard.instantiateInitialViewController;
        self.view.window.rootViewController = storyboard.instantiateInitialViewController;
        
        //隐藏模态窗口 (如果显示了 模态窗口，一定要dismiss 否则 dealloc不执行 该控制器不会销毁 会造成内存泄露)
        [self dismissViewControllerAnimated:NO completion:nil];
        
    });
    
}



@end
