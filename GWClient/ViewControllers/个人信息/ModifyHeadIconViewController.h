//
//  ModifyHeadIconViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/22.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyHeadIconViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) void(^imageBlock)(UIImage *);
@end
