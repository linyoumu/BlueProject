//
//  LinBlueToothModel.h
//  BlueThooth
//
//  Created by LinYouMu on 17/8/16.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LinBlueToothModel : NSObject

@property (strong,nonatomic) CBPeripheral *peripheral;
// 写特征
@property (strong,nonatomic) CBCharacteristic *characteristcs;
// 升级特征
@property (strong,nonatomic) CBCharacteristic *updateCharacteristcs;

@end
