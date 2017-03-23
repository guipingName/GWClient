//
//  TransferListViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TransferListViewController.h"

@interface TransferListViewController ()
{
    UIButton *circleBtn;
    UIButton *squareBtn;
}

@end

@implementation TransferListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"传输列表";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(doLogin)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void) createViews{
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, KSCREEN_WIDTH, 32)];
    btnBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:btnBackView];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, btnBackView.bounds.size.height -1, btnBackView.bounds.size.width, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [btnBackView addSubview:lineView];
    
    
    circleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [circleBtn setFrame:CGRectMake(btnBackView.bounds.size.width / 4 - 100 / 2, 0, 100, 30)];
    [circleBtn setTitle:@"上传列表" forState:UIControlStateNormal];
    [circleBtn setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    circleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [circleBtn addTarget:self action:@selector(selectedClipType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:circleBtn];
    
    squareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [squareBtn setFrame:CGRectMake((btnBackView.bounds.size.width + 100) /2, 0, 100, 30)];
    [squareBtn setTitle:@"下载列表" forState:UIControlStateNormal];
    squareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [squareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [squareBtn addTarget:self action:@selector(selectedClipType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:squareBtn];
}

-(void) selectedClipType:(UIButton *) sender{
    [sender setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    if([sender.titleLabel.text isEqualToString:@"上传列表"]){
        [squareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        [circleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}


- (void) doLogin{
    NSLog(@"222");
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
