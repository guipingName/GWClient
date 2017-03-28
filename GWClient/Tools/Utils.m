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
    NSString *host = HOST_IP;
    int port = HOST_PORT;
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpcForTestJsonCodec:ApiType paramDic:params succeed:success fail:failure];
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


+ (void)addDialogueBoxWithSuperView:(UIView *)superView Content:(NSString *)content{
    UILabel * label = [[UILabel alloc]init];
    label.text = content;
    label.font = [UIFont systemFontOfSize:15];
    CGRect rect = [content boundingRectWithSize:CGSizeMake(0, 0) options:1 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    label.frame = CGRectMake(15, 5, rect.size.width, rect.size.height);
    label.textColor = [UIColor whiteColor];
    UIView * view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, rect.size.width + 30, rect.size.height + 10);
    view.center = CGPointMake(KSCREEN_WIDTH / 2 , KSCREEN_HEIGHT / 2);
    view.backgroundColor = UICOLOR_RGBA(0, 0, 0,0.8);
    view.layer.cornerRadius = 8;
    [superView addSubview:view];
    [view addSubview:label];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}


+ (void) savePhotoWithImage:(UIImage *)image imageName:(NSString *) imageName{
    //先把图片转成NSData
    NSData *data  = UIImageJPEGRepresentation(image, 0.000000005);
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //拼接要存放东西的文件夹
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/EcmChatMyPic", pathDocuments];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![fileManager fileExistsAtPath:createPath]) {
        //如果没有就创建这个 想创建的文件夹
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * DocumentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/EcmChatMyPic"];
    NSString *imgFileName = [NSString stringWithFormat:@"/%@.jpg",imageName];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:imgFileName] contents:data attributes:nil];
}

+ (UIImage *) getImageWithImageName:(NSString *) imageName{
    NSString * DocumentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/EcmChatMyPic"];
    NSString *imgFileName = [NSString stringWithFormat:@"/%@.jpg",imageName];
    NSString * filePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,imgFileName];
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return img;
}


+ (NSString *)getTimeToShowWithTimestamp:(NSUInteger)timestamp {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *publishString = [formater stringFromDate:startDate];
    return publishString;
}

+ (NSString *) ImageNameWithFileType:(NSUInteger) fileType{
    NSString *str = nil;
    switch (fileType) {
        case 1:
            str = @"folder";
            break;
        case 2:
            str = @"Word";
            break;
        case 3:
            str = @"Excel";
            break;
        case 4:
            str = @"PDF";
            break;
        case 5:
            str = @"";
            break;
        case 6:
            str = @"";
        default:
            break;
    }
    return  str;
}

@end
