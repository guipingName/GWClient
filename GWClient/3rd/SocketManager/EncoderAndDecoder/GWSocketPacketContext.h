//
//  GWSocketPacketContext.h
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWSocketPacket.h"
@interface GWSocketPacketContext : NSObject


@end

/**
 请求Model
 */
@interface GWSocketPacketRequest : NSObject<GWRequestPacket>

// 获取请求参数userId
- (NSInteger)userId;
// 获取请求参数token
- (NSString *)token;
// 获取请求参数包
- (NSDictionary *) dic;

@end


/**
 返回Model
 */
@interface GWSocketPacketResponse : NSObject<GWResponesPacket>

@end
