//
//  AppDelegate.h
//  WeChat
//
//  Created by wjw on 16/6/20.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLonginFailure,//登录失败
    XMPPResultTypeNetErr//网络不给力
}XMPPResultType;
//登录结果的Block
typedef void (^XMPPResultBlock)(XMPPResultType type);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  用户登录
 *
 *  @param resultBlock <#resultBlock description#>
 */
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock;

/**
 *  用户注销
 */
- (void)xmppUserLogout;

/**
 *  用户注册
 */
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock;
@end

