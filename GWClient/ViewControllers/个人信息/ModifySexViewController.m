//
//  ModifySexViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/27.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ModifySexViewController.h"
#import "SexButton.h"

@interface ModifySexViewController (){
    UIButton *btnMan;
    UIButton *btnWoman;
    NSString *sex;
}

@end

@implementation ModifySexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"性别";
    self.view.backgroundColor = [UIColor whiteColor];
    
    btnMan = [SexButton buttonWithType:UIButtonTypeCustom];
    btnMan.frame = CGRectMake(0, 64, KSCREEN_WIDTH, 40);
    [btnMan setImage:[UIImage imageNamed:@"sex_sel"] forState:UIControlStateSelected];
    [btnMan addTarget:self action:@selector(btnManClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnMan.backgroundColor = [UIColor whiteColor];
    [btnMan setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnMan setTitle:@"男" forState:UIControlStateNormal];
    [self.view addSubview:btnMan];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 104, KSCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [self.view addSubview:line];
    
    btnWoman = [SexButton buttonWithType:UIButtonTypeCustom];
    btnWoman.frame = CGRectMake(0, 105, KSCREEN_WIDTH, 40);
    [btnWoman setImage:[UIImage imageNamed:@"sex_sel"] forState:UIControlStateSelected];
    [btnWoman addTarget:self action:@selector(btnWomanClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnWoman.backgroundColor = [UIColor whiteColor];
    [btnWoman setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnWoman setTitle:@"女" forState:UIControlStateNormal];
    [self.view addSubview:btnWoman];
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 145, KSCREEN_WIDTH, 0.5)];
    line1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:line1];
    
    if ([_sexStr isEqualToString:@"男"]) {
        btnMan.selected = YES;
    }
    else if ([_sexStr isEqualToString:@"女"]){
        btnWoman.selected = YES;
    }
    
}

- (void) btnManClicked:(UIButton *) sender {
    btnWoman.selected = NO;
    sender.selected = YES;
    sex = @"男";
    [self done];
}

- (void) btnWomanClicked:(UIButton *) sender {
    btnMan.selected = NO;
    sender.selected = YES;
    sex = @"女";
    [self done];
}

- (void) done{
    if (_sexStrBlock) {
        _sexStrBlock(sex);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
