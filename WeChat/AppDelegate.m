//
//  AppDelegate.m
//  WeChat
//
//  Created by wjw on 16/6/20.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "WCNavigationController.h"
@interface AppDelegate ()<XMPPStreamDelegate>{
    XMPPStream *_xmppStream;
    XMPPResultBlock _resultBlock;
}

/*
 1.初始化XMPPStream
 2.连接到服务器【传一个JID】
 3.连接服务器成功后 在发送授权密码
 4.授权成功后，发送“在线小新”
 */

//1.初始化XMPPStream
- (void)setupXMPPStream;

//2.连接到服务器
- (void)connectToHost;

//3.连接到服务成功后，再发送密码授权
- (void)sendPwdToHost;

//4.授权成功后，发送“在线”消息
- (void)sendOnlineToHost;

@end

@implementation AppDelegate




#pragma mark -私有方法
#pragma mark 初始化 xmppStream
- (void)setupXMPPStream {
    _xmppStream = [[XMPPStream alloc] init];
    
    //设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    
}

#pragma mark 连接到服务器
- (void)connectToHost {
    WCLog(@"开始连接到服务器");
    if(!_xmppStream) {
        [self setupXMPPStream];
    }
    
    /*
     设置录用用户JID 从沙盒获取用户名
     */
//    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    //重构 从单例 获取用户名
    NSString *user = nil;
    if (self.registerOperation) {
        user = [WCUserInfo sharedWCUserInfo].registerUser;
    }else{
        user = [WCUserInfo sharedWCUserInfo].user;
    }
    
//    NSString *userComplate = [NSString stringWithFormat:user,@"@wjw.local"];
    
    //设置JID
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"wjw.local" resource:@"iphone"];
    WCLog(@"myJID:%@",myJID);
    _xmppStream.myJID = myJID;
    
    //设置服务器域名
    _xmppStream.hostName = @"wjw.local";//不仅可以用域名 还可以用IP地址
    //设置端口 服务器默认端口 5222
    _xmppStream.hostPort = 5222;
    
//    if ([_xmppStream isConnected]) {
//        [_xmppStream disconnect];
//    }
    
    //连接
    NSError *err = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        WCLog(@"connect error:%@",err);
    }
    
}

- (void)sendPwdToHost {
    WCLog(@"再发送密码授权");
    NSError *err = nil;
    //从沙盒里获取pwd
//    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"pwd"];
    //从单例里获取密码
    NSString *pwd = [WCUserInfo sharedWCUserInfo].pwd;
    
    [_xmppStream authenticateWithPassword:pwd error:&err];
    if (err) {
        WCLog(@"%s:%@",__func__,err);
    }
}

#pragma mark 授权成功后，发送“在线”消息
- (void)sendOnlineToHost {
    WCLog(@"发送 在线 消息");
    XMPPPresence *presence = [XMPPPresence presence];
    WCLog(@"%@",presence);
    [_xmppStream sendElement:presence];
}
#pragma mark -XMPPStream的代理
#pragma mark 与主机连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    WCLog(@"与主机连接成功");
    
    if (self.registerOperation) {//注册的操作 发送注册的密码
        NSString *pwd = [WCUserInfo sharedWCUserInfo].registerPwd;
        [_xmppStream registerWithPassword:pwd error:nil];
    }else{//登录操作
        //主机连接成功后，发送密码进行授权
        [self sendPwdToHost];
    }
    
}

#pragma mark 与主机断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    //如果有错误，代表连接失败
    WCLog(@"与主机连接失败 %@",error);
    //如果没有错误，标示正常的（人为）断开连接
    if(error && _resultBlock){
        _resultBlock(XMPPResultTypeNetErr);
    }
}

#pragma mark 授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    WCLog(@"授权成功");
    [self sendOnlineToHost];
    
    //回调控制 登陆成功
    if(_resultBlock){
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
}

#pragma mark 授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    WCLog(@"授权失败 %@",error);
    //判断 result 有无值，再回调给登录控制器
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLonginFailure);
    }
}
#pragma mark - 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    WCLog(@"注册成功");
    if(_resultBlock){
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}

#pragma mark - 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    WCLog(@"注册失败:%@",error);
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
}

#pragma mark - 公共方法
- (void)xmppUserLogout{
    //1.“发送” 离线消息
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    //2.与服务器断开连接
    [_xmppStream disconnect];
    
    //3.回到登录界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login_Storyboard" bundle:nil];
    self.window.rootViewController = storyboard.instantiateInitialViewController;
    
    //4、更新用户的登录状态
    [WCUserInfo sharedWCUserInfo].loginStatus = NO;
    [[WCUserInfo sharedWCUserInfo] saveUserInfoToSandbox];
}
/**
 *  用户登录
 *
 *  @param resultBlock
 */
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock{
    //先把 block存起来
    _resultBlock = resultBlock;
    
    //如果以前连接过服务器，要断开(这里登录之前都断开一次)
    [_xmppStream disconnect];
    
    //连接主机 成功后发送密码
    [self connectToHost];
}

/**
 *  用户注册
 */
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock{
    //先把 block存起来
    _resultBlock = resultBlock;
    
    //如果以前连接过服务器，要断开(这里登录之前都断开一次)
    [_xmppStream disconnect];
    
    //连接主机 成功后发送注册的密码
    [self connectToHost];
    
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //一次性用共有方法来 设置导航条背景（主题）
    [WCNavigationController setupNavTheme];
    
    //从沙盒里加载用户的数据单例
    [[WCUserInfo sharedWCUserInfo] loadUserInfoFromSandbox];
    
    //判断用户登录状态，YES 直接来到主界面
    if([WCUserInfo sharedWCUserInfo].loginStatus == YES){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storyboard.instantiateInitialViewController;
    }
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
