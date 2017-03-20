//
//  UserInfoTableViewCell.h
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isHead;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@end
