//
//  WCUserInfo.h
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface WCUserInfo : NSObject

singleton_interface(WCUserInfo);
@property(nonatomic,copy)NSString *user;//用户名
@property(nonatomic,copy)NSString *pwd;//密码

/**
 *  登录的状态 来确定 登录的时候 确定 界面是来到登录界面 还是主界面
 *  YES 登陆过/NO
 */
@property(nonatomic,assign) BOOL loginStatus;

/**
 *  用户注册的用户名 密码
 */
@property(nonatomic,copy)NSString *registerUser;
@property(nonatomic,copy)NSString *registerPwd;

/**
 *  保存用户数据到沙盒
 */
- (void)saveUserInfoToSandbox;

/**
 *  从沙盒里获取用户数据
 */
- (void)loadUserInfoFromSandbox;
@end
