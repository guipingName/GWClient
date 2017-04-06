//
//  RHSocketChannel.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/15.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketChannel.h"
#import "RHSocketConnection.h"
#import "RHSocketException.h"
#import "RHSocketPacketContext.h"
#import "RHSocketVariableLengthDecoder.h"
#import "RHSocketVariableLengthEncoder.h"

@interface RHSocketChannel () <RHSocketConnectionDelegate, RHSocketEncoderOutputProtocol, RHSocketDecoderOutputProtocol>
{
    RHSocketConnection *_connection;
    //
    NSMutableData *_receiveDataBuffer;
    RHSocketPacketResponse *_downstreamContext;
}

@end

@implementation RHSocketChannel

- (instancetype)init
{
    if (self = [super init]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _downstreamContext = [[RHSocketPacketResponse alloc] init];
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if (self = [super init]) {
        _receiveDataBuffer = [[NSMutableData alloc] init];
        _downstreamContext = [[RHSocketPacketResponse alloc] init];
        _host = host;
        _port = port;
    }
    return self;
}

- (void)openConnection
{
    @synchronized(self) {
        [self closeConnection];
        _connection = [[RHSocketConnection alloc] init];
        _connection.delegate = self;
        [_connection connectWithHost:_host port:_port];
    }//@synchronized
}

- (void)closeConnection
{
    @synchronized(self) {
        if (_connection) {
            _connection.delegate = nil;
            [_connection disconnect];
            _connection = nil;
        }
    }//synchronized
}

- (BOOL)isConnected
{
    return [_connection isConnected];
}

// 上传
- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
        compeletProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process
{
    if (nil == _encoder) {
        RHSocketLog(@"RHSocket Encoder should not be nil ...");
        return;
    }
    _connection.processBlock = process;
    [self.encoder encode:packet output:self];
}
// 下载

- (void)asyncSendPacket:(id<RHUpstreamPacket>)packet
        downLoadProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process
{
    if (nil == _encoder) {
        RHSocketLog(@"RHSocket Encoder should not be nil ...");
        return;
    }
    _connection.downProcessBlock = process;
    [self.encoder encode:packet output:self];
}

#pragma mark RHSocketConnectionDelegate method

- (void)didDisconnectWithError:(NSError *)error
{
    [_delegate channelClosed:self error:error];
}

- (void)didConnectToHost:(NSString *)host port:(UInt16)port
{
    [_delegate channelOpened:self host:host port:port];
}

- (void)didReceiveDataDic:(NSDictionary *)dataDic tag:(long)tag
{
    NSData *data = [dataDic valueForKey:@"data"];
    NSInteger command = [[dataDic valueForKey:@"command"] integerValue];
    if (data.length < 1) {
        return;
    }
    
    if (nil == _decoder) {
        RHSocketLog(@"RHSocket Decoder should not be nil ...");
        return;
    }
    @synchronized(self) {
        [_receiveDataBuffer appendData:data];
        _downstreamContext.object = _receiveDataBuffer;
        _downstreamContext.pid = command;
        [self.decoder decode:_downstreamContext output:self];
    }//@synchronized
}

#pragma mark - RHSocketEncoderOutputProtocol
- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout
{
    if (data.length < 1) {
        return;
    }
    [_connection writeData:data timeout:timeout tag:0];
}

#pragma mark - RHSocketDecoderOutputProtocol

- (void)didDecode:(id<RHDownstreamPacket>)packet
{
    [_delegate channel:self received:packet];
}




@end
