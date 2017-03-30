//
//  TransferListViewController.h
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"

@interface TransferListViewController : UIViewController

@end


@interface TransferListCell : UITableViewCell

- (void)configWithFileModel:(FileModel *)fileModel andCompelet: (NSDictionary *) dic;

@end
