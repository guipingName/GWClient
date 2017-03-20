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

@interface RHSocketVariableLengthEncoder()
@property (nonatomic, assign) int requestCommand;
@end
@implementation RHSocketVariableLengthEncoder

- (instancetype)init
{
    if (self = [super init]) {
        _maxFrameSize = 65536;
        _countOfLengthByte = 2;
        _requestCommand = 1;
        _reverseOfLengthByte = NO;
    }
    return self;
}

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
    }//
    
    
    if (data.length >= _maxFrameSize - _countOfLengthByte - _requestCommand) {
        [RHSocketException raiseWithReason:@"[Encode] Too Long Frame ..."];
        return;
    }
    // 请求命令参数，默认一个字节
    NSInteger command = upstreamPacket.pid;
    //可变长度编码，数据块的前两个字节为后续完整数据块的长度
    NSUInteger dataLen = data.length;
    
    NSMutableData *sendData = [[NSMutableData alloc] init];
    
    //将数据长度转换为长度字节，写入到数据块中。这里根据head占的字节个数转换data长度，默认为2个字节
    NSData *headData = [RHSocketUtils bytesFromValue:dataLen byteCount:_countOfLengthByte reverse:_reverseOfLengthByte];
    NSData *commandData = [RHSocketUtils bytesFromValue:command byteCount:_requestCommand reverse:_reverseOfLengthByte];
    [sendData appendData:headData];
    [sendData appendData:commandData];
    [sendData appendData:data];
    NSTimeInterval timeout = [upstreamPacket timeout];
    
    RHSocketLog(@"timeout: %f, sendData: %@", timeout, sendData);
    [output didEncode:sendData timeout:timeout];
}

@end
