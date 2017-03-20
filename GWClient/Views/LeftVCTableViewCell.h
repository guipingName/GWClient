//
//  LeftVCTableViewCell.h
//  warmwind
//
//  Created by guiping on 17/2/28.
//  Copyright © 2017年 galaxyWind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftVCTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isSetting;
@property (nonatomic, assign) BOOL isMore;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *imageName;

@end
