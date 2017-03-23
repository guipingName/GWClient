//
//  RHSocketVariableLengthDecoder.h
//  RHSocketKitDemo
//
//  Created by zhuruhong on 16/2/15.
//  Copyright © 2016年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketCodecProtocol.h"


/**
 *  可变长度编码器
 *  数据包Header为一个字典，dic[@“len”]为数据包长度，dic[@“command”]为api接口参数
 *  解码时，读取Header获取到数据包长度和api接口参数
 */
@interface RHSocketVariableLengthDecoder : NSObject <RHSocketDecoderProtocol>
@property (nonatomic, strong) id<RHSocketDecoderProtocol> nextDecoder;
@end
