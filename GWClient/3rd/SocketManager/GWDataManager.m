//
//  GWDataManager.m
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import "GWDataManager.h"
#import "GWVariableDecoder.h"
#import "GWVariableEncoder.h"
#import "GWSocketPacketContext.h"
#import "Define.h"
#import "SocketManager.h"

@interface GWDataManager()<GWSocketEncoderOutputProtocol, GWSocketDecoderOutputProtocol>

@property (nonatomic, strong) id<GWSocketEncoderProtocol> encoder;
@property (nonatomic, strong) id<GWSocketDecoderProtocol> decoder;
@property (nonatomic, strong)  GWSocketPacketRequest *requst;
@property (nonatomic, copy) void (^success)(id successObject);
@property (nonatomic, copy) void (^error)(NSError *error);

@end

@implementation GWDataManager


+(instancetype) sharedInstance
{
    static GWDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GWDataManager new];
    });
    return manager;
}
#pragma mark - 网络请求


-(void)GET:(ApiType)ApiType params:(NSDictionary *)params succeed:(void (^)(id))success fail:(void (^)(NSError *))failure{
    [[SocketManager sharedInstance] connectWithHost:HOST_IP onPort:HOST_PORT success:^(BOOL connectSuccess) {
        GWSocketPacketRequest *request = [[GWSocketPacketRequest alloc] init];
        request.pid = ApiType;
        request.object = params;
        self.success = success;
        self.error = failure;
        [self.encoder encode:request output:self];
    } backError:^(NSError *error) {
        NSLog(@"error.localizedDescription: %@", error.localizedDescription);
        failure(error);
    }];
}


#pragma mark - GWSocketEncoderOutputProtocol
// 编码后输出结果
- (void)didEncode:(NSData *)data timeout:(NSTimeInterval)timeout
{
//    NSLog(@"打包后的data长度:%d",data.length);
    if (data.length > 0) {
        self.requestData(data);
    }
}

#pragma mark - GWSocketDecoderOutputProtocol
// 解析后的数据
- (void)didDecode:(id<GWResponesPacket>)decodedPacket
{
    if (self.success) {
        self.success(decodedPacket.object);
//        [[SocketManager sharedInstance] disConnect];
    }
//    NSLog(@"返回数据: %@", decodedPacket.object);
}
#pragma mark - 解析返回数据

- (void)setResponse:(NSDictionary *)response
{
    NSData *requestData = [response valueForKey:@"data"];
    NSMutableData *receiveDataBuffer = [NSMutableData new];
    [receiveDataBuffer appendData:requestData];
    GWSocketPacketResponse *decoderResponse = [GWSocketPacketResponse new];
    decoderResponse.object = receiveDataBuffer;
    decoderResponse.pid = [[response valueForKey:@"command"] integerValue];
    [self.decoder decode:decoderResponse output:self];
}

#pragma mark - 懒加载

- (id<GWSocketEncoderProtocol>)encoder
{
    if (!_encoder) {
        _encoder = [[GWVariableEncoder alloc] init];
    }
    return _encoder;
}


- (id<GWSocketDecoderProtocol>)decoder
{
    if (!_decoder) {
        _decoder = [[GWVariableDecoder alloc] init];
    }
    return _decoder;
}

@end
