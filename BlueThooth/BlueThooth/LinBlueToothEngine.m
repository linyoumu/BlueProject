//
//  LinBlueToothEngine.m
//  BlueThooth
//
//  Created by Myfly on 17/8/16.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import "LinBlueToothEngine.h"
#import "NSString+Engine.h"

@interface LinBlueToothEngine(){
    NSString * _state;
    int _count;
    //    BOOL _hasReady;
    dispatch_queue_t _reSendQueue;
}


@end
@implementation LinBlueToothEngine

/*
 * 单例方法
 */
+(LinBlueToothEngine *)shareInstance
{
    static dispatch_once_t pred = 0;
    __strong static LinBlueToothEngine *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[LinBlueToothEngine alloc] init]; // or some other init method
    });
    return _sharedObject;
}


/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
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
-(void)startconnectServiceWithType:(BlueSendModelType)senderType{
    
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
- (void)sendWriteData:(NSData *)data WithType:(BlueSendModelType)senderType{
    [self.deviceModel.peripheral writeValue:data forCharacteristic:self.deviceModel.characteristcs type:CBCharacteristicWriteWithResponse];
    
}

#pragma mark delegate
//搜索成功的回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    // 52代表右
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
        self.deviceModel.peripheral = peripheral;
        !self.scanningToAroundYES ? : self.scanningToAroundYES(peripheral.name);
    }
    
}

//外设连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
        if (peripheral == self.deviceModel.peripheral) {
            self.deviceModel.peripheral.delegate = self;
            [self.deviceModel.peripheral discoverServices:nil];
            _isConnect = YES;
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
            _isConnect = NO;
            !self.loseConnention ? :self.loseConnention();
        }
    }
}

//*************扫描外设中的服务和特征**************

//发现外设的service
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        !self.connentionFailure ? :self.connentionFailure();
        //        NSLog(@"在这个发现了 %@ 服务 错误: %@", peripheral.name, error);
        return;
    }
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]){
        
        for (CBService *service in peripheral.services)
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:BLUETOOTH_CBUUID]])
            {
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}


//// 外设发现service的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if (error) {
        return;
    }
    //NSLog(@"%@", peripheral);
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]){
        NSLog(@"发现特征");
        if (peripheral == self.deviceModel.peripheral) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WRITE_CHARACTERISTIC]]) {
                    self.deviceModel.characteristcs = characteristic;
                    NSLog(@"写入");
                }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:READ_CHARACTERISTIC]]){
                    NSLog(@"通知");
                    [self.deviceModel.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
            
        }
        !self.connectionSuccess ? : self.connectionSuccess ();
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        return;
    }
    if ([peripheral.name isEqualToString:BLUETOOTH_DEVICE_NAME]) {
        if (peripheral == self.deviceModel.peripheral) {
            NSString * resultString = [[NSString stringWithHexData:characteristic.value] stringUpperCase];
            //NSLog(@"+++++%@",resultString);
            !self.dataReportingBluetooth ? : self.dataReportingBluetooth(resultString);
            
        }
    }
    
}


#pragma mark 内部函数
-(id)init
{
    if(self = [super init]){
        self.seqendIdArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _isPowerOn = YES;
        self.isReConnection = NO;
        self.deviceModel = [[LinBlueToothModel alloc]init];
        NSString *resStr = @"reSendThread";
        const char *reSendQueueName = [resStr UTF8String];
        _reSendQueue = dispatch_queue_create(reSendQueueName, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

/**
 * *************************************************************
 * 工具类方法
 */
/**********************************************************************************/
#pragma mark 并行重新发送机制
/*
 - (void)reSendParallelMessageMechanism:(SKGBlueCmdModel * )sendModel{
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 if ([sendModel.typeString isEqualToString:@"Left"]) {
 dispatch_time_t firstTime = dispatch_time(DISPATCH_TIME_NOW, 300*NSEC_PER_MSEC);
 dispatch_after(firstTime, _reSendQueue, ^{
 if ([self.leftSeqendIdArray containsObject:sendModel.seqendId]) {
 [self.leftSeqendIdArray removeObject:sendModel.seqendId];
 return;
 }else{
 // 第一次重新发送
 [self sendWriteData:sendModel.cmdData WithType:SKGDataModelLeftType];
 }
 dispatch_time_t secondTime = dispatch_time(DISPATCH_TIME_NOW, 300*NSEC_PER_MSEC);
 
 dispatch_after(secondTime, _reSendQueue, ^{
 if ([self.leftSeqendIdArray containsObject:sendModel.seqendId]) {
 [self.leftSeqendIdArray removeObject:sendModel.seqendId];
 return;
 }else{
 // 第二次重新发送
 [self sendWriteData:sendModel.cmdData WithType:SKGDataModelLeftType];
 }
 dispatch_time_t lastTime = dispatch_time(DISPATCH_TIME_NOW, 400*NSEC_PER_MSEC);
 dispatch_after(lastTime, _reSendQueue, ^{
 if ([self.leftSeqendIdArray containsObject:sendModel.seqendId]) {
 [self.leftSeqendIdArray removeObject:sendModel.seqendId];
 return;
 }else{
 // 抛出超时错误信息
 
 // 刷新 UI
 !self.timeOutBluetooth ? : self.timeOutBluetooth([NSString stringWithFormat:@"%@",sendModel.cmdData],@"");
 }
 
 });
 });
 });
 
 }else{
 dispatch_time_t firstTime = dispatch_time(DISPATCH_TIME_NOW, 300*NSEC_PER_MSEC);
 dispatch_after(firstTime, _reSendQueue, ^{
 if ([self.rightSeqendIdArray containsObject:sendModel.seqendId]) {
 [self.rightSeqendIdArray removeObject:sendModel.seqendId];
 return;
 }else{
 // 第一次重新发送
 [self sendWriteData:sendModel.cmdData WithType:SKGDataModelRightType];
 }
 dispatch_time_t secondTime = dispatch_time(DISPATCH_TIME_NOW, 300*NSEC_PER_MSEC);
 
 dispatch_after(secondTime, _reSendQueue, ^{
 if ([self.rightSeqendIdArray containsObject:sendModel.seqendId]) {
 [self.rightSeqendIdArray removeObject:sendModel.seqendId];
 return;
 }else{
 // 第二次重新发送
 [self sendWriteData:sendModel.cmdData WithType:SKGDataModelRightType];
 }
 dispatch_time_t lastTime = dispatch_time(DISPATCH_TIME_NOW, 400*NSEC_PER_MSEC);
 dispatch_after(lastTime, _reSendQueue, ^{
 if ([self.rightSeqendIdArray containsObject:sendModel.seqendId]) {
 [self.rightSeqendIdArray removeObject:sendModel.seqendId];
 return;
 }else{
 // 抛出超时错误信息
 
 // 刷新 UI
 !self.timeOutBluetooth ? : self.timeOutBluetooth(@"",[NSString stringWithFormat:@"%@",sendModel.cmdData]);
 }
 
 });
 });
 });
 }
 });
 }
 */

@end
