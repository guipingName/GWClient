//
//  ModifySignatureViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ModifySignatureViewController.h"


@interface ModifySignatureViewController ()<UITextFieldDelegate>
{
    UITextField *tfNickname;
    //UITextView *textView;
}

@end

@implementation ModifySignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.title = @"个性签名";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    // 创建用户名
    tfNickname = [self createTextField];
    tfNickname.frame = CGRectMake(10, 80, KSCREEN_WIDTH - 20, 40);
    [self.view addSubview:tfNickname];
    tfNickname.delegate = self;
    tfNickname.text = _signatureStr;
    tfNickname.placeholder = @"请编辑您的个性签名";
    [tfNickname becomeFirstResponder];

}

- (void) done{
    UserInfoModel *model = [Utils aDecoder];
    NSDictionary *params = @{@"userId":@(model.userId),
                             @"token":@"123",
                             @"modifyDic":@{@"signature":tfNickname.text}
                             };
    [Utils GET:15 params:params succeed:^(id response) {
//        if ([response[@"success"] boolValue]) {
//            
//        }
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"修改个性签名--返回的Json串:\n%@", tempStr);
    } fail:^(NSError * error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
    if (_signStrBlock) {
        _signStrBlock(tfNickname.text);
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
