//
//  RegisterViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserLogin.h"

@interface RegisterViewController ()<UITextFieldDelegate>
{
    UITextField *tfEmail;
    UITextField *tfPassword;
    UITextField *tfConfirm;
    UIButton *btnRegister;
    UIButton *btnConfim;
    UILabel *lbConfirm;
    NSString *confirmStr;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    
    [self createViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldLength:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void) textFieldLength:(NSNotification *) sender{
    if (tfEmail.text.length > 0 && tfConfirm.text.length > 0 && tfPassword.text.length > 0) {
        btnRegister.enabled = YES;
        btnRegister.backgroundColor = THEME_COLOR;
    }
    else{
        btnRegister.enabled = NO;
        btnRegister.backgroundColor = BTN_ENABLED_BGCOLOR;
    }
    if (tfEmail.text.length > 0){
        btnConfim.enabled = YES;
        btnConfim.backgroundColor = THEME_COLOR;
    }
    else{
        btnConfim.enabled = NO;
        btnConfim.backgroundColor = BTN_ENABLED_BGCOLOR;
    }
}

- (void) createViews{
    UILabel *lbTemp = nil;
    NSArray *names = @[@"用户名", @"验证码", @"密码"];
    CGPoint lbOriginCenter = CGPointZero;
    CGPoint lbNewCenter = CGPointZero;
    CGPoint lbConfirmCenter = CGPointZero;
    CGRect maxRect = CGRectZero;
    for (int i=0; i<3; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = names[i];
        label.tag = 500 + i;
        label.font = [UIFont systemFontOfSize:15];
        CGRect temperatureLabelR = LABEL_RECT(label.text, 0, 0, 1, 15);
        if (temperatureLabelR.size.width > maxRect.size.width) {
            maxRect = temperatureLabelR;
            lbTemp = label;
        }
        [self.view addSubview:label];
    }
    for (int i=0; i<3; i++) {
        UILabel *label = (UILabel *)[self.view viewWithTag:500 + i];
        label.frame = CGRectMake(40, 64 + 20 + 50 * i, maxRect.size.width, maxRect.size.height);
        if (i == 0) {
            lbOriginCenter = label.center;
        }
        else if (i == 1) {
            lbNewCenter = label.center;
        }
        else{
            lbConfirmCenter = label.center;
        }
        [label setAlignmentLeftAndRight];
    }
    NSArray *placeholders = @[@"请输入用户名", @"请输入验证码", @"请输入新密码"];
    for (int i=0; i<3; i++) {
        UITextField *tf = [self createTextField:i];
        tf.frame = CGRectMake(0, 0, KSCREEN_WIDTH - CGRectGetMaxX(lbTemp.frame) - 50, 40);
        if (i == 0) {
            tf.center = CGPointMake((CGRectGetMaxX(lbTemp.frame)) + 10 + CGRectGetWidth(tf.frame) / 2, lbOriginCenter.y);
            tfEmail = tf;
            [tf becomeFirstResponder];
            [self.view addSubview:tf];
        }
        else if (i == 1) {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH - CGRectGetMaxX(lbTemp.frame) - 50, 40)];
            bgView.center = CGPointMake((CGRectGetMaxX(lbTemp.frame)) + 10 + CGRectGetWidth(tf.frame) / 2, lbNewCenter.y);
            bgView.layer.cornerRadius = 5;
            bgView.layer.masksToBounds = YES;
            bgView.layer.borderColor = UICOLOR_RGBA(204, 204, 204, 1.0).CGColor;
            bgView.layer.borderWidth = 1;
            [self.view addSubview:bgView];
            
            tf.frame = CGRectMake(0, 0, CGRectGetWidth(bgView.bounds) - 70, 40);
            [bgView addSubview:tf];
            
            tfConfirm = tf;
            // 获取验证码
            btnConfim = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnConfim setTitle:@"获取验证码" forState:UIControlStateNormal];
            [btnConfim setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnConfim.titleLabel.font = [UIFont systemFontOfSize:12];
            btnConfim.backgroundColor = BTN_ENABLED_BGCOLOR;
            btnConfim.enabled = NO;
            btnConfim.frame = CGRectMake(bgView.bounds.size.width - 72,(bgView.bounds.size.height - 30) / 2, 70, 30);
            //btnConfim.frame = CGRectMake(100,400, 70, 30);
            btnConfim.layer.cornerRadius = 5;
            btnConfim.layer.masksToBounds = YES;
            [bgView addSubview:btnConfim];
            [btnConfim addTarget:self action:@selector(getConfirm:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            tf.center = CGPointMake((CGRectGetMaxX(lbTemp.frame)) + 10 + CGRectGetWidth(tf.frame) / 2, lbConfirmCenter.y);
            tfPassword = tf;
            tfPassword.secureTextEntry = YES;
            [self.view addSubview:tf];
        }
        tf.delegate = self;
        tf.placeholder = placeholders[i];
        
    }
    
    lbConfirm = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH / 2, 50)];
    lbConfirm.center = CGPointMake(KSCREEN_WIDTH / 2, CGRectGetMaxY(tfPassword.frame) + 30);
    lbConfirm.backgroundColor = [UIColor grayColor];
    lbConfirm.font = [UIFont systemFontOfSize:15];
    lbConfirm.hidden = YES;
    [self.view addSubview:lbConfirm];
    
    // 创建注册按钮
    btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.backgroundColor = BTN_ENABLED_BGCOLOR;
    btnRegister.enabled = NO;
    btnRegister.frame = CGRectMake((KSCREEN_WIDTH - 150) / 2, CGRectGetMaxY(lbConfirm.frame) + 5, 150, 40);
    [self.view addSubview:btnRegister];
    btnRegister.layer.cornerRadius = 5;
    btnRegister.layer.masksToBounds = YES;
    [btnRegister addTarget:self action:@selector(Register:) forControlEvents:UIControlEventTouchUpInside];
}

- (UITextField *)createTextField:(NSInteger) number{
    UITextField *tf = [[UITextField alloc] init];
    if (number != 1) {
        tf.layer.borderColor = UICOLOR_RGBA(204, 204, 204, 1.0).CGColor;
        tf.layer.borderWidth= 1.0f;
        tf.layer.cornerRadius = 5.0f;
    }
    tf.returnKeyType = UIReturnKeyDone;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    [tf setValue:UICOLOR_RGBA(128, 128, 128, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
    return tf;
}

- (void) getConfirm:(UIButton *) sender{
    NSDictionary *paramDic = @{@"username":tfEmail.text};
    [Request GET:ApiTypeGetverifiyCode params:paramDic succeed:^(id response) {
//        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
//        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
//        NSLog(@"获取验证码--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            [MBProgressHUD showSuccessMessage:response[@"message"]];
            if ([response[@"success"] boolValue]) {
                NSDictionary *tempD = response[@"result"];
                confirmStr = [tempD[@"verifiyCode"] stringValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    btnConfim.enabled = NO;
                    btnConfim.backgroundColor = BTN_ENABLED_BGCOLOR;
                    lbConfirm.text = [NSString stringWithFormat:@"验证码: %@ ", confirmStr];
                    [lbConfirm setAlignmentLeftAndRight];
                    lbConfirm.hidden = NO;
                });
            }
        }
        else{
            [MBProgressHUD showErrorMessage:@"获取失败"];
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        if (error.code != NO_NETWORK) {
            [MBProgressHUD showErrorMessage:@"获取失败"];
        }
    }];
}


- (void) Register:(UIButton *) sender{
//    if (![tfConfirm.text isEqualToString:confirmStr]) {
//        [Utils hintMessage:@"验证码不正确" time:1 isSuccess:NO];
//        return;
//    }
    NSDictionary *paramDic = @{@"username":tfEmail.text,
                               @"verifyCode":tfConfirm.text,
                               @"password":tfPassword.text
                               };
    [Request GET:ApiTypeRegister params:paramDic succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"注册--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            [MBProgressHUD showSuccessMessage:response[@"message"]];
            if ([response[@"success"] boolValue]) {
                UserLogin *model = [[UserLogin alloc] init];
                model.email = tfEmail.text;
                model.password = tfPassword.text;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (_loginBlock) {
                        _loginBlock(model);
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
        else{
            [MBProgressHUD showErrorMessage:@"注册失败"];
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        if (error.code != NO_NETWORK) {
            [MBProgressHUD showErrorMessage:@"注册失败"];
        }
    }];
}

#pragma mark --------------- UITextFieldDelegate ----------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField becomeFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([tfEmail becomeFirstResponder] || [tfPassword becomeFirstResponder]) {
        [tfEmail resignFirstResponder];
        [tfPassword resignFirstResponder];
    }
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
