//
//  ViewController.m
//  GWClient
//
//  Created by guiping on 17/3/16.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ViewController.h"
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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    NSLog(@"客户端测试");
    
    // 添加按钮
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btnSearch];
    btnSearch.frame = CGRectMake(100, 400, 80, 40);
    btnSearch.layer.cornerRadius = 5;
    btnSearch.layer.masksToBounds = YES;
    [btnSearch setTitle:@"开始搜索" forState:UIControlStateNormal];
    btnSearch.titleLabel.font = [UIFont systemFontOfSize:14];
    btnSearch.backgroundColor = THEME_COLOR;
    [btnSearch addTarget:self action:@selector(btnSearchClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) btnSearchClicked:(UIButton *) sender{
    [self doTestJsonCodecButtonAction];
}


#pragma mark - test json codec

- (void)doTestJsonCodecButtonAction{
    NSString *host = @"127.0.0.1";
    int port = 20162;
    
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
        [self sendRpcForTestJsonCodec];
    }];
    
    [[RHSocketChannelProxy sharedInstance] asyncConnect:connect];
}

- (void)sendRpcForTestJsonCodec
{
    //rpc返回的call reply id是需要和服务端协议一致的，否则无法对应call和reply。
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    paramDic[@"key1"] = @"1-先做json的编码";
    paramDic[@"key2"] = @"2-接着做string的编码";
    paramDic[@"key3"] = @"3-接着做可变包长度编码";
    paramDic[@"内容1"] = @"可变数据包通信测试（中文测试）";
    paramDic[@"content2"] = @"Variable Length （codec test）";
    
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = paramDic;
    
    RHSocketCallReply *callReply = [[RHSocketCallReply alloc] init];
    callReply.request = req;
    [callReply setSuccessBlock:^(id<RHSocketCallReplyProtocol> callReply, id<RHDownstreamPacket> response) {
        NSDictionary *resultDic = [response object];
        RHSocketLog(@"json resultDic: %@, %@", resultDic[@"key1"], resultDic[@"key2"]);
    }];
    [callReply setFailureBlock:^(id<RHSocketCallReplyProtocol> callReply, NSError *error) {
        RHSocketLog(@"error: %@", error.description);
    }];
    //发送，并等待返回
    [[RHSocketChannelProxy sharedInstance] asyncCallReply:callReply];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
