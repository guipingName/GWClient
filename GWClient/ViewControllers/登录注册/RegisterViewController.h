//
//  RegisterViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserLogin;
@interface RegisterViewController : UIViewController

@property (nonatomic, copy) void(^loginBlock)(UserLogin *);

@end
