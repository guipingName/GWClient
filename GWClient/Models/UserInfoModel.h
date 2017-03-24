//
//  UserInfoModel.h
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject<NSCoding>


/**用户Id*/
@property (nonatomic, assign) NSUInteger userId;

/**用户名*/
@property (nonatomic, copy) NSString *nickName;

/**用户头像Url*/
@property (nonatomic, copy) NSString *headImgUrl;
//@property (nonatomic, strong) UIImage *headImg;

/**年龄(默认0)*/
@property (nonatomic, assign) NSUInteger age;

/**性别(1男、2女、3未知)*/
@property (nonatomic, assign) NSUInteger sex;

/**地区*/
@property (nonatomic, copy) NSString *location;

/**个性签名(默认:您还没设置个性签名)*/
@property (nonatomic, copy) NSString *signature;



- (BOOL) updateSelfInfomation;

- (BOOL) uploadFile:(NSString *) fileName;

- (BOOL) downloadFile:(NSString *) fileName;

- (BOOL) deleteFile:(NSString *) fileName;


@end
