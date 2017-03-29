//
//  NewsTableViewCell.h
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsModel;
@interface NewsTableViewCell : UITableViewCell

@property(nonatomic, strong)NewsModel *model;
@end
