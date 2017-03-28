//
//  DocViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"

@interface DocViewController : UIViewController

@end


@interface TransferListCellaaa : UITableViewCell

@property(nonatomic, copy)void (^onOffBlock)(BOOL onOff);


@property(nonatomic, assign)BOOL cellOn;
@property(nonatomic, strong)FileModel *model;
@property(nonatomic, copy)void (^deleteBlock)(FileModel *);

@end
