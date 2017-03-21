//
//  ModifyViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ModifyViewController.h"

@interface ModifyViewController ()<UITextFieldDelegate>
{
    UITextField *tfNickname;
}

@end

@implementation ModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"昵称";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    
    // 创建用户名
    tfNickname = [self createTextField];
    tfNickname.frame = CGRectMake(10, 80, KSCREEN_WIDTH - 20, 40);
    //tfUserName.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:tfNickname];
    tfNickname.delegate = self;
    tfNickname.text = _nickName;
    tfNickname.placeholder = @"设置昵称";
    [tfNickname becomeFirstResponder];
    
    
}

- (void) done{
    if (_nameStrBlock) {
        _nameStrBlock(tfNickname.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --------------- UITextFieldDelegate ----------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField becomeFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([tfNickname becomeFirstResponder]) {
        [tfNickname resignFirstResponder];
    }
}

- (UITextField *) createTextField{
    UITextField *tf = [[UITextField alloc] init];
    tf.layer.borderColor = UICOLOR_RGBA(204, 204, 204, 1.0).CGColor;
    tf.layer.borderWidth= 1.0f;
    tf.layer.cornerRadius = 5.0f;
    tf.returnKeyType = UIReturnKeyDone;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    [tf setValue:UICOLOR_RGBA(128, 128, 128, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
    return tf;
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
