//
//  NewsTableViewCell.m
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "NewsTableViewCell.h"
#import "NewsModel.h"
#import "UIImageView+WebCache.h"

@implementation NewsTableViewCell{
    UIImageView *imageView;
    UILabel *lbTitle;
    UILabel *lbTime;
    UILabel *lbSrc;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(NewsModel *)model{
    _model = model;
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
    }
    imageView.frame = CGRectMake(5, (CGRectGetHeight(self.frame) - 80) / 2, 80, 80);
    [self.contentView addSubview:imageView];
    
    if (!lbTitle) {
        lbTitle = [[UILabel alloc] init];
    }
    lbTitle.numberOfLines = 0;
    lbTitle.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:lbTitle];
    
    
    if (!lbSrc) {
        lbSrc = [[UILabel alloc] init];
    }
    lbSrc.font = [UIFont systemFontOfSize:12];
    lbSrc.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetHeight(self.bounds) - 30, 100, 30);
    [self.contentView addSubview:lbSrc];
    
    if (!lbTime) {
        lbTime = [[UILabel alloc] init];
    }
    lbTime.font = [UIFont systemFontOfSize:12];
    lbTime.textAlignment = NSTextAlignmentRight;
    //CGRect lbTimeR = [lbTitle.text boundingRectWithSize:CGSizeMake(0, 0) options:1 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    //NSLog(@"width:%f  height:%f",lbTimeR.size.width, lbTimeR.size.height);
    lbTime.frame = CGRectMake(CGRectGetWidth(self.bounds) - 130, CGRectGetHeight(self.bounds) - 30, 125, 30);
    [self.contentView addSubview:lbTime];
    
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMAGENAME]];
    lbTitle.text = model.title;
    lbSrc.text = model.src;
    lbTime.text = model.time;
    
    CGRect lbTitleR = [lbTitle.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame) - 110, CGRectGetHeight(self.frame) - 55) options:1 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
    lbTitle.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 20, lbTitleR.size.width, lbTitleR.size.height);
}



@end
