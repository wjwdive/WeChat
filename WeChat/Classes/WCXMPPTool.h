//
//  WCXMPPTool.h
//  WeChat
//
//  Created by wjw on 16/6/24.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"

extern NSString *const WCLoginStatusChangeNotification;


typedef enum {
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLoninFailure,//登录失败
    XMPPResultTypeNetErr,//网络不给力
    XMPPResultTypeRegisterSuccess,//注册成功
    XMPPResultTypeRegisterFailure,//注册失败
    XMPPResultTypeConnecting//正在连接
}XMPPResultType;
//登录结果的Block
typedef void (^XMPPResultBlock)(XMPPResultType type);

@interface WCXMPPTool : NSObject

singleton_interface(WCXMPPTool);
//暴露出 xmppStream
@property (nonatomic,strong,readonly)XMPPStream *xmppStream;
//暴露出vCard
@property (nonatomic,strong,readonly)XMPPvCardTempModule *vCard;
//暴露出
@property (nonatomic,strong,readonly) XMPPRosterCoreDataStorage *rosterStorage;//花名册数据存储模块
//暴露出 花名册
@property (nonatomic,strong,readonly) XMPPRoster *roster;
//暴露出 聊天的数据数据存储
@property(nonatomic,strong,readonly) XMPPMessageArchivingCoreDataStorage *msgStorage;

//@property (strong, nonatomic) UIWindow *window;
//注册操作标识 YES 注册、NO 登录
@property (nonatomic,assign,getter=isRegisterOperation) BOOL registerOperation;
/**
 *  用户登录
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
