//
//  NSString+Engine.h
//  BlueThooth
//
//  Created by Myfly on 17/8/14.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import "NSString+Engine.h"

@implementation NSString (Engine)

#pragma mark  转换大小写
// 全部大写
- (NSString * )stringUpperCase{
    return  [self uppercaseString];
}

//16进制的字符串转16位Data 蓝牙常用到
- (NSData *)stringHexToBytesData{
    NSMutableData * data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
// 10进制数转成16
- (NSString *)stringWithHexValueIntString:(NSString *)number{
    int num = [number intValue];
    return [NSString stringWithFormat:@"%x",num];
}
// 16进制数转成10数
- (NSInteger)stringWithIntValueHexString:(NSString *)numString{
    return  strtoul([numString UTF8String], 0, 16);
}

// data转成NSString
+ (NSString *)stringWithHexData:(NSData * )data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return  hexStr;
}

@end
