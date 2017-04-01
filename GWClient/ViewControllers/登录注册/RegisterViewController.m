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
        UITextField *tf = [Utils createTextField];
        tf.frame = CGRectMake(0, 0, KSCREEN_WIDTH - CGRectGetMaxX(lbTemp.frame) - 50, 40);
        if (i == 0) {
            tf.center = CGPointMake((CGRectGetMaxX(lbTemp.frame)) + 10 + CGRectGetWidth(tf.frame) / 2, lbOriginCenter.y);
            tfEmail = tf;
            [tf becomeFirstResponder];
        }
        else if (i == 1) {
            tf.center = CGPointMake((CGRectGetMaxX(lbTemp.frame)) + 10 + CGRectGetWidth(tf.frame) / 2, lbNewCenter.y);
            tfConfirm = tf;
            // 获取验证码
            btnConfim = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnConfim setTitle:@"获取验证码" forState:UIControlStateNormal];
            [btnConfim setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnConfim.titleLabel.font = [UIFont systemFontOfSize:12];
            btnConfim.backgroundColor = BTN_ENABLED_BGCOLOR;
            btnConfim.enabled = NO;
            btnConfim.frame = CGRectMake(tf.bounds.size.width - 72,(tf.bounds.size.height - 30) / 2, 70, 30);
            btnConfim.layer.cornerRadius = 5;
            btnConfim.layer.masksToBounds = YES;
            [tf addSubview:btnConfim];
            [btnConfim addTarget:self action:@selector(getConfirm:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            tf.center = CGPointMake((CGRectGetMaxX(lbTemp.frame)) + 10 + CGRectGetWidth(tf.frame) / 2, lbConfirmCenter.y);
            tfPassword = tf;
            tfPassword.secureTextEntry = YES;
        }
        tf.delegate = self;
        tf.placeholder = placeholders[i];
        [self.view addSubview:tf];
    }
    
    lbConfirm = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH / 2, 50)];
    lbConfirm.center = CGPointMake(KSCREEN_WIDTH / 2, CGRectGetMaxY(tfPassword.frame) + 35);
    lbConfirm.backgroundColor = [UIColor grayColor];
    lbConfirm.font = [UIFont systemFontOfSize:15];
    lbConfirm.hidden = YES;
    [self.view addSubview:lbConfirm];
    
    // 创建添加按钮
    btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.backgroundColor = BTN_ENABLED_BGCOLOR;
    btnRegister.enabled = NO;
    btnRegister.frame = CGRectMake((KSCREEN_WIDTH - 150) / 2, CGRectGetMaxY(lbConfirm.frame) + 15, 150, 40);
    [self.view addSubview:btnRegister];
    btnRegister.layer.cornerRadius = 5;
    btnRegister.layer.masksToBounds = YES;
    [btnRegister addTarget:self action:@selector(Register:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) getConfirm:(UIButton *) sender{
    NSDictionary *paramDic = @{@"username":tfEmail.text};
    [Utils GET:ApiTypeGetverifiyCode params:paramDic succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"获取验证码--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            [Utils hintMessage:response[@"message"] time:1 isSuccess:YES];
            if ([response[@"success"] boolValue]) {
                NSDictionary *tempD = response[@"result"];
                confirmStr = [tempD[@"verifiyCode"] stringValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    lbConfirm.text = [NSString stringWithFormat:@"验证码: %@ ", confirmStr];
                    [lbConfirm setAlignmentLeftAndRight];
                    lbConfirm.hidden = NO;
                });
            }
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


- (void) Register:(UIButton *) sender{
    if (![tfConfirm.text isEqualToString:confirmStr]) {
        [Utils hintMessage:@"验证码不正确" time:1 isSuccess:NO];
        return;
    }
    NSDictionary *paramDic = @{@"username":tfEmail.text,
                               @"password":tfPassword.text
                               };
    [Utils GET:ApiTypeRegister params:paramDic succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"注册--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            [Utils hintMessage:response[@"message"] time:1 isSuccess:YES];
            if ([response[@"success"] boolValue]) {
                UserLogin *model = [[UserLogin alloc] init];
                model.email = tfEmail.text;
                model.password = tfPassword.text;
                if (_loginBlock) {
                    _loginBlock(model);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
        else{
            [Utils hintMessage:response[@"注册失败"] time:1 isSuccess:NO];
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
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
