//
//  ModifySignatureViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ModifySignatureViewController.h"
#import "UITextView+YLTextView.h"


@interface ModifySignatureViewController ()<UITextFieldDelegate>
{
    UITextView *textView;
}

@end

@implementation ModifySignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"个性签名";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, 0.1)];
    [self.view addSubview:view];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 70, KSCREEN_WIDTH-20, 80)];
    textView.font = [UIFont systemFontOfSize:18];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5;
    textView.layer.masksToBounds = YES;
    textView.layer.borderWidth = 0.5;
    textView.layer.borderColor = UICOLOR_RGBA(200, 200, 200, 1.0).CGColor;
    textView.text = _signatureStr;
    textView.placeholder = @"请设置您的个性签名";
    textView.limitLength = @30;
    [self.view addSubview:textView];

}

- (void) done{    
    if (_signStrBlock) {
        _signStrBlock(textView.text);
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
