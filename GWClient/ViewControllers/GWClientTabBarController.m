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
    
    [UITabBar appearance].barTintColor = THEME_COLOR;
    self.tabBar.translucent = NO;
    
    DocViewController *docVC = [[DocViewController alloc] init];
    TransferListViewController *transferVC = [[TransferListViewController alloc] init];
    NewsViewController *newsVC= [[NewsViewController alloc] init];
    
    self.viewControllers = @[[self addNavigationItemForViewController:docVC],[self addNavigationItemForViewController:transferVC],[self addNavigationItemForViewController:newsVC]];
    
    NSArray *titles = @[@"网盘", @"传输列表", @"资讯"];
    NSArray *images = @[@"bimarBtn定时", @"bimarBtn模式", @"bimarBtn风速"];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitle:titles[idx]];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blueColor]} forState:UIControlStateNormal];
        item.image = [[[UIImage imageNamed:images[idx]] rt_tintedImageWithColor:[UIColor blueColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor greenColor]} forState:UIControlStateSelected];
        item.selectedImage = [[[UIImage imageNamed:images[idx]] rt_tintedImageWithColor:[UIColor greenColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }];
    self.selectedIndex = 0;
}

- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
//    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                                                                     target:self
//                                                                                                     action:@selector(pushSearchViewController)];
//    
    
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
