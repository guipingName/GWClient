//
//  FileCollectionViewCell.h
//  GWClient
//
//  Created by guiping on 2017/3/24.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, strong) UIButton *deleteButton;


@end


