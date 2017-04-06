//
//  GWVariableDecoder.h
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWSocketCodecProtocol.h"

/**
 *  可变长度编码器
 *  数据包Header为一个字典，dic[@“len”]为数据包长度，dic[@“command”]为api接口参数
 *  解码时，读取Header获取到数据包长度和api接口参数
 */
@interface GWVariableDecoder : NSObject<GWSocketDecoderProtocol>

@end
