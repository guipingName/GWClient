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
    id object = [upstreamPacket object];
    if (![object isKindOfClass:[NSData class]]) {
        [RHSocketException raiseWithReason:@"[Encode] object should be NSData ..."];
        return;
    }
    
    NSData *data = object;
    if (data.length == 0) {
        return;
    }
    //可变长度编码，数据块的前两个字节为后续完整数据块的长度
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
