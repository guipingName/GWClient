//
//  FileListTableViewCell.h
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileListTableViewCell : UITableViewCell

@property(nonatomic, copy)void (^onOffBlock)(BOOL onOff);


@property(nonatomic, assign)BOOL cellOn;
@property(nonatomic, strong)FileModel *model;
@property(nonatomic, copy)void (^deleteBlock)(FileModel *);
@property(nonatomic, copy)void (^downLoadBlock)(FileModel *);
@end
