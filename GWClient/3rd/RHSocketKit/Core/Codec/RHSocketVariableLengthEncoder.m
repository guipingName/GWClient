//
//  RHSocketVariableLengthEncoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"
#import <GCDAsyncSocket.h>

@implementation RHSocketVariableLengthEncoder

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:upstreamPacket.object];
    NSUInteger dataLen = data.length;
    
    NSDictionary *headeDic = @{
                               @"len":[NSNumber numberWithUnsignedInteger:dataLen],
                               @"command":[NSNumber numberWithInteger:upstreamPacket.pid]
                               };
    NSMutableData *sendData = [[NSMutableData alloc] init];
    
    NSData *headData =  [NSJSONSerialization dataWithJSONObject:headeDic options:NSJSONWritingPrettyPrinted error:nil];
    [sendData appendData:headData];
    //在数据中加入[GCDAsyncSocket CRData]标记，读取时获取数据包信息
    [sendData appendData:[GCDAsyncSocket CRLFData]];
    [sendData appendData:data];
    NSTimeInterval timeout = upstreamPacket.timeout;
    [output didEncode:sendData timeout:timeout];
}

@end
