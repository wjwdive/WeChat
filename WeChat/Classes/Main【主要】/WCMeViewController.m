//
//  WCMeViewController.m
//  WeChat
//
//  Created by wjw on 16/6/23.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCMeViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
@interface WCMeViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBtnClick;
//头像
@property (weak, nonatomic) IBOutlet UIImageView *headerView;
//昵称
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
//微信号
@property (weak, nonatomic) IBOutlet UILabel *weixinNumLabel;

@end

@implementation WCMeViewController
- (IBAction)logoutBtnClick:(id)sender {
    //直接调用 appdelegate 的注销方法
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    [app xmppUserLogout];
    //修改后用WCXMPPTool 的方法
    [[WCXMPPTool sharedWCXMPPTool] xmppUserLogout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //如何使用CoreData 获取数据
    //1.上下文 【关联到数据】
    //2.FetchRequest
    //3.设置过滤和排序
    //4.执行请求获取数据
    
    //xmpp 提供了一个方法，直接获取个人信息
    XMPPvCardTemp *myVcard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    //设置头像
    if(myVcard.photo){
        self.headerView.image = [UIImage imageWithData:myVcard.photo];
    }
    //设置昵称
    self.nickNameLabel.text = myVcard.nickname;
    //设置微信号
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
    self.weixinNumLabel.text = [NSString stringWithFormat:@"微信号:%@",user];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 1;
}

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
