//
//  ModifyViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyNickNameViewController : UIViewController

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) void(^nameStrBlock)(NSString *);

@end
