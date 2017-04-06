//
//  AppDelegate.m
//  GWClient
//
//  Created by guiping on 17/3/16.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MMDrawerController.h"
#import "LeftViewController.h"
#import "GWClientTabBarController.h"
#import "GPNetWorkManager.h"
#import "TaskManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [DataBaseManager sharedManager].currentUser = [Utils aDecoder];
    UserInfoModel *user = [DataBaseManager sharedManager].currentUser;
    [TaskManager sharedManager].uploadTaskArray = [[user upLoadList] mutableCopy];
    [TaskManager sharedManager].downloadTaskArray = [[user downLoadList] mutableCopy];
    [user deleteAllRecord];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if ([userDef boolForKey:IS_HAS_LOGIN]) {
        LeftViewController *leftVC = [[LeftViewController alloc] init];
        MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:[[GWClientTabBarController alloc] init] leftDrawerViewController:leftVC];
        
        [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        [drawerController setMaximumLeftDrawerWidth:LEFTVC_WIDTH];
        _window.rootViewController = drawerController;
    }
    else{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = nav;
    }
    
    [self getNetworkStatus];
    return YES;
}


- (void) getNetworkStatus{
    GPNetWorkManager *manager = [GPNetWorkManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(HSReachabilityStatus status) {
        switch (status) {
            case HSReachabilityStatusNotReachable:
                [Utils addDialogueBoxWithSuperView:_window Content:@"未连接网络"];
                _netState = NetStatussNone;
                break;
            case HSReachabilityStatusReachableViaWWAN:
                [Utils addDialogueBoxWithSuperView:_window Content:@"蜂窝移动网络"];
                _netState = NetStatusViaWWAN;
                break;
            case HSReachabilityStatusReachableViaWiFi:
                [Utils addDialogueBoxWithSuperView:_window Content:@"Wi-Fi"];
                _netState = NetStatusViaWiFi;
                [[TaskManager sharedManager] reUpload];
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    UserInfoModel *user = [DataBaseManager sharedManager].currentUser;
    NSArray *upArray = [TaskManager sharedManager].uploadTaskArray;
    for (FileModel *model in upArray) {
        [user uploadFile:model];
    }
    NSArray *downArray = [TaskManager sharedManager].downloadTaskArray;
    for (FileModel *model in downArray) {
        [user downloadFile:model];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
