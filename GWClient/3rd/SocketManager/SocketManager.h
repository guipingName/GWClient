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
- (void)connectWithHost:(NSString *)host
                 onPort:(uint16_t )port
                success:(void (^) (BOOL connectSuccess)) connectSucees
        compeletProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process
              backError:(void (^) (NSError *error)) backError;
- (void)connectWithHost:(NSString *)host
                 onPort:(uint16_t )port
                success:(void (^) (BOOL connectSuccess)) connectSucees
        downLoadProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process
              backError:(void (^) (NSError *error)) backError;

-(void) disconnected;
@end
