//
//  GWImagesDecoder.h
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/22.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"
@interface GWImagesDecoder : NSObject<RHSocketDecoderProtocol>
/**
 *  应用协议中允许发送的最大数据块大小，默认为65536
 */
@property (nonatomic, assign) NSUInteger maxFrameSize;

/**
 *  包长度数据的字节个数，默认为2
 */
@property (nonatomic, assign) int countOfLengthByte;
@property (nonatomic, strong) id<RHSocketDecoderProtocol> nextEncoder;
@end
