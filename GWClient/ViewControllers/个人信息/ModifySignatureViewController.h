//
//  ModifySignatureViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModifySignatureViewController : UIViewController

@property (nonatomic, assign) BOOL isModifySignature;

@property (nonatomic, assign) BOOL isfeedback;

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, copy) void(^strBlock)(NSString *);

@end
