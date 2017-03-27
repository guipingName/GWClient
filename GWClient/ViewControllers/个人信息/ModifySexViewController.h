//
//  ModifySexViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/27.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifySexViewController : UIViewController

@property (nonatomic, copy) NSString *sexStr;
@property (nonatomic, copy) void(^sexStrBlock)(NSString *);

@end
