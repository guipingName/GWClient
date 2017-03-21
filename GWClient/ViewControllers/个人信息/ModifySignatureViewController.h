//
//  ModifySignatureViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModifySignatureViewController : UIViewController



@property (nonatomic, copy) NSString *signatureStr;

@property (nonatomic, copy) void(^signStrBlock)(NSString *);

@end
