//
//  AppDelegate.m
//  WeChat
//
//  Created by wjw on 16/6/20.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "AppDelegate.h"
#import "WCNavigationController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //沙盒路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    WCLog(@"path: %@",path);
    //打开XMPP的日志 注释掉 关闭xmpp日志
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    
    //一次性用共有方法来 设置导航条背景（主题）
    [WCNavigationController setupNavTheme];
    
    //从沙盒里加载用户的数据单例
    [[WCUserInfo sharedWCUserInfo] loadUserInfoFromSandbox];
    
    //判断用户登录状态，YES 直接来到主界面
    if([WCUserInfo sharedWCUserInfo].loginStatus == YES){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storyboard.instantiateInitialViewController;
    }
    
    //自动登录
    [[WCXMPPTool sharedWCXMPPTool] xmppUserLogin:nil];
#warning 一般情况下不会立即连接，等待两秒再自动连接。因为 发送连接状态通知时，还没有控制器可以被初始化 并接受通知
    //等待两秒后再自动登陆
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[WCXMPPTool sharedWCXMPPTool] xmppUserLogin:nil];
    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
