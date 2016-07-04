//
//  WCProfileViewController.m
//  WeChat
//
//  Created by wjw on 16/6/28.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "WCEditProfileViewController.h"

@interface WCProfileViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,WCEditProfileViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headerView;//头像
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;//昵称
@property (weak, nonatomic) IBOutlet UILabel *weixinNumLabel;//微信号

@property (weak, nonatomic) IBOutlet UILabel *orgnameLabel;//公司
@property (weak, nonatomic) IBOutlet UILabel *orgunitLabel;//部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//职位
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;//电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;//电子邮件


@end

@implementation WCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人信息";
    [self loadvCard];
}

- (void)loadvCard{
    //显示个人信息
    XMPPvCardTemp *myVcard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    //设置头像
    if(myVcard.photo){
        self.headerView.image = [UIImage imageWithData:myVcard.photo];
    }
    //设置昵称
    self.nickNameLabel.text = myVcard.nickname;
    //设置微信号
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
    self.weixinNumLabel.text = [NSString stringWithFormat:@"%@",user];
    
    //公司
    self.orgnameLabel.text = myVcard.orgName;
    //部门
    if ( myVcard.orgUnits.count > 0) {
        self.orgunitLabel.text = myVcard.orgUnits[0];
    }
    //职位
    self.titleLabel.text = myVcard.title;
    //电话
#warning myCard.telecomsAddress 这个get方法，没有对电子名片的xml 数据进行解析
    //使用 note 字段从当电话
    self.phoneLabel.text = myVcard.note;
    
    //邮件
#warning  用mailer 的信心充当邮件
//    self.emailLabel.text = myVcard.mailer;
  
    if (myVcard.emailAddresses.count > 0) {
        //不管有多少个邮箱，只去第一个
        self.emailLabel.text = myVcard.emailAddresses[0];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取cell.tag
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger tag = cell.tag;
    
    //判断
    if(tag == 2){
        return;
    }
    if (tag == 0) {
        WCLog(@"选择照片");
        UIActionSheet *sheet = [[UIActionSheet alloc]
                           initWithTitle:@"请选择"
                           delegate:self
                           cancelButtonTitle:@"取消"
                           destructiveButtonTitle:@"照相"
                           otherButtonTitles:@"相册", nil];
        [sheet showInView:self.view];
    }else{
        WCLog(@"跳到下一个控制器");
        [self performSegueWithIdentifier:@"EditvCardSegue" sender:cell];
    }
}

//跳转之前
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //获取编辑个人信息控制器
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[WCEditProfileViewController class]]) {
        WCEditProfileViewController *editVc = destVc;
        editVc.cell = sender;
        editVc.delegate = self;
    }
}

#pragma mark actionsheet 的代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //设置代理
    imagePicker.delegate = self;
    //允许编辑
    imagePicker.allowsEditing = YES;
    //
    if(buttonIndex == 0 ){//照相
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{//图库
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    //显示图片选择器
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark -- 图片选择器的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    WCLog(@"%@",info);
    //获取图片 设置图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headerView.image = image;
    //隐藏当前的模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    // 更新到服务器
    [self editProfileViewControllerDidSave];

}



#pragma mark 编辑个人信息的控制器代理
- (void)editProfileViewControllerDidSave {
    //保存
    //获取当前的电子名片信息
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    //头像 图片 转 data
    myvCard.photo = UIImagePNGRepresentation(self.headerView.image);
    //昵称
    myvCard.nickname = self.nickNameLabel.text;
    //公司
    myvCard.orgName = self.orgnameLabel.text;
    //部门
    if (self.orgnameLabel.text.length > 0) {
        myvCard.orgUnits = @[self.orgunitLabel.text];
    }
    
    //职位
    myvCard.title = self.titleLabel.text;
    //电话
    myvCard.note = self.phoneLabel.text;
    //邮件
//    myvCard.mailer = self.emailLabel.text;
    if (self.emailLabel.text.length > 0) {
        myvCard.emailAddresses = @[self.emailLabel.text];
    }
    //更新到服务器
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:myvCard];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
