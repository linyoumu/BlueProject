//
//  LinBlueToothModel.h
//  BlueThooth
//
//  Created by Myfly on 17/8/16.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LinBlueToothModel : NSObject

@property (strong,nonatomic) CBPeripheral *peripheral;
@property (strong,nonatomic) CBCharacteristic *characteristcs;

@end
