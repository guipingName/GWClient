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


//
#import "RHSocketChannel.h"

#import "RHSocketStringEncoder.h"
#import "RHSocketStringDecoder.h"

#import "RHSocketBase64Encoder.h"
#import "RHSocketBase64Decoder.h"

#import "RHSocketJSONSerializationEncoder.h"
#import "RHSocketJSONSerializationDecoder.h"

#import "RHSocketZlibCompressionEncoder.h"
#import "RHSocketZlibCompressionDecoder.h"

#import "RHSocketProtobufEncoder.h"
#import "RHSocketProtobufDecoder.h"
//#import "Person.pb.h"

#import "RHSocketDelimiterEncoder.h"
#import "RHSocketDelimiterDecoder.h"

#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"

//#import "RHSocketHttpEncoder.h"
//#import "RHSocketHttpDecoder.h"
//#import "RHSocketHttpRequest.h"
//#import "RHSocketHttpResponse.h"

#import "RHSocketConfig.h"

//
#import "RHSocketService.h"

//
#import "RHSocketChannelProxy.h"
#import "RHConnectCallReply.h"
#import "EXTScope.h"

#import "RHSocketRpcCmdEncoder.h"
#import "RHSocketRpcCmdDecoder.h"

//
#import "RHSocketUtils.h"

//
#import "RHWebSocket.h"
//

@interface LoginViewController ()<UITextFieldDelegate>
{
    UITextField *tfUserName;
    UITextField *tfPassword;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
    
}

- (void) doLogin:(UIButton *) sender{
    NSString *strName = tfUserName.text;
    NSString *strPassword = tfPassword.text;
    //strName = @"guipingme@sina.com";
    //strPassword = @"hfdhfkaf";
    NSLog(@"登录");
    // 测试数据
    UserInfoModel *model = [[UserInfoModel alloc] init];
    model.userId = 20170201;
    model.nickName = strName;
    model.headImgUrl = @"bimar模式中火";
    model.age = 24;
    model.sex = 8;
    model.location = @"四川~成都";
    model.signature = @"即将设置个性签名";
    //
    // 归档
    NSMutableData *mData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mData];
    [archiver encodeObject:model forKey:@"userInfo"];
    [archiver finishEncoding];
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[documentsPath firstObject] stringByAppendingPathComponent:@"userInfo"];
     [mData writeToFile:dbPath atomically:YES];
     
    [self doTestJsonCodecButtonAction:strName password:strPassword];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setBool:YES forKey:IS_HAS_LOGIN];
    [userDef synchronize];
    
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    leftVC.model = model;
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:[[GWClientTabBarController alloc] init] leftDrawerViewController:leftVC];
    
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setMaximumLeftDrawerWidth:LEFTVC_WIDTH];
    
    self.view.window.rootViewController = drawerController;
}

- (void) createUserInfo{
    
}

- (void)doTestJsonCodecButtonAction:(NSString *) userName password:(NSString *) password{
    NSString *host = @"10.134.20.1";
    int port = 20173;
    //jsonEncoder -> stringEncoder -> VariableLengthEncoder
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    
    RHSocketStringEncoder *stringEncoder = [[RHSocketStringEncoder alloc] init];
    stringEncoder.nextEncoder = encoder;
    
    RHSocketJSONSerializationEncoder *jsonEncoder = [[RHSocketJSONSerializationEncoder alloc] init];
    jsonEncoder.nextEncoder = stringEncoder;
    
    //VariableLengthDecoder -> stringDecoder -> jsonDecoder
    RHSocketJSONSerializationDecoder *jsonDecoder = [[RHSocketJSONSerializationDecoder alloc] init];
    
    RHSocketStringDecoder *stringDecoder = [[RHSocketStringDecoder alloc] init];
    stringDecoder.nextDecoder = jsonDecoder;
    
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    decoder.nextDecoder = stringDecoder;
    
    [RHSocketChannelProxy sharedInstance].encoder = jsonEncoder;
    [RHSocketChannelProxy sharedInstance].decoder = decoder;
    
    //
    RHConnectCallReply *connect = [[RHConnectCallReply alloc] init];
    connect.host = host;
    connect.port = port;
    @weakify(self);
    [connect setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        @strongify(self);
        [self sendRpcForTestJsonCodec:userName password:password];
    }];
    
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void) sendRpcForTestJsonCodec:(NSString *) userName password:(NSString *) password{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    NSDictionary *paramDic = @{@"username":userName,
                               @"password":password
                               };
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = paramDic;
    req.pid = ApiTypeLoginApi;
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        NSDictionary *resultDic = [response object];
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"--返回的Json串:\n%@", tempStr);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        NSLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}


- (void) dobtnRegister:(UIButton *) sender{
    NSLog(@"注册");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createViews{
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLogin.backgroundColor = THEME_COLOR;
    btnLogin.frame = CGRectMake(0, 0, 175, 40);
    btnLogin.center = CGPointMake(KSCREEN_WIDTH / 2, KSCREEN_HEIGHT * 4 /5);
    [self.view addSubview:btnLogin];
    btnLogin.layer.cornerRadius = 5;
    btnLogin.layer.masksToBounds = YES;
    [btnLogin addTarget:self action:@selector(doLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.backgroundColor = THEME_COLOR;
    btnRegister.frame = CGRectMake(0, 0, 175, 40);
    btnRegister.center = CGPointMake(CGRectGetMidX(btnLogin.frame), CGRectGetMaxY(btnLogin.frame) + 50);
    [self.view addSubview:btnRegister];
    btnRegister.layer.cornerRadius = 5;
    btnRegister.layer.masksToBounds = YES;
    [btnRegister addTarget:self action:@selector(dobtnRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    tfUserName = [self createTextField];
    tfUserName.frame = CGRectMake(0, 0, KSCREEN_WIDTH - 70 - CGRectGetWidth(lbPassword.frame), 40);
    tfUserName.center = CGPointMake((CGRectGetMaxX(lbDeviceId.frame) + 10) + (CGRectGetWidth(tfUserName.frame)) / 2, lbSSIDCenter.y);
    //tfUserName.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:tfUserName];
    tfUserName.delegate = self;
    tfUserName.placeholder = @"请输入用户名";
    
    // 密码输入框
    tfPassword = [self createTextField];
    tfPassword.frame = CGRectMake(0, 0, KSCREEN_WIDTH - 70 - CGRectGetWidth(lbPassword.frame), 40);
    tfPassword.center = CGPointMake((CGRectGetMaxX(lbPassword.frame) + 10) + (CGRectGetWidth(tfPassword.frame)) / 2, lbPasswordCenter.y);
    //tfPassword.keyboardType = UIKeyboardTypeASCIICapable;
    tfPassword.secureTextEntry = YES;
    [self.view addSubview:tfPassword];
    tfPassword.delegate = self;
    tfPassword.placeholder = @"请输入密码";
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
