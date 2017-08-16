//
//  ViewController.m
//  BlueThooth
//
//  Created by Myfly on 17/8/14.
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
    [self.blueToothEngine setScanningToAroundYES:^(NSString *name) {
        [weakSelf.blueToothEngine stopScan];
        if ([name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
            weakSelf.infoLabel.text = @"已扫描到设备";
            NSLog(@"设备已扫描到--%@", name);
            [weakSelf.blueToothEngine startconnectServiceWithType:BlueDataModelLeftType];
        }
    }];
    
    [self.blueToothEngine setConnectionSuccess:^{
        weakSelf.infoLabel.text = @"连接成功";
        weakSelf.blueToothEngine.isReConnection = YES;
        NSLog(@"设备已连接");
    }];
    
    [self.blueToothEngine setLoseConnention:^{
        weakSelf.infoLabel.text = @"失去连接";
    }];

    [self.blueToothEngine setDataReportingBluetooth:^(NSString *info) {
        weakSelf.infoLabel.text = info;
        NSLog(@"info===%@", info);
    }];
    
    
}

- (IBAction)conectAction:(id)sender {
    [self.blueToothEngine startScanWithFailure:nil];
}

- (IBAction)disConnectAction:(id)sender {
    [self.blueToothEngine cancelConnectService];
}

- (IBAction)reConnectAction:(id)sender {
    [self.blueToothEngine startconnectServiceWithType:BlueDataModelLeftType];
}

- (IBAction)sendCommand:(id)sender {
    NSString *command = @"020000";
    NSData *data = [command stringHexToBytesData];
    [self.blueToothEngine sendWriteData:data WithType:BlueDataModelLeftType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
