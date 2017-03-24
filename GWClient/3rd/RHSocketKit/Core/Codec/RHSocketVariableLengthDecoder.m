//
//  RHSocketVariableLengthDecoder.m
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import "RHSocketVariableLengthDecoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"
#import "RHSocketPacketContext.h"

@interface RHSocketVariableLengthDecoder()
@property(nonatomic, assign) int requestCommandLength;
@end
@implementation RHSocketVariableLengthDecoder

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:downstreamPacket.object];
    //去除数据长度后的数据内容
    RHSocketPacketRequest *ctx = [[RHSocketPacketRequest alloc] init];
    ctx.pid = downstreamPacket.pid;
    ctx.object = dic;
    [output didDecode:ctx];
    return 1;
}

@end
