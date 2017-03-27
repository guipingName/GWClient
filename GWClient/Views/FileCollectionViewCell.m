//
//  FileCollectionViewCell.m
//  GWClient
//
//  Created by guiping on 2017/3/24.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "FileCollectionViewCell.h"

@implementation FileCollectionViewCell{
    UIImageView *imageView;
    UILabel *lbFileName;
}

-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 30)];
        imageView.layer.cornerRadius = 15;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
    }
    imageView.image = [UIImage imageNamed:@"bimar背景"];
    
    if (!lbFileName) {
        lbFileName = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), self.bounds.size.width, 30)];
        [self.contentView addSubview:lbFileName];
    }
    lbFileName.text = fileName;
    lbFileName.textColor = THEME_COLOR;
    lbFileName.textAlignment = NSTextAlignmentCenter;
    //lbFileName.backgroundColor = [UIColor greenColor];
    
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(self.bounds.size.width - 30, 0, 30, 30);
        _deleteButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_deleteButton];
    }
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    
}

@end
