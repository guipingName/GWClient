//
//  UserLogin.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserLogin : NSObject

/**登录邮箱*/
@property (nonatomic, copy) NSString *email;

/**用户名*/
@property (nonatomic, copy) NSString *password;
@end
