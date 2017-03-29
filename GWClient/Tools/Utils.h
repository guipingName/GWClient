//
//  Utils.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (void) aCoder:(UserInfoModel *) model;

+ (UserInfoModel *) aDecoder;

+ (UITextField *) createTextField;

+(void)hintView:(UIView *)superView message:(NSString *) message;

// 有进度的请求
+(void)GET:(ApiType) ApiType params:(NSDictionary *)params
   succeed:(void (^)(id))success
      fail:(void (^)(NSError *))failure
compeletProcess:(void (^)(NSInteger done, NSInteger total, float percentage)) process;

// 没有进度
+(void)GET:(ApiType) ApiType params:(NSDictionary *)params
   succeed:(void (^)(id))success
      fail:(void (^)(NSError *))failure;

+ (void)addDialogueBoxWithSuperView:(UIView *)superView Content:(NSString *)content;

+ (UIImage *) getImageWithImageName:(NSString *) imageName;

+ (void) savePhotoWithImage:(UIImage *)image imageName:(NSString *) imageName;

+ (NSInteger)currentTimeStamp;

+ (NSString *)getTimeToShowWithTimestamp:(NSUInteger)timestamp;

+ (NSString *) ImageNameWithFileType:(NSUInteger) fileType;

@end
