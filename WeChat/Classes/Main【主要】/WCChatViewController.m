//
//  WCChatViewController.m
//  WeChat
//
//  Created by wjw on 16/6/30.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCChatViewController.h"
#import "WCInputView.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"
//UITextViewDelegate 以前是textFieldDelegate
@interface WCChatViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UITextViewDelegate,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSFetchedResultsController *_resultController;
}
//inputView 的height约束
@property(nonatomic,strong) NSLayoutConstraint *inputViewHeightConstraint;
//inputView 的底部约束
@property(nonatomic,strong) NSLayoutConstraint *inputViewBottomConstraint;
@property(nonatomic,weak) UITableView *tableView;

@property(nonatomic,strong) HttpTool *httpTool;
@end
@implementation WCChatViewController


//http 工具类
- (HttpTool *)httpTool {
    if(!_httpTool){
        _httpTool = [[HttpTool alloc] init];
    }
    return _httpTool;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    WCLog(@"viewDidLoad");
    //代码的方式实现自动布局 VFL
    
    [self setupView];
    self.title = self.friendJid.user;
    //键盘的监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self loadMsgs];
    [self scrollToTableBottom];
}

- (void)viewWillAppear:(BOOL)animated {
//
}



//iOS 7 这个方法无效
//- (void)kbFrmWillChange:(NSNotification *)noti {
//    WCLog(@"noti:%@",noti.userInfo);
//    //获取窗口的高度
//    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;
//    
//    //键盘结束的Frm
//    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    //获取键盘结束的Y值
//    CGFloat kbEndY = kbEndFrm.origin.y;
//    
//    self.inputViewBottomConstraint.constant = windowH - kbEndY;
//    
//}

- (void)keyboardWillShow:(NSNotification *)noti {
    //获取键盘的高度
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrm.size.height;
    //竖屏{{0,0},{768,264}}
    //横屏{{0,0},{352,1024}}
    //如果是iOS7 以下的，当屏幕是横屏，键盘的高度是size.with
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        kbHeight = kbEndFrm.size.width;
    }
    self.inputViewBottomConstraint.constant = kbHeight;
    //表格滚动到底部
    [self scrollToTableBottom];
}


- (void)keyboardWillHide:(NSNotification *)noti {
    //关闭键盘，输入框距离底部约束的距离为 0
    self.inputViewBottomConstraint.constant = 0;
}

//代码的方式实现自动布局 VFL
- (void)setupView{
    //创建一个TableView
    UITableView *tableView = [[UITableView alloc] init];
//    tableView.backgroundColor = [UIColor yellowColor];
    tableView.delegate = self;
    tableView.dataSource = self;
#warning 代码实现自动布局 要设置下面的属性 否则 代码布局无效
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //创建一个输入框
    WCInputView *inputView = [WCInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:inputView];
    inputView.textView.delegate = self;
    
    //添加按钮事件
    [inputView.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    //自动布局
    //1.添加 水平方向上的约束
    NSDictionary *views = @{@"tableview":tableView,
                            @"inputview":inputView};
    //tableView水平方向上的约束
    NSArray *tableviewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableview]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableviewHConstraints];
    //inputView 水平方向上的约束
    NSArray *inputViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputview]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConstraints];
    
    //2.添加 竖直方向上的约束
    //tableView inputView竖直方向上的约束
    NSArray *VConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableview]-0-[inputview(50)]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:VConstraints];
    
    //查看 可以发现  VConstraints数组里 的最后一个 约束就是inputViewBottomConstraint
    WCLog(@"constraitsV:%@",VConstraints);
    self.inputViewHeightConstraint = VConstraints[2];
    self.inputViewBottomConstraint = VConstraints.lastObject;
    
}

#pragma mark -- 加载XMPPMessageArching数据库的数据,显示在表格里
- (void)loadMsgs {
    //上下文
    NSManagedObjectContext *context = [WCXMPPTool sharedWCXMPPTool].msgStorage.mainThreadManagedObjectContext ;
    //请求对象
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //过滤 排序 bareJIDstr 当前用户登陆的JID
    //1.当前登录用户的jid 的消息
    
    //2.好友的jid 的消息
//    NSString *friendJid = nil;

    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[WCUserInfo sharedWCUserInfo].jid,self.friendJid.bare];
    request.predicate = pre;
    //排序 时间升序 最新的排在最下面
    NSSortDescriptor *timerSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timerSort];

    //查询
    _resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultController.delegate = self;
    NSError *err = nil;
    [_resultController performFetch:&err];
    if (err) {
        WCLog(@"%@",err);
    }
}

#pragma  mark -- dataSource 的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    {
    
    return _resultController.fetchedObjects.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"ChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    //获取聊天消息对象
    XMPPMessageArchiving_Message_CoreDataObject *msg = _resultController.fetchedObjects[indexPath.row];
    
    //判断是图片还是纯文本
    NSString *chatType = [msg.message attributeStringValueForName:@"bodyType"];
    if ([msg.outgoing boolValue]) {
        if ([chatType isEqualToString:@"image"]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"placeHolder"]];
            cell.textLabel.text = nil;
        }
        else{
            cell.textLabel.text = [NSString stringWithFormat:@"Me: %@", msg.body];
            cell.imageView.image = nil;
        }
    }else {
        cell.textLabel.text = [NSString stringWithFormat:@"Other: %@", msg.body];
        cell.imageView.image = nil;
    }
    /*
    if ([chatType isEqualToString:@"image"]) {
        //图片显示
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"placeHolder"]];
//        if([msg.outgoing boolValue]){
//            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"placeHolder"]];
//        }else {
//            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"placeHolder"]];
//        }
        //该重用单元格 资源设置要，若有文本内容，清除文本内容的缓存
        cell.textLabel.text = nil;
    }else if([chatType isEqualToString:@"text"]) {
        //显示消息
        //outgoing 字段标示消息是自己发出的，还是接受到的
        //显示消息
        if([msg.outgoing boolValue] == 1){
            cell.textLabel.text = [NSString stringWithFormat:@"Me: %@", msg.body];
        }else if([msg.outgoing boolValue] == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Other: %@", msg.body];
        }
        //该单元格资源设置，清除图片内容
        cell.imageView.image = nil;
    }
    
    */
    
        return cell;
}

#pragma mark resultController 代理
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    [self scrollToTableBottom];
}

#pragma mark TextView的代理
- (void)textViewDidChange:(UITextView *)textView {
//    [self scrollToTableBottom];
    //获取ContentSize
    CGSize size = textView.contentSize;
    CGFloat contentH = textView.contentSize.height;
    WCLog(@"textView的content的高度: %f",size.height);
    //大于33 超过一行的高度、小于68 高度是在三行以内
    if (contentH > 33 && contentH <= 68) {
        self.inputViewHeightConstraint.constant = contentH + 18;
    }

    NSString *text = textView.text;
    //换行就等于点击了send
    if ([text rangeOfString:@"\n"].length != 0) {
        WCLog(@"发送的聊天内容%@",text);
        //去除换行字符
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self sendMsgWithText:text bodyType:@"text"];
        textView.text = nil;
        //发送完消息，把inputView的高度改过来
        self.inputViewHeightConstraint.constant = 50;
    }else {
        NSLog(@"%@",textView.text);
    }
}

//发送数据的方法
- (void)sendMsgWithText:(NSString *)text bodyType:(NSString *)bodyType{
//    WCLog(@"");
    //担任聊天类型 “chat”
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
//    [msg addAttributeWithName:@"bodyType" stringVale:bodyType];
    //给 msg  多配置一个区分聊天内容类型的字段  text-纯文本  image-图片
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    //设置body 不是点属性
    [msg addBody:text];
    WCLog(@"发送的聊天内容 msg:%@",msg);
    //设置内容
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
    
}

#pragma mark 滚动tableView到底部
- (void)scrollToTableBottom {
    NSInteger lastRow = _resultController.fetchedObjects.count - 1;
    if(lastRow < 0) {
        //行数如果小于0 不能滚动
        return;
    }
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark 选择图片
- (void)addBtnClick {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark 选取后图片的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    WCLog(@"%@",info);
    //隐藏图片旋转器的窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    //获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //把图片发送到文件服务器
    //文件的上传路径：http://localhost:8080/imfileserver/Upload/Image/ + 图片名（程序员自己定义）
    /*
     * put 实现上传没post 那么繁琐，而且比post 快
     *  put 的文件上传路径就是下载路径
     */
    // 1。取文件名 用户名 + 时间（20160704000000）年月日 时分秒
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    //针对该服务器 ，文件名必须要加后缀 ，有的是需要的
    NSString *fileName = [user stringByAppendingString:timeStr];
    // 2.拼接上传路径
    NSString *upLoadUrl = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    // 3.使用HTTP put 上传
#warning 图片上传请使用jpg 格式，因为服务器写的服务只接收
    //jpg 0.75 压缩比例 第一个 block 进度 第二个 成功与否
    [self.httpTool uploadData:UIImageJPEGRepresentation(image, 0.75) url:[NSURL URLWithString:upLoadUrl] progressBlock:nil completion:^(NSError *error) {
        if (!error) {
            WCLog(@"上传成功！");
            [self sendMsgWithText:upLoadUrl bodyType:@"image"];
        }else {
            NSLog(@"上传图片 error:%@",error);
        }
    }];
    
    //图片发送成功，把图片的URL传到openFier服务器
    
    
}
@end
