//
//  UIImage+WF.m
//  WeChat
//
//  Created by wjw on 16/6/30.
//  Copyright © 2016年 wjwdive. All rights reserved.
//

#import "UIImage+WF.h"

@implementation UIImage (WF)
+ (NSString *)typeOfImage:(NSData *)imageData{
    uint8_t c;
    
    [imageData getBytes:&c length:1];
    
    
    
    switch (c) {
            
        case 0xFF:
            
            return @"jpeg";
            
        case 0x89:
            
            return @"png";
            
        case 0x47:
            
            return @"gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"tiff";
            
    }
    
    return nil;

}

+(UIImage *)stretchedImageWithName:(NSString *)name{
    
    UIImage *image = [UIImage imageNamed:name];
    int leftCap = image.size.width * 0.5;
    int topCap = image.size.height * 0.5;
    return [image stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}
@end
