//
//  GWClientTabBarController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "GWClientTabBarController.h"
#import "DocViewController.h"
#import "TransferListViewController.h"
#import "NewsViewController.h"

@interface GWClientTabBarController ()

@end

@implementation GWClientTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UITabBar appearance].barTintColor = [UIColor grayColor];
    self.tabBar.translucent = NO;
    
    DocViewController *docVC = [[DocViewController alloc] init];
    TransferListViewController *transferVC = [[TransferListViewController alloc] init];
    NewsViewController *newsVC= [[NewsViewController alloc] init];
    
    self.viewControllers = @[[self addNavigationItemForViewController:docVC],[self addNavigationItemForViewController:transferVC],[self addNavigationItemForViewController:newsVC]];
    NSArray *titles = @[@"网盘", @"传输列表", @"资讯"];
    NSArray *images = @[@"tabbar_me", @"arrow_up_down", @"tabbar_discover"];
    UIColor *normalColor = [UIColor whiteColor];
    UIColor *selectedColor = THEME_COLOR;
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitle:titles[idx]];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: normalColor} forState:UIControlStateNormal];
        item.image = [[[UIImage imageNamed:images[idx]] rt_tintedImageWithColor:normalColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: selectedColor} forState:UIControlStateSelected];
        item.selectedImage = [[[UIImage imageNamed:images[idx]] rt_tintedImageWithColor:selectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    //self.selectedIndex = 0;
}


- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    return navigationController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
