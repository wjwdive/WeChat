//
//  WCInputView.h
//  WeChat
//
//  Created by wjw on 16/6/30.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCInputView : UIView
//暴露出输入框
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
+ (instancetype)inputView;
@end
