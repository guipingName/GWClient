//
//  Utils.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Utils : NSObject

+ (void) aCoder:(UserInfoModel *) model;

+ (UserInfoModel *) aDecoder;

+ (UITextField *) createTextField;

// 有进度的请求
+(void)GET:(ApiType) ApiType params:(NSDictionary *)params
   succeed:(void (^)(id))success
      fail:(void (^)(NSError *))failure
compeletProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process;
// 有进度的下载
+(void)downLoad:(ApiType) ApiType params:(NSDictionary *)params
                                 succeed:(void (^)(id))success
                                    fail:(void (^)(NSError *))failure
                         downLoadProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process;

// 没有进度
+(void)GET:(ApiType) ApiType params:(NSDictionary *)params
   succeed:(void (^)(id))success
      fail:(void (^)(NSError *))failure;

+ (void)addDialogueBoxWithSuperView:(UIView *)superView Content:(NSString *)content;

+ (UIImage *) getImageWithImageName:(NSString *) imageName;

+ (NSString *) savePhotoWithImage:(UIImage *)image imageName:(NSString *) imageName;

+ (void) saveVideoWithData:(NSData *)data videoName:(NSString *) videoName;

+ (NSInteger)currentTimeStamp;

+ (NSString *)getTimeToShowWithTimestamp:(NSUInteger)timestamp;

+ (NSString *) ImageNameWithFileType:(NSUInteger) fileType;

+ (void) hintMessage:(NSString *) message time:(int)time isSuccess:(BOOL) isSuccess;

+ (void) showMessage:(NSString *) message superView:(UIView *) superView;

+ (void) hintMessage:(NSString *) message superView:(UIView *) superView hud:(MBProgressHUD *) hud;
@end
