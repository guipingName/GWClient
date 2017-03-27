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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    btnMan = [SexButton buttonWithType:UIButtonTypeCustom];
    btnMan.frame = CGRectMake(0, 64, KSCREEN_WIDTH, 40);
    [btnMan setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
    [btnMan addTarget:self action:@selector(btnManClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnMan.backgroundColor = [UIColor whiteColor];
    [btnMan setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnMan setTitle:@"男" forState:UIControlStateNormal];
    [self.view addSubview:btnMan];
    
    btnWoman = [SexButton buttonWithType:UIButtonTypeCustom];
    btnWoman.frame = CGRectMake(0, 104, KSCREEN_WIDTH, 40);
    [btnWoman setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
    [btnWoman addTarget:self action:@selector(btnWomanClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnWoman.backgroundColor = [UIColor whiteColor];
    [btnWoman setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnWoman setTitle:@"女" forState:UIControlStateNormal];
    [self.view addSubview:btnWoman];
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
}

- (void) btnWomanClicked:(UIButton *) sender {
    btnMan.selected = NO;
    sender.selected = YES;
    sex = @"女";
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
