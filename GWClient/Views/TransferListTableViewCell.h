//
//  TransferListTableViewCell.h
//  GWClient
//
//  Created by guiping on 2017/4/6.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransferListTableViewCell : UITableViewCell

- (void)configWithFileModel:(FileModel *)fileModel andCompelet: (NSDictionary *) dic;


@end
