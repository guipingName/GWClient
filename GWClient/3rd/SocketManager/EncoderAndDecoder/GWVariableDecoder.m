//
//  GWVariableDecoder.m
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import "GWVariableDecoder.h"
#import "GWSocketPacketContext.h"

@implementation GWVariableDecoder


- (NSInteger)decode:(id<GWResponesPacket>)responseStreamPacket output:(id<GWSocketDecoderOutputProtocol>)output
{
    id object = [responseStreamPacket object];
    NSData *data = nil;
    if (![object isKindOfClass:[NSData class]]) {
        return -1;
    } else {
        data = object;
    }
    NSDictionary *requestDic = [NSKeyedUnarchiver unarchiveObjectWithData:object];
    //去除数据长度后的数据内容
    GWSocketPacketResponse *ctx = [[GWSocketPacketResponse alloc] init];
    ctx.pid = responseStreamPacket.pid;
    ctx.object = requestDic;
    // 输出结果
    [output didDecode:ctx];
    return data.length;
}

@end
