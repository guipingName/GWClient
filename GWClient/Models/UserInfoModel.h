//
//  UserInfoModel.h
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject

/**用户名*/
@property (nonatomic, copy) NSString *nickName;

/**用户头像Url*/
@property (nonatomic, copy) NSString *headImgUrl;

/**年龄(默认0)*/
@property (nonatomic, assign) NSUInteger age;

/**性别(1男、2女、3未知)*/
@property (nonatomic, assign) NSUInteger sex;

/**个性签名(默认:您还没设置个性签名)*/
@property (nonatomic, copy) NSString *signature;

@end
