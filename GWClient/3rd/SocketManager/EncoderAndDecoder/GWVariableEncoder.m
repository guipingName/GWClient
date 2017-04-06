//
//  GWVariableEncoder.m
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import "GWVariableEncoder.h"
#import <GCDAsyncSocket.h>

@implementation GWVariableEncoder

- (void)encode:(id<GWRequestPacket>)requestStreamPacket output:(id<GWSocketEncoderOutputProtocol>)output
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:requestStreamPacket.object];
    //可变长度编码，数据块的前两个字节为后续完整数据块的长度
    NSUInteger dataLen = data.length;
    NSDictionary *headeDic = @{
                               @"len":[NSNumber numberWithUnsignedInteger:dataLen],
                               @"command":[NSNumber numberWithInteger:requestStreamPacket.pid]
                               };
    NSMutableData *sendData = [[NSMutableData alloc] init];
    NSData *headData =  [NSJSONSerialization dataWithJSONObject:headeDic options:NSJSONWritingPrettyPrinted error:nil];
    [sendData appendData:headData];
    //在数据中加入[GCDAsyncSocket CRData]标记，读取时获取数据包信息
    [sendData appendData:[GCDAsyncSocket CRLFData]];
    [sendData appendData:data];
    //    NSLog(@"发送数据包长度%lu,总数据长度%lu", (unsigned long)dataLen, sendData.length);
    NSTimeInterval timeout = requestStreamPacket.timeout;
    [output didEncode:sendData timeout:timeout];

    
}

@end
