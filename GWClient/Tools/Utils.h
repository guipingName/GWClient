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

+ (void)addDialogueBoxWithSuperView:(UIView *)superView Content:(NSString *)content;

+ (UIImage *) getImageWithImageName:(NSString *) imageName;

+ (NSUInteger) savePhotoWithImage:(UIImage *)image imageName:(NSString *) imageName;

+ (void) saveVideoWithData:(NSData *)data videoName:(NSString *) videoName;

+ (NSInteger)currentTimeStamp;

+ (NSString *)getTimeToShowWithTimestamp:(NSUInteger)timestamp;

+ (UIImage *) ImageNameWithFileType:(NSUInteger) fileType;

+ (void) showMessage:(NSString *) message superView:(UIView *) superView;

+ (void) hintMessage:(NSString *) message superView:(UIView *) superView hud:(MBProgressHUD *) hud;
@end
