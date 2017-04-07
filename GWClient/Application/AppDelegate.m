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

@interface AppDelegate (){
    UserInfoModel *currentUser;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    [DataBaseManager sharedManager].currentUser = [Utils aDecoder];
    currentUser = [DataBaseManager sharedManager].currentUser;
    [TaskManager sharedManager].uploadTaskArray = [[currentUser upLoadList] mutableCopy];
    [TaskManager sharedManager].downloadTaskArray = [[currentUser downLoadList] mutableCopy];
    NSLog(@"uploadTaskArray:%lu  downloadTaskArray:%lu",(unsigned long)[TaskManager sharedManager].uploadTaskArray.count,(unsigned long)[TaskManager sharedManager].downloadTaskArray.count);
    
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
    NSLog(@"添加到数据库");
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
    NSLog(@"删除数据库");
     [currentUser deleteAllRecord];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
