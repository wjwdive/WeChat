//
//  WCRegisterViewController.h
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCRegisterViewControllerDelegate <NSObject>

/**
 *  完成注册
 */
- (void)registerViewControllerDidFinishRegister;

@end
@interface WCRegisterViewController : UIViewController

@property (nonatomic,weak) id <WCRegisterViewControllerDelegate> delegate;

@end
