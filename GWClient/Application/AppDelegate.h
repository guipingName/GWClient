//
//  AppDelegate.h
//  GWClient
//
//  Created by guiping on 17/3/16.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NetStatus) {
    NetStatussNone = 0,     // 无网络
    NetStatusViaWWAN = 1,   // 移动蜂窝网络
    NetStatusViaWiFi = 2,   // Wi-Fi
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, assign)NetStatus netState;

@property(nonatomic, assign)BOOL severAvailable;

@end

