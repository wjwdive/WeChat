//
//  WCUserInfo.m
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCUserInfo.h"

#define UserKey @"user"
#define PwdKey @"pwd"
#define LoginStatusKey @"LoginStatus"

@implementation WCUserInfo

singleton_implementation(WCUserInfo)

//保存用户数据到沙盒
- (void)saveUserInfoToSandbox{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user forKey:UserKey];
    [defaults setObject:self.pwd forKey:PwdKey];
    [defaults setBool:self.loginStatus forKey:LoginStatusKey];
    [defaults synchronize];//不要忘记做同步
}


/**
 *  从沙盒里获取用户数据
 */
- (void)loadUserInfoFromSandbox{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.user = [defaults objectForKey:UserKey];
    self.pwd = [defaults objectForKey:PwdKey];
    self.loginStatus = [defaults objectForKey:LoginStatusKey];
}

-(NSString *)jid {
    return [NSString stringWithFormat:@"%@@%@",self.user,domain];
}
@end
