//
//  GWSocketPacketContext.m
//  GWDataManagerServer
//
//  Created by wenrong on 2017/3/20.
//  Copyright © 2017年 wenrong. All rights reserved.
//

#import "GWSocketPacketContext.h"

@implementation GWSocketPacketContext

@end

@implementation GWSocketPacketRequest

@synthesize pid;
@synthesize object;
@synthesize timeout = _timeout;

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}

- (NSInteger)userId
{
    NSDictionary *dic = object;
    return [dic[@"userId"] integerValue];
}
- (NSString *)token
{
    NSDictionary *dic = object;
    return [dic[@"token"] stringValue];
}
- (NSDictionary *) dic
{
    return (NSDictionary *)object;
}
@end

@implementation GWSocketPacketResponse

@synthesize pid;
@synthesize object;
@synthesize timeout = _timeout;

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = -1;
    }
    return self;
}
@end
