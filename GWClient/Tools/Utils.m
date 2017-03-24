//
//  Utils.m
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "Utils.h"
#import "MBProgressHUD.h"

//#import "RHSocketChannel.h"
#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"
#import "RHSocketChannelProxy.h"
#import "EXTScope.h"



@implementation Utils

+(void)GET:(ApiType) ApiType params:(NSDictionary *)params succeed:(void (^)(id))success fail:(void (^)(NSError *))failure{
    NSString *host = @"10.134.20.1";
    //NSString *host = @"127.0.0.1";
    int port = 20173;
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpcForTestJsonCodec:ApiType paramDic:params succeed:^(id response) {
            success(response);
        } fail:^(NSError *error) {
            failure(error);
        }];
    }];
    
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
    
}


+ (void) sendRpcForTestJsonCodec:(ApiType) ApiType paramDic :(NSDictionary *) paramDic succeed:(void (^)(id))success fail:(void (^)(NSError *))failure{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = paramDic;
    req.pid = ApiType;
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        NSDictionary *resultDic = [response object];
        success(resultDic);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        failure(error);
    }];
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}


+(void)hintView:(UIView *)superView message:(NSString *) message{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:superView animated:YES];
    });
}



+(void)aCoder:(UserInfoModel *) model{
    NSMutableData *mData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mData];
    [archiver encodeObject:model forKey:@"userInfo"];
    [archiver finishEncoding];
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[documentsPath firstObject] stringByAppendingPathComponent:@"userInfo"];
    [mData writeToFile:dbPath atomically:YES];
}

+(UserInfoModel *)aDecoder{
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[documentsPath firstObject] stringByAppendingPathComponent:@"userInfo"];
    NSData *data = [NSData dataWithContentsOfFile:dbPath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    UserInfoModel *model = [unarchiver decodeObjectForKey:@"userInfo"];
    return model;
}

+(UITextField *)createTextField{
    UITextField *tf = [[UITextField alloc] init];
    tf.layer.borderColor = UICOLOR_RGBA(204, 204, 204, 1.0).CGColor;
    tf.layer.borderWidth= 1.0f;
    tf.layer.cornerRadius = 5.0f;
    tf.returnKeyType = UIReturnKeyDone;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    [tf setValue:UICOLOR_RGBA(128, 128, 128, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
    return tf;
}
@end
