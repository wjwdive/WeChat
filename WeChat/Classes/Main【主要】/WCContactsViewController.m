//
//  WCContactsViewController.m
//  WeChat
//
//  Created by wjw on 16/6/29.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCContactsViewController.h"
#import "WCChatViewController.h"

@interface WCContactsViewController ()<NSFetchedResultsControllerDelegate>{
    //该类的代理 用来监听 数据库的改变
    NSFetchedResultsController *_resultsCotroller;
}
@property(nonatomic,strong)NSArray *friends;
@end

@implementation WCContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //从数据库里加载好友列表显示
    [self loadFriends2];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)loadFriends2 {
    //使用coreData 获取数据
    //1.上下文 【关联到数据库 XMPPRoster.sqlite】
//    [WCXMPPTool sharedWCXMPPTool]
    NSManagedObjectContext *context = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.FetchRequest[查哪张表]
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //3.设置过滤和排序
    //过滤当前登录用户的好友 去查数据库啊
    NSString *jid = [WCUserInfo sharedWCUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jid];
    
    request.predicate = pre;
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    //4.执行请求获取数据
    _resultsCotroller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultsCotroller.delegate = self;
    
    NSError *err = nil;
    [_resultsCotroller performFetch:&err];
    if (err) {
        WCLog(@"error:%@",err);
    }
    //看到有 sqlite 的错误  把应用程序删除 重新运行
}

#pragma mark 当数据库发送改变，会调用这个方法
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    WCLog(@"数据发生改变");
    //刷新表格
    [self.tableView reloadData];
}

- (void)loadFriends {
    //使用coreData 获取数据
    //1.上下文 【关联到数据库 XMPPRoster.sqlite】
    //    [WCXMPPTool sharedWCXMPPTool]
    NSManagedObjectContext *context = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.FetchRequest[查哪张表]
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //3.设置过滤和排序
    //过滤当前登录用户的好友 去查数据库啊
    NSString *jid = [WCUserInfo sharedWCUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jid];
    
    request.predicate = pre;
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    //4.执行请求获取数据
    self.friends = [context executeFetchRequest:request error:nil];
    WCLog(@"%@'s friends:%@",jid,self.friends);
    
    //看到有 sqlite 的错误  把应用程序删除 重新运行
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
//    return self.friends.count;
    return _resultsCotroller.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    //获取对应的好友
//    XMPPUserCoreDataStorageObject *friend = self.friends[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = _resultsCotroller.fetchedObjects[indexPath.row];
    //sectionNum
    //“0” -- 在线
    //"1" -- 离开
    //"2" -- 离线
    NSLog(@"status:%@",friend.sectionName);
    switch ([friend.sectionNum intValue]) {//不是friend.sectionNum...
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
            
        default:
            cell.detailTextLabel.text = @"未知";
            break;
    }
    
    cell.textLabel.text = friend.jidStr;
    return cell;
}

//左滑删除 代理方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WCLog(@"删除好友");
        //通过 数据库视图对象 找到 当前行对应显示的好友信息
        XMPPUserCoreDataStorageObject *friend = _resultsCotroller.fetchedObjects[indexPath.row];
        XMPPJID *friendJid = friend.jid;
        //用工具类中的roster
        [[WCXMPPTool sharedWCXMPPTool].roster removeUser:friendJid];
    }
}


//选中cell跳转到 聊天界面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取好友
    XMPPUserCoreDataStorageObject *friend = _resultsCotroller.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"ChatSegue" sender:friend.jid];
    WCLog(@"go to chat view : ChatSegue");
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[WCChatViewController class]]) {
        WCChatViewController *chatVc = destVc;
        chatVc.friendJid = sender;
    }
}
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
