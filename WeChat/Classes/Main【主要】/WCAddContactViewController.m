//
//  WCAddContactViewController.m
//  WeChat
//
//  Created by wjw on 16/6/29.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCAddContactViewController.h"

@interface WCAddContactViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation WCAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//输入完数据 代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //添加好友
    
    //1、获取好友账号
    NSString *user = textField.text;
    WCLog(@"user:%@",user);
    //判断这个账号是否为手机号码
    if(![textField isTelphoneNum]){
        //提示
        [self showAlert:@"请输入正确的手机号"];
        return YES;
    }
    
    //判断能否添加自己
    if([user isEqualToString:[WCUserInfo sharedWCUserInfo].user]){
        [self showAlert:@"不能添加自己为好友"];
        return YES;
    }
    
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",user,domain];
    XMPPJID *friendJid = [XMPPJID jidWithString:jidStr];
    //判断好友是否已经存在
    if([[WCXMPPTool sharedWCXMPPTool].rosterStorage userExistsWithJID:friendJid xmppStream:[WCXMPPTool sharedWCXMPPTool].xmppStream]){
        [self showAlert:@"当前好友已经存在"];
        return YES;
    }
    //2、发送添加好友的请求
    
    [[WCXMPPTool sharedWCXMPPTool].roster subscribePresenceToUser:friendJid];
    return YES;
}

- (void)showAlert:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 1;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 1;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
