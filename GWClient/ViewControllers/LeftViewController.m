//
//  LeftViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController (){
    UIImageView *ImvUserhead;
    UILabel *lbNickName;
}

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatViews];
    [self infomation];
    
}

- (void) infomation{
    ImvUserhead.image = [UIImage imageNamed:@"bimar模式大火"];
    lbNickName.text = @"bimar模式大火";
}

- (void) creatViews{
    ImvUserhead = [[UIImageView alloc] initWithFrame:CGRectMake((LEFTVC_WIDTH - 80) /2, 100, 80, 80)];
    [self.view addSubview:ImvUserhead];
    ImvUserhead.layer.cornerRadius = 40;
    ImvUserhead.layer.masksToBounds = YES;
    
    lbNickName = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(ImvUserhead.frame) + 10, LEFTVC_WIDTH, 30)];
    lbNickName.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbNickName];
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
