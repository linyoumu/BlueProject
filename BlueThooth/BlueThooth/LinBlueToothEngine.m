//
//  LinBlueToothEngine.m
//  BlueThooth
//
//  Created by LinYouMu on 17/8/16.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import "LinBlueToothEngine.h"
#import "NSString+Engine.h"
#import "LinBlueToothModel.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface LinBlueToothEngine()<CBCentralManagerDelegate, CBPeripheralDelegate, LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate>
{
    NSString * _state;
}
//中心设备
@property (strong, nonatomic) CBCentralManager *centralManager;
//用于存储蓝牙外设的基本属性
@property (nonatomic,strong) LinBlueToothModel *deviceModel;
//标记是否为重新连接
@property (nonatomic, assign) BOOL isReConnection;
//标记蓝牙是否开启
@property (assign, nonatomic) BOOL isPowerOn;

@end

@implementation LinBlueToothEngine

#pragma mark 内部函数
/*
 * 初始化方法
 */
-(id)init{
    if(self = [super init]){
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.isPowerOn = YES;
        self.isReConnection = NO;
        self.deviceModel = [[LinBlueToothModel alloc]init];
    }
    return self;
}
/*
 * 单例方法
 */
+(LinBlueToothEngine *)shareInstance
{
    static dispatch_once_t pred = 0;
    __strong static LinBlueToothEngine *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[LinBlueToothEngine alloc] init]; 
    });
    return _sharedObject;
}

/*
 * 扫描设备
 */
- (void)startScanWithFailure:(void (^)(NSString * status))failure{
    if (_isPowerOn){
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }else{
        !failure ? : failure(_state);
    }
}
/*
 * 停止扫描设备
 */
- (void)stopScan{
    [self.centralManager stopScan];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startScanWithFailure:) object:nil];
}


/**
 *  连接
 */
-(void)startconnectService{
    [self.centralManager connectPeripheral:self.deviceModel.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey :@YES}];
    
}
/**
 *  取消连接
 */
-(void)cancelConnectService{
    [self.centralManager cancelPeripheralConnection:self.deviceModel.peripheral];
    
}

/*
 *  发送数据
 */
- (void)sendWriteData:(NSData *)data{
    [self.deviceModel.peripheral writeValue:data forCharacteristic:self.deviceModel.characteristcs type:CBCharacteristicWriteWithResponse];
    
}

#pragma mark CBCentralManagerDelegate
//蓝牙状态变化
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    _isPowerOn = NO;
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            _state = @"平台/硬件不支持蓝牙";
            break;
        case CBCentralManagerStateUnauthorized:
            _state = @"这个应用程序未被授权使用蓝牙";
            break;
        case CBCentralManagerStatePoweredOff:
            _state = @"目前蓝牙关闭";
            break;
        case CBCentralManagerStatePoweredOn:
            _state = @"正常打开了";
            _isPowerOn = YES;
            break;
        case CBCentralManagerStateUnknown:
        default:
            ;
    }
}
//搜索成功的回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
        self.deviceModel.peripheral = peripheral;
        !self.scanningToAroundYES ? : self.scanningToAroundYES(peripheral.name);
    }
    
}

//外设连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
        if (peripheral == self.deviceModel.peripheral) {
            self.deviceModel.peripheral.delegate = self;
            [self.deviceModel.peripheral discoverServices:nil];
        }
    }
}

//外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
        !self.connentionFailure ? :self.connentionFailure();
    }
}

//丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]){
        if (peripheral == self.deviceModel.peripheral) {
            !self.loseConnention ? :self.loseConnention();
        }
    }
}

//*************扫描外设中的服务和特征**************
#pragma mark CBPeripheralDelegate
//发现外设的service
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error){
        !self.connentionFailure ? :self.connentionFailure();
        return;
    }
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]){
        for (CBService *service in peripheral.services){
            if ([service.UUID isEqual:[CBUUID UUIDWithString:BLUETOOTH_CBUUID]]){
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}


//// 外设发现service的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        return;
    }
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]){
        if (peripheral == self.deviceModel.peripheral) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WRITE_CHARACTERISTIC]]) {
                    NSLog(@"写入特征");
                    self.deviceModel.characteristcs = characteristic;
                }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:READ_CHARACTERISTIC]]){
                    NSLog(@"通知特征");
                    [self.deviceModel.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
        self.isReConnection = YES;
        !self.connectionSuccess ? : self.connectionSuccess ();
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        return;
    }
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
        if (peripheral == self.deviceModel.peripheral) {
            NSString * resultString = [[NSString stringWithHexData:characteristic.value] stringUpperCase];
            !self.dataReportingBluetooth ? : self.dataReportingBluetooth(resultString);
        }
    }
}



#pragma mark - LoggerDelegate
- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message
{
    [self goodMessage:[NSString stringWithFormat:@"[Framework][%ld]:%@", (long)level, message]];
}

#pragma mark - DFUServiceDelegate
- (void)didStateChangedTo:(enum DFUState)state
{
    [self goodMessage:[NSString stringWithFormat:@"[Framework]State changed to:%ld", (long)state]];
}

- (void)didErrorOccur:(enum DFUError)error withMessage:(NSString * _Nonnull)message
{
    [self badMessage:[NSString stringWithFormat:@"[Framework]Error occur:%ld, %@", error, message]];
}

#pragma mark - DFUProgressDelegate
- (void)onUploadProgress:(NSInteger)part totalParts:(NSInteger)totalParts progress:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
    [self goodMessage:[NSString stringWithFormat:@"[Framework]Uploading...%ld", (long)progress]];
}

#pragma mark - Private
- (void)goodMessage:(NSString *)goodMessage
{
    NSLog(@"[✅]%@", goodMessage);
}

- (void)badMessage:(NSString *)badMessage
{
    NSLog(@"[❌]%@", badMessage);
}


@end
