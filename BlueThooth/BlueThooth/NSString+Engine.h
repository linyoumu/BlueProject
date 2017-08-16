//
//  NSString+Engine.h
//  BlueThooth
//
//  Created by LinYouMu on 17/8/14.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Engine)

// 全部大写
- (NSString * )stringUpperCase;
// 16进制 ,蓝牙常用到
- (NSData *)stringHexToBytesData;
// 10进制数转成16
- (NSString *)stringWithHexValueIntString:(NSString *)number;
// 16进制数转成10
- (NSInteger)stringWithIntValueHexString:(NSString *)numString;
// data转成NSString
+ (NSString *)stringWithHexData:(NSData * )data;

@end
