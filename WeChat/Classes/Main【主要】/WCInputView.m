//
//  WCInputView.m
//  WeChat
//
//  Created by wjw on 16/6/30.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "WCInputView.h"

@implementation WCInputView
//返回自己定义的 inputView
+ (instancetype)inputView{
    return [[[NSBundle mainBundle] loadNibNamed:@"WCInputView" owner:nil options:nil] lastObject];
}
@end
