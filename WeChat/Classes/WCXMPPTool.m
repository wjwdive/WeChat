//
//  WCXMPPTool.m
//  WeChat
//
//  Created by wjw on 16/6/24.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCXMPPTool.h"

NSString *const WCLoginStatusChangeNotification = @"WCLoginStatusNotification";

@interface WCXMPPTool()<XMPPStreamDelegate>{
    XMPPStream *_xmppStream;
    XMPPResultBlock _resultBlock;
    
    //*********************自动重练模块
    XMPPReconnect *_reconnect;
    
    //*********************
    
    
    //********************* 电子名片模块
    //电子名片
    XMPPvCardTempModule *_vCard;
    //电子名片的数据存储
    XMPPvCardCoreDataStorage *_vCardStorage;
    //电子名片头像
    XMPPvCardAvatarModule *_avatar;
    //*********************
    
    
    //*********************
    XMPPRoster *_roster;//花名册模块
    XMPPRosterCoreDataStorage *_rosterStorage;//花名册数据存储模块
    //*********************
    
    //********************* 消息模块
    XMPPMessageArchiving *_msgArching;
    XMPPMessageArchivingCoreDataStorage *_msgStorage;
    //*********************
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

@implementation WCXMPPTool

singleton_implementation(WCXMPPTool)


#pragma mark -私有方法
#pragma mark 初始化 xmppStream
- (void)setupXMPPStream {
    _xmppStream = [[XMPPStream alloc] init];
    
    //********************* 电子名片模块
    //添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    //激活
    [_vCard activate:_xmppStream];
    //*********************
    
    //********************* 头像模块
    //头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];
    
    //*********************
    
    //********************* 自动重练模块 添加 激活
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
    //*********************
    
    //********************* 花名册模块 数据存储模块  激活
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster setAutoFetchRoster:YES];
    [_roster setAutoAcceptKnownPresenceSubscriptionRequests:YES];
    [_roster activate:_xmppStream];
    //*********************
    
    //********************* 聊天模块 并激活
    _msgStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _msgArching = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgStorage];
    [_msgArching activate:_xmppStream];
    //*********************
    //设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    
}


#pragma mark 释放xmppStrean相关资源
-(void)teardownXmpp{
    //移除代理
    [_xmppStream removeDelegate:self];
    //停止模块
    [_reconnect deactivate];
    [_vCard deactivate];
    [_avatar deactivate];
    [_roster deactivate];
    [_msgArching deactivate];
    
    //断开连接
    _reconnect = nil;
    //清空资源
    _vCard = nil;
    _vCardStorage = nil;
    _avatar = nil;
    _xmppStream = nil;
    _rosterStorage = nil;
    _roster = nil;
    _msgArching = nil;
    _msgStorage = nil;
}


#pragma mark 连接到服务器
- (void)connectToHost {
    WCLog(@"开始连接到服务器");
    if(!_xmppStream) {
        [self setupXMPPStream];
    }
    
    //发送通知 通知HistoryViewController【正在连接】
    [self postNotification:XMPPResultTypeConnecting];
    
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

- (void)postNotification:(XMPPResultType)resultType {
    //将登陆状态放入字典，然后通过通知传递
    NSDictionary *userInfo = @{@"loginStatus":@(resultType)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCLoginStatusChangeNotification object:nil userInfo:userInfo];
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
    
    if (error){
        //通知 historyViewController【网络不稳定】
        [self postNotification:XMPPResultTypeNetErr];
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
    //通知【授权成功】
    [self postNotification:XMPPResultTypeLoginSuccess];
}

#pragma mark 授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    WCLog(@"授权失败 %@",error);
    //判断 result 有无值，再回调给登录控制器
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoninFailure);
    }
    
    //通知【授权成功】
    [self postNotification:XMPPResultTypeLoninFailure];
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

#pragma mark - 公共方法 注销
- (void)xmppUserLogout{
    //1.“发送” 离线消息
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    //2.与服务器断开连接
    [_xmppStream disconnect];
    
    //3.回到登录界面
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login_Storyboard" bundle:nil];
//    self.window.rootViewController = storyboard.instantiateInitialViewController;
    [UIStoryboard showInitialVCWithName:@"Login_Storyboard"];
    //4、更新用户的登录状态
    [WCUserInfo sharedWCUserInfo].loginStatus = NO;
    [[WCUserInfo sharedWCUserInfo] saveUserInfoToSandbox];
}
/**
 *  用户登录
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



- (void)dealloc {
    [self teardownXmpp];
}

@end
