//
//  RHSocketConnection.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"
#import "GCDAsyncSocket.h"

#define READ_HEAD_TIMEOUT 5.0
#define READ_TIMEOUT 15.0
#define WRITE_TIMEOUT 15.0
#define SEND_TAG 0

@interface RHSocketConnection () <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_asyncSocket;
    NSDictionary *currentPacketHead;
    NSInteger reqestCommand;
}

@end

@implementation RHSocketConnection

- (instancetype)init
{
    if (self = [super init]) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_asyncSocket setIPv4PreferredOverIPv6:NO];
    }
    return self;
}

- (void)dealloc
{
    _asyncSocket.delegate = nil;
    _asyncSocket = nil;
}

- (void)connectWithHost:(NSString *)hostName port:(int)port
{
    NSError *error = nil;
    [_asyncSocket connectToHost:hostName onPort:port error:&error];
    if (error) {
        RHSocketLog(@"[RHSocketConnection] connectWithHost error: %@", error.description);
        if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
            [_delegate didDisconnectWithError:error];
        }
    }
}

- (void)disconnect
{
    [_asyncSocket disconnect];
}

- (BOOL)isConnected
{
    return [_asyncSocket isConnected];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:timeout tag:tag];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_asyncSocket writeData:data withTimeout:timeout tag:tag];
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSUInteger done = 0;
//        NSUInteger total = 0;
//        float asign = [_asyncSocket progressOfWriteReturningTag:&tag bytesDone:&done total:&total];
//        NSLog(@"++++++++++++ 完成=%u --------全部=%u,============进度=%f",done, total, asign);
    }];
}

#pragma mark -
#pragma mark GCDAsyncSocketDelegate method

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    RHSocketLog(@"[RHSocketConnection] didDisconnect...%@", err.description);
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
        [_delegate didDisconnectWithError:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    RHSocketLog(@"[RHSocketConnection] didConnectToHost: %@, port: %d", host, port);
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectToHost:port:)]) {
        [_delegate didConnectToHost:host port:port];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveDataDic:tag:)]) {
        if (!currentPacketHead) {
            currentPacketHead = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingMutableContainers
                                 error:nil];
            if (!currentPacketHead) {
                NSLog(@"error：当前数据包的头为空");
                return;
            }
            NSUInteger packetLength = [currentPacketHead[@"len"] integerValue];
            reqestCommand = [currentPacketHead[@"command"] integerValue];
            NSLog(@"收到数据包传输长度:%lu",(unsigned long)packetLength);
            [sock readDataToLength:packetLength withTimeout:-1 tag:0];
            return;
        }
        NSDictionary *dic = @{@"data":data,
                              @"command":[NSNumber numberWithInteger:reqestCommand]
                              };
        [_delegate didReceiveDataDic:dic tag:tag];
        currentPacketHead = nil;
    }
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    RHSocketLog(@"[RHSocketConnection] didWriteDataWithTag: %ld", tag);
    [_asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:tag];

}

@end
