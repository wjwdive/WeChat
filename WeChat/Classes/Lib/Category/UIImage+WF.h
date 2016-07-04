//
//  UIImage+WF.h
//  WeChat
//
//  Created by wjw on 16/6/30.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WF)
//判断一个图片是PNG 类型还是 JPG 类型
+ (NSString *)typeOfImage:(NSData *)imageData;
/**
 *返回中心拉伸的图片
 */
+(UIImage *)stretchedImageWithName:(NSString *)name;
@end
