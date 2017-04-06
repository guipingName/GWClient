//
//  GWSocketCodecProtocol.h
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWSocketPacket.h"

#pragma mark - encoder output protocol

/**
 *  数据编码后，分发对象协议
 */
@protocol GWSocketEncoderOutputProtocol <NSObject>

@required

- (void)didEncode:(NSData *)encodedData timeout:(NSTimeInterval)timeout;

@end

#pragma mark - decoder output protocol

/**
 *  数据解码后，分发对象协议
 */
@protocol GWSocketDecoderOutputProtocol <NSObject>

@required

- (void)didDecode:(id<GWResponesPacket>)decodedPacket;

@end

#pragma mark - encoder protocol

/**
 *  编码器协议
 */
@protocol GWSocketEncoderProtocol <NSObject>

@required

/**
 *  编码器
 *
 *  @param requestStreamPacket 待发送的数据包
 *  @param output 数据编码后，分发对象
 */
- (void)encode:(id<GWRequestPacket>) requestStreamPacket output:(id<GWSocketEncoderOutputProtocol>)output;

@end

#pragma mark - decoder protocol

/**
 *  解码器协议
 */
@protocol GWSocketDecoderProtocol <NSObject>

/**
 *  解码器
 *
 *  @param responseStreamPacket 接收到的原始数据
 *  @param output           数据解码后，分发对象
 *
 *  @return -1解码异常，断开连接; 0数据不完整，等待数据包; >0解码正常，为已解码数据长度
 */
- (NSInteger)decode:(id<GWResponesPacket>) responseStreamPacket output:(id<GWSocketDecoderOutputProtocol>)output;

@end
