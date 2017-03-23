//
//  Define.h
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#ifndef Define_h
#define Define_h


typedef NS_ENUM(NSUInteger, ApiType) {
    ApiTypeLoginApi = 11,   // 登录
    ApiTypeGetverifiyCode = 12,    // yanzheng
    ApiTypeRegister = 13,    // 注册
    ApiTypeHeadImage = 14    // 修改用户头像
};


#define USERINFOCELL        @"UserInfoTableViewCell"
#define DEFAULT_HEAD_IMAGENAME  @"bimar汉语"


#endif /* Define_h */
