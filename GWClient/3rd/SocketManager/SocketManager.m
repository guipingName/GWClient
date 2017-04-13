//
//  SocketManager.m
//  GWClient
//
//  Created by wenrong on 2017/4/6.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "SocketManager.h"
#import "GWDataManager.h"
#import "AppDelegate.h"

#define READ_HEAD_TIMEOUT -1
#define READ_TIMEOUT -1
#define WRITE_TIMEOUT -1
#define HEAD_TAG 0
#define CONTENT_TAG 1
#define RESPONSE_TIME 15

#define NORMALIDENTFY @"normalSocket"
#define UPIENTFY @"upSocket"
#define DOWNIDENTFY @"downSocket"

#define HOST @"192.168.0.1"
#define PORT 20173

@interface SocketManager()<GCDAsyncSocketDelegate>

{
    NSData *backData;
    NSMutableDictionary *headsDic;
    
}
@property(nonatomic, strong) GCDAsyncSocket *gcdSocket;
@property(nonatomic, strong) GCDAsyncSocket *upSocket;
@property(nonatomic, strong) GCDAsyncSocket *downSocket;

@property(nonatomic, copy) void (^connectSuccess)(BOOL isConnect);
@property(nonatomic, copy) void (^netError)(NSError *error);
@property(nonatomic, strong)NSTimer *upTimer;
@property(nonatomic, strong)NSTimer *downTimer;
/**
 进度百分比
 */
@property(nonatomic, copy)void (^processBlock)(NSInteger done, NSInteger total, float percentage);

@property(nonatomic, copy)void (^downProcessBlock)(NSInteger done, NSInteger total, float percentage);

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        headsDic = [NSMutableDictionary dictionary];
    }
    return self;
}
#pragma mark - GCDAsyncSocketDelegate
// 上传
- (void)connectWithHost:(NSString *)host
                 onPort:(uint16_t )port
                success:(void (^) (BOOL connectSuccess)) connectSucees
              backError:(void (^) (NSError *error)) backError
{
    if (_gcdSocket) {
        [_gcdSocket disconnect];
        [_gcdSocket setDelegate:nil];
        _gcdSocket = nil;
    }
    NSError *error = nil;
    self.connectSuccess = connectSucees;
    self.netError = backError;
    //[self.gcdSocket connectToHost:host onPort:port error:&error];
    [self.gcdSocket connectToHost:host onPort:port withTimeout:RESPONSE_TIME error:&error];
}

// 有进度的上传
- (void)connectWithHost:(NSString *)host onPort:(uint16_t)port success:(void (^)(BOOL))connectSucees compeletProcess:(void (^)(NSInteger, NSInteger, float))process backError:(void (^)(NSError *))backError
{
    if (_upSocket) {
        [_upSocket disconnect];
        [_upSocket setDelegate:nil];
        _upSocket = nil;
    }
    NSError *error = nil;
    self.connectSuccess = connectSucees;
    self.netError = backError;
    [self.upSocket connectToHost:host onPort:port error:&error];
    self.processBlock = process;
    dispatch_async(dispatch_get_main_queue(), ^{
        _upTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(calculateProcess:) userInfo:nil repeats:YES];
    });
}

// 有进度的下载
- (void)connectWithHost:(NSString *)host onPort:(uint16_t)port success:(void (^)(BOOL))connectSucees downLoadProcess:(void (^)(NSInteger, NSInteger, float))process backError:(void (^)(NSError *))backError
{
    if (_downSocket) {
        [_downSocket disconnect];
        [_downSocket setDelegate:nil];
        _downSocket = nil;
    }
    NSError *error = nil;
    self.connectSuccess = connectSucees;
    self.netError = backError;
    [self.downSocket connectToHost:host onPort:port error:&error];
    self.downProcessBlock = process;
    dispatch_async(dispatch_get_main_queue(), ^{
        _downTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(calculateDownProcess:) userInfo:nil repeats:YES];
    });
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket连接成功");
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.severAvailable = YES;
    [[GWDataManager sharedInstance] setRequestData:^(NSData *request, NSTimeInterval timeOut) {
        //NSLog(@"上传数据长度:%lu", (unsigned long)request.length);
        [sock writeData:request withTimeout:timeOut tag:HEAD_TAG];
    }];
    self.connectSuccess(YES);
}

-(void)disconnected{
    [_gcdSocket disconnect];
    [_upSocket disconnect];
    [_downSocket disconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //NSString *host = sock.connectedHost;
    uint16_t port = sock.connectedPort;
    //NSLog(@"读取数据的socket:  Host = %@, Port = %hu",host, port);
    if (tag == HEAD_TAG) {
        //NSLog(@"头部tag:%ld",tag);
        NSDictionary *currentPacketHead = [NSJSONSerialization
                                           JSONObjectWithData:data
                                           options:NSJSONReadingMutableContainers
                                           error:nil];
        if (!currentPacketHead) {
            NSLog(@"error：当前数据包的头为空");
            return;
        }
        [headsDic setObject:currentPacketHead forKey:sock.userData];
        NSUInteger packetLength = [currentPacketHead[@"len"] integerValue];
        if ([sock.userData isEqualToString:UPIENTFY] || [sock.userData isEqualToString:DOWNIDENTFY]) {
            [sock readDataToLength:packetLength withTimeout:READ_TIMEOUT tag:CONTENT_TAG];
        }
        else{
            [sock readDataToLength:packetLength withTimeout:RESPONSE_TIME tag:CONTENT_TAG];
        }
        
    } else {
        //NSLog(@"内容tag:%ld, 数据长度%lu",tag, (unsigned long)data.length);
        if ([sock.userData isEqualToString:DOWNIDENTFY]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.downProcessBlock) {
                    self.downProcessBlock(0, 0, 1.0);
                }
                [self stopTimer:_downTimer];
            });
        }
        NSNumber *reqestCommand = [headsDic valueForKey:sock.userData][@"command"];
        [headsDic removeObjectForKey:[NSString stringWithFormat:@"%d", port]];
        // 处理客户端请求
        [GWDataManager sharedInstance].response = @{@"data":data,
                                                    @"command":reqestCommand
                                                    };
    }
}

#pragma mark - 返回数据重载函数
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //NSLog(@"userData: %@", sock.userData);
    if ([sock.userData isEqualToString:UPIENTFY]) {
        [self stopTimer:_upTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.processBlock) {
                self.processBlock(0, 0, 1.0);
            }
        });
    }
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:HEAD_TAG];
}

// 进度显示timer方法
- (void)calculateProcess:(NSTimer *) sender
{
    long tag = 0;
    NSUInteger done = 0;
    NSUInteger total = 0;
    float asign = [self.upSocket progressOfWriteReturningTag:&tag bytesDone:&done total:&total];
    if (self.processBlock) {
        self.processBlock(done,total,asign);
    }
}
- (void)calculateDownProcess:(NSTimer *) sender
{
    long tag = 0;
    NSUInteger doweDone = 0;
    NSUInteger downToal = 0;
    float downAsign = [self.downSocket progressOfReadReturningTag:&tag bytesDone:&doweDone total:&downToal];
    if (self.downProcessBlock) {
        self.downProcessBlock(doweDone,downToal,downAsign);
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

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if (elapsed <= WRITE_TIMEOUT) {
        return 0.0;
    }
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"-------------断开连接,error.localizedDescription:%@",err.localizedDescription);
    if (err.localizedDescription) {
        if (err.code == SOCKET_CLOSED) {
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.severAvailable = NO;
        }
        self.netError(err);
        [self stopTimer:_downTimer];
        [self stopTimer:_upTimer];
    }
}

- (void)stopTimer:(NSTimer *) sender
{
    if ([sender isValid]) {
        [sender invalidate];
        sender = nil;
    }
}
#pragma mark - 懒加载
- (GCDAsyncSocket *)gcdSocket
{
    if (!_gcdSocket) {
        _gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
        _gcdSocket.userData = NORMALIDENTFY;
    }
    return _gcdSocket;
}

- (GCDAsyncSocket *)upSocket
{
    if (!_upSocket) {
        _upSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
        _upSocket.userData = UPIENTFY;
    }
    return _upSocket;
}

- (GCDAsyncSocket *)downSocket
{
    if (!_downSocket) {
        _downSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];
        _downSocket.userData = DOWNIDENTFY;
    }
    return _downSocket;
}

@end
