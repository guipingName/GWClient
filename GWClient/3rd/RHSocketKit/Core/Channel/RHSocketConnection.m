//
//  RHSocketConnection.m
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketConnection.h"
#import "GCDAsyncSocket.h"
#import "AppDelegate.h"

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

@property(nonatomic, strong)NSTimer *upTimer;
@property(nonatomic, strong)NSTimer *downTimer;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        _upTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(calculateProcess:) userInfo:@(tag) repeats:YES];
        _downTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(calculateDownProcess:) userInfo:@(tag) repeats:YES];
    });
}


- (void)calculateProcess:(NSTimer *) sender
{
    long tag = [sender.userInfo integerValue];
    NSUInteger done = 0;
    NSUInteger total = 0;
    float asign = [_asyncSocket progressOfWriteReturningTag:&tag bytesDone:&done total:&total];
    if (self.processBlock) {
       self.processBlock(done,total,asign); 
    }
    if (isnan(asign)) {
        [sender invalidate];
        sender = nil;
        return;
    }
}
- (void)calculateDownProcess:(NSTimer *) sender
{
    long tag = [sender.userInfo integerValue];
    NSUInteger doweDone = 0;
    NSUInteger downToal = 0;
    float downAsign = [_asyncSocket progressOfReadReturningTag:&tag bytesDone:&doweDone total:&downToal];
    if (self.downProcessBlock) {
        self.downProcessBlock(doweDone,downToal,downAsign);
    }
    if (isnan(downAsign) || (downAsign == 1.0)) {
        [sender invalidate];
        sender = nil;
        return;
    }
}
#pragma mark GCDAsyncSocketDelegate method

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"-------------断开连接,%@",err.localizedDescription);
    NSLog(@"[RHSocketConnection] didDisconnect...%@", err.description);
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
        [_delegate didDisconnectWithError:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"[RHSocketConnection] didConnectToHost: %@, port: %d", host, port);
    AppDelegate *appdelegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.severAvailable = YES;
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
            //NSLog(@"收到数据包传输长度:%lu",(unsigned long)packetLength);
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
    //NSLog(@"[RHSocketConnection] didWriteDataWithTag: %ld", tag);
    [_asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:tag];

}

@end
