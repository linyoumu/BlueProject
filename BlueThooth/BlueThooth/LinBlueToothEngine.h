//
//  LinBlueToothEngine.h
//  BlueThooth
//
//  Created by LinYouMu on 17/8/16.
//  Copyright © 2017年 Myfly. All rights reserved.
//




#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LinBlueToothModel.h"

#define BLUETOOTH_DEVICE_NAME @"temp"
//服务-id
#define BLUETOOTH_CBUUID @"00000100-1212-efde-1523-785feabcd123"
//读特征-id
#define READ_CHARACTERISTIC @"00000101-1212-efde-1523-785feabcd123"
//写特征-id
#define WRITE_CHARACTERISTIC @"00000102-1212-efde-1523-785feabcd123"

@interface LinBlueToothEngine : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSInteger _curretnTime;
    NSInteger _curretnCalorie;
    NSInteger _currentStepsCount;
    NSInteger _currentFrequency;
    NSInteger _currentMarker;
}
// 中心设备
@property (strong, nonatomic) CBCentralManager *centralManager;

@property (nonatomic, strong) NSMutableArray *seqendIdArray;

//用于存储蓝牙外设的基本属性
@property (nonatomic,strong) LinBlueToothModel *deviceModel;

//连接成功执行的Block
@property (nonatomic,copy) void (^connectionSuccess)();
//连接失败执行的Block
@property (nonatomic,copy) void (^connentionFailure)();
//连接失败执行的Block
@property (nonatomic,copy) void (^loseConnention)();
//扫描到设备执行的Block
@property (nonatomic,copy) void (^scanningToAroundYES)(NSString *);
//收到设备信息执行的Block
@property (nonatomic,copy) void (^dataReportingBluetooth)(NSString *);

//标记连接状态
@property (assign,nonatomic) BOOL isConnect;
//标记是否为重新连接
@property (nonatomic, assign) BOOL isReConnection;
//标记蓝牙是否开启
@property (assign, nonatomic) BOOL isPowerOn;

/*
 * 单例方法
 */
+(LinBlueToothEngine *)shareInstance;

/*
 * 扫描设备
 */
- (void)startScanWithFailure:(void (^)(NSString * status))failure;

/*
 * 停止扫描设备
 */
- (void)stopScan;

/*
 *  发送数据
 */
- (void)sendWriteData:(NSData *)data;

/**
 *  连接
 */
-(void)startconnectService;

/**
 *  取消连接
 */
-(void)cancelConnectService;

@end
