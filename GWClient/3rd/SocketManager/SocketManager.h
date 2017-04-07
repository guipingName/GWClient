//
//  SocketManager.h
//  GWClient
//
//  Created by wenrong on 2017/4/6.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>

@interface SocketManager : NSObject

+ (instancetype) sharedInstance;

- (void)connectWithHost:(NSString *)host
                 onPort:(uint16_t )port
                success:(void (^) (BOOL connectSuccess)) connectSucees
              backError:(void (^) (NSError *error)) backError;
/**
 进度百分比
 */
@property(nonatomic, copy)void (^processBlock)(NSInteger done, NSInteger total, float percentage);

@property(nonatomic, copy)void (^downProcessBlock)(NSInteger done, NSInteger total, float percentage);
@end
