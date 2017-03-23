//
//  GWImagesDecoder.m
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/22.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWImagesDecoder.h"
#import "RHSocketException.h"
#import "RHSocketUtils.h"

@implementation GWImagesDecoder

- (NSInteger)decode:(id<RHDownstreamPacket>)downstreamPacket output:(id<RHSocketDecoderOutputProtocol>)output
{
    id object = [downstreamPacket object];
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSUInteger subLen = _countOfLengthByte;
    if ([object isKindOfClass:[NSData class]]) {
        NSData *requestData = object;
        //先读区2个字节的协议长度 (前2个字节为数据包的长度)
        NSData *lenData = [requestData subdataWithRange:NSMakeRange(0, _countOfLengthByte)];
        //长度字节数据
        NSUInteger frameLen = (NSUInteger)[RHSocketUtils valueFromBytes:lenData];
        // 长度数组data
        NSData *lenArrayData = [requestData subdataWithRange:NSMakeRange(subLen, frameLen)];
        if (lenArrayData.length > 0) {
            NSMutableArray *lenArray = [NSKeyedUnarchiver unarchiveObjectWithData:lenArrayData];
            NSUInteger jsonLen = [lenArray.firstObject unsignedIntegerValue];
            subLen += frameLen;
            NSData *jsonData = [requestData subdataWithRange:NSMakeRange(subLen, jsonLen)];
            NSDictionary *headerDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            [resultDic addEntriesFromDictionary:headerDic];
            subLen += jsonLen;
            [lenArray removeObjectAtIndex:0];
            NSMutableArray *imageArray = [NSMutableArray array];
            for (NSNumber *lenNum in lenArray) {
                NSUInteger imageLen = [lenNum unsignedIntegerValue];
                NSData *imageData = [requestData subdataWithRange:NSMakeRange(subLen, imageLen)];
                UIImage *image = [UIImage imageWithData:imageData];
                [imageArray addObject:image];
                subLen+=imageLen;
            }
            [resultDic addEntriesFromDictionary:@{@"imageArray": imageArray}];
            [downstreamPacket setObject:resultDic];
        }
    }
    [output didDecode:downstreamPacket];
    return 0;

}
@end
