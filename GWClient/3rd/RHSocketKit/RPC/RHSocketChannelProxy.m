//
//  RHSocketChannelProxy.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 15/12/21.
//  Copyright © 2015年 zhuruhong. All rights reserved.
//

#import "RHSocketChannelProxy.h"
#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"

@implementation RHSocketChannelProxy

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _callReplyManager = [[RHSocketCallReplyManager alloc] init];
        _encoder = [[RHSocketVariableLengthEncoder alloc] init];
        _decoder = [[RHSocketVariableLengthDecoder alloc] init];
        
    }
    return self;
}


- (void)asyncConnect:(RHConnectCallReply *)aCallReply
{
    _connectCallReply = aCallReply;
    [self openConnection];
}

- (void)disconnect
{
    [self closeConnection];
}

- (void)asyncCallReply:(id<RHSocketCallReplyProtocol>)aCallReply
       compeletProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process
{
    if (![_channel isConnected]) {
        NSDictionary *userInfo = @{@"msg":@"Socket channel is not connected."};
        NSError *error = [NSError errorWithDomain:@"RHSocketChannelProxy" code:-1 userInfo:userInfo];
        [aCallReply onFailure:aCallReply error:error];
        return;
    }//if
    [_callReplyManager addCallReply:aCallReply];
    [_channel asyncSendPacket:[aCallReply request] compeletProcess:process];
    
}
- (void)asyncCallReply:(id<RHSocketCallReplyProtocol>)aCallReply
           downProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process
{
    if (![_channel isConnected]) {
        NSDictionary *userInfo = @{@"msg":@"Socket channel is not connected."};
        NSError *error = [NSError errorWithDomain:@"RHSocketChannelProxy" code:-1 userInfo:userInfo];
        [aCallReply onFailure:aCallReply error:error];
        return;
    }//if
    [_callReplyManager addCallReply:aCallReply];
    
    [_channel asyncSendPacket:[aCallReply request] downLoadProcess:process];
}
#pragma mark - RHSocketChannel

- (void)openConnection
{
    [self closeConnection];
    _channel = [[RHSocketChannel alloc] initWithHost:_connectCallReply.host port:_connectCallReply.port];
    _channel.delegate = self;
    _channel.encoder = _encoder;
    _channel.decoder = _decoder;
    [_channel openConnection];
}

- (void)closeConnection
{
    if (_channel) {
        [_channel closeConnection];
        _channel.delegate = nil;
        _channel = nil;
    }
}

#pragma mark - RHSocketChannelDelegate

- (void)channelOpened:(RHSocketChannel *)channel host:(NSString *)host port:(int)port
{
    [_connectCallReply onSuccess:_connectCallReply response:nil];
}

- (void)channelClosed:(RHSocketChannel *)channel error:(NSError *)error
{
    [_callReplyManager removeAllCallReply];
    [_connectCallReply onFailure:_connectCallReply error:error];
}

- (void)channel:(RHSocketChannel *)channel received:(id<RHDownstreamPacket>)packet
{
    //结合命令编码解码器，解析命令字段。对callreply协议，从packet中解析出callreplyid。然后从_callReplyManager中获得replay指针处理回调。
    NSInteger callReplyId = [packet pid];
    id<RHSocketCallReplyProtocol> tempCallReply = [_callReplyManager getCallReplyWithId:callReplyId];
    [_callReplyManager removeCallReplyWithId:callReplyId];
    [tempCallReply onSuccess:tempCallReply response:packet];
}

@end
