//
//  WCEditProfileViewController.h
//  WeChat
//
//  Created by wjw on 16/6/28.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCEditProfileViewControllerDelegate <NSObject>

- (void)editProfileViewControllerDidSave;

@end
@interface WCEditProfileViewController : UITableViewController
//接受传过来的 cell
@property(nonatomic,strong)UITableViewCell *cell;

@property(nonatomic,weak) id <WCEditProfileViewControllerDelegate> delegate;
@end
