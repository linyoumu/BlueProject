//
//  LinBlueToothEngine.h
//  BlueThooth
//
//  Created by LinYouMu on 17/8/16.
//  Copyright © 2017年 Myfly. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BLUETOOTH_DEVICE_NAME @"temp"
#define BLUETOOTH_DEVICE_DFU @"DfuTarg"
//服务-id
#define BLUETOOTH_CBUUID @"00000100-1212-efde-1523-785feabcd123"
//读特征-id
#define READ_CHARACTERISTIC @"00000101-1212-efde-1523-785feabcd123"
//写特征-id
#define WRITE_CHARACTERISTIC @"00000102-1212-efde-1523-785feabcd123"

//升级特征-id
//#define UPDATE_CHARACTERISTIC @"00000201-1212-efde-1523-785feabcd123"

@interface LinBlueToothEngine : NSObject

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
//执行升级的Block
@property (nonatomic,copy) void (^uploadVersion)();
@property (nonatomic, assign) BOOL isUpdateVersion;

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
/**
 *  连接
 */
-(void)startconnectService;
/**
 *  取消连接
 */
-(void)cancelConnectService;
/*
 *  发送数据
 */
- (void)sendWriteData:(NSData *)data;

@end
