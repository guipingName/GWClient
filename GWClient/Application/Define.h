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
    ApiTypeLogin = 11,                  // 登录
    ApiTypeGetverifiyCode = 12,         // 获取验证码
    ApiTypeRegister = 13,               // 注册
    ApiTypeUpFile = 14,                 // 上传文件
    ApiTypeGetFile = 15,                // 获取文件
    ApiTypeModifyUserInfo = 16,         // 修改用户信息
    ApiTypeGetUserFileList = 17,        // 获取用户文件列表
    ApiTypeDeleteFiles = 18,            // 删除文件
    ApiTypeGetNewsList = 19             // 获取新闻列表
};


#define UICOLOR_RGBA(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define THEME_COLOR                        UICOLOR_RGBA(250, 126, 20, 1.0);
#define BTN_ENABLED_BGCOLOR                UICOLOR_RGBA(130, 131, 130, 1.0);

#define DEFAULT_HEAD_IMAGENAME      @"head"
#define NAVIGATION_LEFTBAR          @"navigationbar_list_normal"
#define IS_HAS_LOGIN                @"isHasLogin"

#define HOST_IP                     @"10.134.42.1"
#define HOST_PORT                   20173
#define BTN_NEW_TAG                 800
#define NO_NETWORK                  57
#define CONNECTION_REFUSED          61
#define SOCKET_CLOSED               7

#define LEFTVC_WIDTH               KSCREEN_WIDTH * 2 / 3

#define TRANSFERLISTCELL            @"transferListTableViewCell"
#define SETTING_CELL                @"settingcell"
#define FILELISTCELL                @"FileListTableViewCell"
#define LEFTCELL                    @"LeftVCTableViewCell"
#define USERINFOCELL                @"UserInfoTableViewCell"
#define NEWSCELL                    @"NewsTableViewCell"

#define CONNECTION_REFUSED_STR      @"服务器已断开"
#define NO_NETWORK_STR              @"网络断开"
#define GET_ERROR                   @"获取失败"
#define PREVIEW_ERROR               @"查看失败"
#define LOGIN_ERROR                 @"非法登录"
#define SERVER_DISCONNECT           @"服务器已断开，请稍后再试"
#define LOAD_ERROR                  @"加载失败，点击再试一次"
#define DELETE_ERROR                @"删除失败"
#define EMPTY                       @"这里是空的~"




#ifndef W_H_
#define W_H_
#define KSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define Request [GWDataManager sharedInstance]
#endif

#define LABEL_RECT(labelText,limitW,limitH,option,font) [labelText boundingRectWithSize:CGSizeMake(limitW, limitH) options:option attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil]

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s: %d \t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif


#endif /* Define_h */
