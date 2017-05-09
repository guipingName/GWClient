//
//  Utils.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

/**
 用户信息归档
 */
+ (void) aCoder:(UserInfoModel *) model;

/**
 用户信息解归档
 */
+ (UserInfoModel *) aDecoder;

/**
 创建UITextField
 */
+ (UITextField *) createTextField;

/**
 添加提示信息
 */
+ (void)addDialogueBoxWithSuperView:(UIView *)superView Content:(NSString *)content;

/**
 从沙盒中获取图片
 */
+ (UIImage *) getImageWithImageName:(NSString *) imageName;

/**
 保存文件(图片、视频)到沙盒
 */
+ (NSUInteger) saveFileWithData:(NSData *)data fileName:(NSString *) fileName isPicture:(BOOL) isPicture;

/**
 压缩图片到指定大小
 */
+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

/**
 获取当前时间1970
 */
+ (NSInteger)currentTimeStamp;

/**
 时间戳转时间
 */
+ (NSString *)getTimeToShowWithTimestamp:(NSUInteger)timestamp;

/**
 根据文件类型获取图片
 */
+ (UIImage *) ImageNameWithFileType:(NSUInteger) fileType;

/**
 弹框提示跳转到登录界面
 */
+ (void) quitToLoginViewControllerFrom:(UIViewController *) viewController;
@end
