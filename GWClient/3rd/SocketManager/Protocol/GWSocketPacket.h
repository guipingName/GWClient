//
//  GWSocketPacket.h
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//
#import <Foundation/Foundation.h>

#pragma mark - socket packet

/**
 *  数据包协议
 */
@protocol GWSocketPacket <NSObject>

@required

/**
 *  数据包携带的数据变量（可以是任何数据格式）
 */
@property (nonatomic, strong) id object;

@optional

/**
 *  类似tag，必要的时候实现，用于区分某个数据包
 */
@property (nonatomic, assign) NSInteger pid;

@end

#pragma mark - upstream packet

/**
 *  请求数据包协议，发送数据时，必须遵循的协议
 */
@protocol GWRequestPacket <GWSocketPacket>

@optional

/**
 *  发送数据超时时间，必须设置。－1时为无限等待
 */
@property (nonatomic, assign) NSTimeInterval timeout;


@end

#pragma mark - downstream packet

/**
 *  下行数据包协议，接收数据时，必须遵循的协议
 */
@protocol GWResponesPacket <GWSocketPacket>

@required
/**
 *  发送数据超时时间，必须设置。－1时为无限等待
 */
@property (nonatomic, assign) NSTimeInterval timeout;


@end
