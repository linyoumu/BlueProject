//
//  ViewController.m
//  BlueThooth
//
//  Created by LinYouMu on 17/8/14.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import "ViewController.h"
#import "LinBlueToothEngine.h"
#import "NSString+Engine.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) LinBlueToothEngine *blueToothEngine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blueToothEngine = [LinBlueToothEngine shareInstance];
    __weak ViewController * weakSelf = self;
    //设置扫描到外设的Block
    [self.blueToothEngine setScanningToAroundYES:^(NSString *name) {
        [weakSelf.blueToothEngine stopScan];
        if ([name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
            weakSelf.infoLabel.text = @"已扫描到设备";
            NSLog(@"设备已扫描到--%@", name);
            [weakSelf.blueToothEngine startconnectService];
        }
    }];
    
    //设置设备连接成功的Block
    [self.blueToothEngine setConnectionSuccess:^{
        weakSelf.infoLabel.text = @"连接成功";
        NSLog(@"设备已连接");
    }];
    
    //设置设备断开连接的Block
    [self.blueToothEngine setLoseConnention:^{
        weakSelf.infoLabel.text = @"失去连接";
    }];

    //设置蓝牙数据上报的Block
    [self.blueToothEngine setDataReportingBluetooth:^(NSString *info) {
        weakSelf.infoLabel.text = info;
        NSLog(@"info===%@", info);
    }];
}

//连接
- (IBAction)conectAction:(id)sender {
    [self.blueToothEngine startScanWithFailure:nil];
}

//断开连接
- (IBAction)disConnectAction:(id)sender {
    [self.blueToothEngine cancelConnectService];
}

//重连
- (IBAction)reConnectAction:(id)sender {
    [self.blueToothEngine startconnectService];
}

//发送指令
- (IBAction)sendCommand:(id)sender {
    NSString *command = @"E1000101";
    NSData *data = [command stringHexToBytesData];
    [self.blueToothEngine sendWriteData:data];
    
    //NSString *command = @"10";
    //NSData *data = [command stringHexToBytesData];
    //[self.blueToothEngine sendWriteData1:data];
    
}

//- (IBAction)sendCommand1:(id)sender {
//    NSString *command = @"E1000101";
//    NSData *data = [command stringHexToBytesData];
//    [self.blueToothEngine sendWriteData1:data];
//}

- (IBAction)updateVersion:(id)sender {
    self.blueToothEngine.isUpdateVersion = YES;
    [self.blueToothEngine startScanWithFailure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
