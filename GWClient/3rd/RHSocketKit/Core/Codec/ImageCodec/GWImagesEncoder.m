//
//  GWImagesEncoder.m
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/22.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import "GWImagesEncoder.h"
#import "RHSocketException.h"
#import <UIKit/UIKit.h>
#import "RHSocketUtils.h"
#define imagesKey @"imageArray"

@implementation GWImagesEncoder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _countOfLengthByte = 2;
    }
    return self;
}

- (void)encode:(id<RHUpstreamPacket>)upstreamPacket output:(id<RHSocketEncoderOutputProtocol>)output
{
    NSMutableData *sendData = [NSMutableData new];
    NSMutableData *dataObject = [NSMutableData new];
    id object = upstreamPacket.object;
    // 储存数据长度
    NSMutableArray *lenArray = [NSMutableArray array];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *objectDic = [NSMutableDictionary dictionaryWithDictionary:object];
        NSArray *images = [objectDic valueForKey:imagesKey];
        [objectDic removeObjectForKey:imagesKey];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objectDic options:NSJSONWritingPrettyPrinted error:nil];
        [dataObject appendData:jsonData];
        
        [lenArray addObject:[NSNumber numberWithUnsignedInteger:dataObject.length]];
        for (UIImage *image in images) {
            NSData *imageData = UIImagePNGRepresentation(image);
            [lenArray addObject:[NSNumber numberWithUnsignedInteger:imageData.length]];
            [dataObject appendData:imageData];
        }
        NSData *lenData = [NSKeyedArchiver archivedDataWithRootObject:lenArray];
        // header长度data
        NSData *headerLenData = [RHSocketUtils bytesFromValue:lenData.length byteCount:_countOfLengthByte];
        [sendData appendData:headerLenData];
        [sendData appendData:lenData];
        [sendData appendData:dataObject];
        if (self.nextEncoder) {
            [upstreamPacket setObject:sendData];
            [_nextEncoder encode:upstreamPacket output:output];
            return;
        }
    } else {
        [RHSocketException raiseWithReason:[NSString stringWithFormat:@"%@ Error !", [self class]]];
    }
    
}
@end
