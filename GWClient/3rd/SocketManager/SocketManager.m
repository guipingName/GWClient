//
//  SocketManager.m
//  GWClient
//
//  Created by wenrong on 2017/4/6.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "SocketManager.h"
#import "GWDataManager.h"

#define READ_HEAD_TIMEOUT -1
#define READ_TIMEOUT -1
#define WRITE_TIMEOUT -1
#define SEND_TAG 0


#define HOST @"192.168.0.1"
#define PORT 20173

@interface SocketManager()<GCDAsyncSocketDelegate>

{
    NSData *backData;
    NSInteger reqestCommand;
    NSDictionary *currentPacketHead;
    
}
@property(nonatomic, strong) GCDAsyncSocket *gcdSocket;
@property(nonatomic, copy) void (^connectSuccess)(BOOL isConnect);
@property(nonatomic, copy) void (^netError)(NSError *error);
@property(nonatomic, strong)NSTimer *upTimer;
@property(nonatomic, strong)NSTimer *downTimer;

@end

@implementation SocketManager

+ (instancetype)sharedInstance
{
    static SocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SocketManager alloc] init];
    });
    return manager;
}
- (void)disConnect
{
    [_gcdSocket disconnect];
    [_gcdSocket setDelegate:nil];
    _gcdSocket = nil;
    NSLog(@"服务器关闭，断开连接");
}
#pragma mark - GCDAsyncSocketDelegate

- (void)connectWithHost:(NSString *)host
                 onPort:(uint16_t )port
                success:(void (^) (BOOL connectSuccess)) connectSucees
              backError:(void (^) (NSError *error)) backError
{
    if ([self.gcdSocket isConnected]) {
        [self disConnect];
    }
    NSError *error = nil;
    self.connectSuccess = connectSucees;
    self.netError = backError;
    [self.gcdSocket connectToHost:host onPort:port error:&error];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket连接成功");
    [[GWDataManager sharedInstance] setRequestData:^(NSData *request) {
        [sock writeData:request withTimeout:WRITE_TIMEOUT tag:SEND_TAG];
    }];
    self.connectSuccess(YES);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
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
        
        //        NSLog(@"收到数据包传输长度:%lu",(unsigned long)packetLength);
        [sock readDataToLength:packetLength withTimeout:READ_TIMEOUT tag:SEND_TAG];
        return;
    }
    [GWDataManager sharedInstance].response = @{@"data":data,
                                                @"command":[NSNumber numberWithInteger:reqestCommand]
                                                };
    currentPacketHead = nil;
}

#pragma mark - 返回数据重载函数
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _upTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(calculateProcess:) userInfo:@(tag) repeats:YES];
        _downTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(calculateDownProcess:) userInfo:@(tag) repeats:YES];
    });

     [self.gcdSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:SEND_TAG];
}
// 进度显示timer方法
- (void)calculateProcess:(NSTimer *) sender
{
    long tag = [sender.userInfo integerValue];
    NSUInteger done = 0;
    NSUInteger total = 0;
    float asign = [self.gcdSocket progressOfWriteReturningTag:&tag bytesDone:&done total:&total];
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
    float downAsign = [self.gcdSocket progressOfReadReturningTag:&tag bytesDone:&doweDone total:&downToal];
    if (self.downProcessBlock) {
        self.downProcessBlock(doweDone,downToal,downAsign);
    }
    if (isnan(downAsign) || (downAsign == 1.0)) {
        [sender invalidate];
        sender = nil;
        return;
    }
}


#pragma mark - 即将关闭函数


- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT) {
        return 0.0;
    }
    return 0.0;
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"-------------断开连接,%@",err.localizedDescription);
    if (err.localizedDescription) {
        self.netError(err);
    }
}

#pragma mark - 懒加载
- (GCDAsyncSocket *)gcdSocket
{
    if (!_gcdSocket) {
        _gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
    }
    return _gcdSocket;
}

@end
