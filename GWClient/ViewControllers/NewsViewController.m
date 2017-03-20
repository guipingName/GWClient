//
//  NewsViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bimar模式小火"] style:UIBarButtonItemStylePlain target:self action:@selector(doLogin)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void) doLogin{
    NSLog(@"333");
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
