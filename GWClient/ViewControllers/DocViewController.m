//
//  DocViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "DocViewController.h"
#import "UIViewController+MMDrawerController.h"



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


@interface DocViewController ()

@end

@implementation DocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bimar关于"] style:UIBarButtonItemStylePlain target:self action:@selector(doLogin)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)doLogin{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
