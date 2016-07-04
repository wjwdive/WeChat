//
//  WCHistoryViewController.m
//  WeChat
//
//  Created by wjw on 16/7/4.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCHistoryViewController.h"

@interface WCHistoryViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation WCHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //监听登录状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusChange:) name:WCLoginStatusChangeNotification object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)loginStatusChange:(NSNotification *)noti {
    
    //通知是在子线程里调用的，刷新是在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        WCLog(@"%@",noti);
        //获取登陆状态
        int status = [noti.userInfo[@"loginStatus"] intValue];
        switch (status) {
            case XMPPResultTypeConnecting:
                [self.indicatorView startAnimating];//正在连接
                break;
            case XMPPResultTypeNetErr:
                [self.indicatorView stopAnimating];//网络错误
                break;
            case XMPPResultTypeLoginSuccess:
                [self.indicatorView stopAnimating];//登陆成功
                break;
            case XMPPResultTypeLoninFailure:
                [self.indicatorView stopAnimating];//登陆失败
                break;
                
            default:
                break;
        }
    });
    
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
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
