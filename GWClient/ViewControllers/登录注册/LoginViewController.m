//
//  LoginViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "GWClientTabBarController.h"
#import "LeftViewController.h"
#import "MMDrawerController.h"
#import "UILabel+GPAligment.h"
#import "RegisterViewController.h"
#import "UserLogin.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    UITextField *tfUserName;
    UITextField *tfPassword;
    UIButton *btnLogin;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self createViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldLength:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void) textFieldLength:(NSNotification *) sender{
    if (tfUserName.text.length > 0 && tfPassword.text.length > 0) {
        btnLogin.enabled = YES;
        btnLogin.backgroundColor = THEME_COLOR;
    }
    else{
        btnLogin.enabled = NO;
        btnLogin.backgroundColor = BTN_ENABLED_BGCOLOR;
    }
}

- (void) doLogin:(UIButton *) sender{
    [tfUserName resignFirstResponder];
    [tfPassword resignFirstResponder];
    [MBProgressHUD showActivityMessageInView:@"正在登录"];
    [Utils hiddenMBProgressAfterTenMinites];
    NSDictionary *paramDic = @{@"username":tfUserName.text,
                               @"password":tfPassword.text,
                               @"deviceId":[[[UIDevice currentDevice] identifierForVendor] UUIDString]
                               };
    [Utils GET:ApiTypeLogin params:paramDic succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"登录--返回的Json串:\n%@", tempStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response[@"success"] boolValue]) {
                [Utils hintMessage:@"登录成功" time:1 isSuccess:YES];
                NSDictionary *dic = response[@"result"];
                UserInfoModel *model = [[UserInfoModel alloc] init];
                model.userId = [dic[@"userId"] integerValue];
                model.token = response[@"token"];
                model.nickName = [NSString stringWithFormat:@"%@",dic[@"nickName"]];
                model.headImgUrl = dic[@"headImgUrl"];
                model.age = [dic[@"age"] integerValue];
                model.sex = [dic[@"gender"] integerValue];
                model.location = dic[@"location"];
                model.signature = dic[@"signature"];
                //
                // 归档
                [Utils aCoder:model];
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                [userDef setBool:YES forKey:IS_HAS_LOGIN];
                [userDef synchronize];
                LeftViewController *leftVC = [[LeftViewController alloc] init];
                MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:[[GWClientTabBarController alloc] init] leftDrawerViewController:leftVC];
                [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
                [drawerController setMaximumLeftDrawerWidth:LEFTVC_WIDTH];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.view.window.rootViewController = drawerController;
                });
            }
            else{
                [Utils hintMessage:response[@"message"] time:1 isSuccess:NO];
            }
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


- (void)doTestJsonCodecButtonAction:(NSString *) userName password:(NSString *) password{
    
}

- (void) dobtnRegister:(UIButton *) sender{
    NSLog(@"注册");
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    registerVC.loginBlock = ^(UserLogin *model){
        tfUserName.text = model.email;
        tfPassword.text = model.password;
        btnLogin.enabled = YES;
        btnLogin.backgroundColor = THEME_COLOR;
    };
    [self.navigationController pushViewController:registerVC animated:YES];
    //[self presentViewController:registerVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createViews{
    UILabel *lbTemp = nil;
    CGRect maxRect = CGRectZero;
    // 创建序列号标签
    UILabel *lbDeviceId = [[UILabel alloc] init];
    lbDeviceId.text = @"用户名";
    lbDeviceId.font = [UIFont systemFontOfSize:15];
    CGRect lbDeviceIdR = LABEL_RECT(lbDeviceId.text, 0, 0, 1, 15);
    maxRect = lbDeviceIdR;
    lbTemp = lbDeviceId;
    [self.view addSubview:lbDeviceId];
    // 创建密码标签
    UILabel *lbPassword = [[UILabel alloc] init];
    lbPassword.text = @"密码";
    lbPassword.font = [UIFont systemFontOfSize:15];
    CGRect lbPasswordR = LABEL_RECT(lbPassword.text, 0, 0, 1, 15);
    if (lbPasswordR.size.width > maxRect.size.width) {
        maxRect = lbPasswordR;
        lbTemp = lbPassword;
    }
    [self.view addSubview:lbPassword];
    lbDeviceId.frame = CGRectMake(30, 100, maxRect.size.width + 1, maxRect.size.height);
    lbPassword.frame = CGRectMake(30, 150, maxRect.size.width + 1, maxRect.size.height);
    CGPoint lbSSIDCenter = lbDeviceId.center;
    CGPoint lbPasswordCenter = lbPassword.center;
    [lbDeviceId setAlignmentLeftAndRight];
    [lbPassword setAlignmentLeftAndRight];
    
    
    // 创建用户名
    tfUserName = [Utils createTextField];
    tfUserName.frame = CGRectMake(0, 0, KSCREEN_WIDTH - 70 - CGRectGetWidth(lbPassword.frame), 40);
    tfUserName.center = CGPointMake((CGRectGetMaxX(lbDeviceId.frame) + 10) + (CGRectGetWidth(tfUserName.frame)) / 2, lbSSIDCenter.y);
    //tfUserName.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:tfUserName];
    tfUserName.delegate = self;
    tfUserName.placeholder = @"请输入用户名";
    
    // 密码输入框
    tfPassword = [Utils createTextField];
    tfPassword.frame = CGRectMake(0, 0, KSCREEN_WIDTH - 70 - CGRectGetWidth(lbPassword.frame), 40);
    tfPassword.center = CGPointMake((CGRectGetMaxX(lbPassword.frame) + 10) + (CGRectGetWidth(tfPassword.frame)) / 2, lbPasswordCenter.y);
    //tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
    tfPassword.secureTextEntry = YES;
    [self.view addSubview:tfPassword];
    tfPassword.delegate = self;
    tfPassword.placeholder = @"请输入密码";
    
    btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLogin.enabled = NO;
    btnLogin.backgroundColor = BTN_ENABLED_BGCOLOR;
    btnLogin.frame = CGRectMake(0, 0, KSCREEN_WIDTH * 2 /3, 40);
    btnLogin.center = CGPointMake(KSCREEN_WIDTH / 2, CGRectGetMaxY(tfPassword.frame) + 60);
    [self.view addSubview:btnLogin];
    btnLogin.layer.cornerRadius = 5;
    btnLogin.layer.masksToBounds = YES;
    [btnLogin addTarget:self action:@selector(doLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.backgroundColor = THEME_COLOR;
    btnRegister.frame = CGRectMake(0, 0, KSCREEN_WIDTH * 2 /3, 40);
    btnRegister.center = CGPointMake(CGRectGetMidX(btnLogin.frame), CGRectGetMaxY(btnLogin.frame) + 35);
    [self.view addSubview:btnRegister];
    btnRegister.layer.cornerRadius = 5;
    btnRegister.layer.masksToBounds = YES;
    [btnRegister addTarget:self action:@selector(dobtnRegister:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark --------------- UITextFieldDelegate ----------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField becomeFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([tfUserName becomeFirstResponder] || [tfPassword becomeFirstResponder]) {
        [tfUserName resignFirstResponder];
        [tfPassword resignFirstResponder];
    }
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
