//
//  UserInfoTableViewCell.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "UserInfoTableViewCell.h"

@implementation UserInfoTableViewCell{
    UIImageView *rightImgView;
    UILabel *lbLeft;
    UILabel *lbRight;
    UIImageView *ImvHeadIcon;
    UIView *lineView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    if (!lbLeft) {
        lbLeft = [[UILabel alloc]init];
        lbLeft.font = [UIFont systemFontOfSize:17];
        //lbLeft.textColor = UICOLOR_RGBA(48, 48, 48, 1.0);
        lbLeft.textColor = [UIColor blackColor];
        [self.contentView addSubview:lbLeft];
    }
    lbLeft.text = title;
    CGRect titleR = LABEL_RECT(lbLeft.text, 0, 0, 1, 17);
    lbLeft.frame = CGRectMake(5, (CGRectGetHeight(self.frame) - titleR.size.height) / 2, titleR.size.width, titleR.size.height);
    
    if (!rightImgView) {
        rightImgView = [[UIImageView alloc]init];
        [self.contentView addSubview:rightImgView];
    }
    UIImage *img = [UIImage imageNamed:@"箭头"];
    rightImgView.image = [img rt_tintedImageWithColor:[UIColor grayColor]];
    float imgH1 = rightImgView.image.size.height;
    float imgW1 = rightImgView.image.size.width;
    rightImgView.frame = CGRectMake(self.bounds.size.width - imgW1, (CGRectGetHeight(self.frame) - imgH1) / 2, imgW1, imgH1);
    
    if (_isHead) {
        if (!ImvHeadIcon) {
            ImvHeadIcon = [[UIImageView alloc]init];
            [self.contentView addSubview:ImvHeadIcon];
        }
        ImvHeadIcon.image = _subtitle;
        ImvHeadIcon.frame = CGRectMake(self.bounds.size.width - imgW1 - (self.bounds.size.height - 10) - 3, 5, self.bounds.size.height - 10, self.bounds.size.height - 10);
        ImvHeadIcon.layer.cornerRadius = (self.bounds.size.height - 10) / 2;
        ImvHeadIcon.layer.borderWidth = 2;
        ImvHeadIcon.layer.borderColor = UICOLOR_RGBA(250, 126, 20, 1.0).CGColor;
        ImvHeadIcon.layer.masksToBounds = YES;
    }
    else{
        if (!lbRight) {
            lbRight = [[UILabel alloc]init];
            lbRight.font = [UIFont systemFontOfSize:17];
            //lbRight.textColor = UICOLOR_RGBA(48, 48, 48, 1.0);
            lbRight.textColor = THEME_COLOR;
            [self.contentView addSubview:lbRight];
        }
        lbRight.text = _subtitle;
        CGRect lbRightR = LABEL_RECT(lbRight.text, KSCREEN_WIDTH / 2, 0, 1, 17);
        lbRight.frame = CGRectMake(CGRectGetMinX(rightImgView.frame) - lbRightR.size.width, (CGRectGetHeight(self.frame) - lbRightR.size.height) / 2, lbRightR.size.width, lbRightR.size.height);
    }
    
    if (!lineView) {
        lineView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetHeight(self.frame) - 0.5, self.bounds.size.width, 0.5)];
        lineView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:lineView];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
