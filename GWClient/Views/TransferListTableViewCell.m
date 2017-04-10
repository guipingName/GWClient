//
//  TransferListTableViewCell.m
//  GWClient
//
//  Created by guiping on 2017/4/6.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TransferListTableViewCell.h"
#import "AppDelegate.h"
#import "FileModel.h"

@interface TransferListTableViewCell()

@property(nonatomic, strong)UIImageView *iconImage;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *sizeLabel;
@property(nonatomic, strong)UILabel *compeletLabel;

@end


@implementation TransferListTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _iconImage = [UIImageView new];
        [self.contentView addSubview:_iconImage];
        [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(5);
            make.top.equalTo(self.contentView).offset(5);
            make.height.width.mas_equalTo(40);
        }];
        
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_centerY).offset(-5);
            make.left.equalTo(_iconImage.mas_right).offset(10);
        }];
        
        _sizeLabel = [UILabel new];
        _sizeLabel.font = [UIFont systemFontOfSize:10];
        _sizeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_sizeLabel];
        [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_centerY).offset(5);
            make.left.equalTo(_nameLabel);
        }];
        
        _compeletLabel = [UILabel new];
        _compeletLabel.font = [UIFont systemFontOfSize:14];
        _compeletLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_compeletLabel];
        [_compeletLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-15);
        }];
        
    }
    return self;
}

- (void)configWithFileModel:(FileModel *)fileModel andCompelet: (NSDictionary *) dic{
    NSNumber *done;
    NSNumber *compelet;
    if (dic) {
        done = [dic valueForKey:@"done"];
        compelet = [dic valueForKey:@"compelet"];
    }
    else {
        done = @(0);
        compelet = @(0);
    }
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (fileModel.fileType == FileTypePicture) {
        _iconImage.image = [Utils getImageWithImageName:fileModel.fileName];
    }
    else{
        _iconImage.image = [Utils ImageNameWithFileType:fileModel.fileType];
    }
    _nameLabel.text = fileModel.fileName;
    if (fileModel.fileState == TransferStatusReady) {
        _sizeLabel.text = [NSString stringWithFormat:@"正在等待..."];
        if (appdelegate.netState != NetStatusViaWiFi) {
            _sizeLabel.text = @"网络断开";
            _sizeLabel.textColor = [UIColor redColor];
        }
        else{
            _sizeLabel.textColor = [UIColor lightGrayColor];
        }
        _compeletLabel.text = @"0%%";
    }
    else if(fileModel.fileState == TransferStatusDuring) {
        _sizeLabel.text = [NSString stringWithFormat:@"%@/%@",[self fileSizeNumber:[done integerValue]], [self fileSizeNumber:fileModel.fileSize]];
        if (appdelegate.netState != NetStatusViaWiFi) {
            _sizeLabel.text = @"网络断开";
            _sizeLabel.textColor = [UIColor redColor];
        }
        else{
            _sizeLabel.textColor = [UIColor lightGrayColor];
        }
        _compeletLabel.text = [NSString stringWithFormat:@"%.f%%",[compelet floatValue] * 100];
    }
    else {
        _sizeLabel.text = [NSString stringWithFormat:@"已完成:%@",[self fileSizeNumber:fileModel.fileSize]];
        _sizeLabel.textColor = [UIColor lightGrayColor];
        _compeletLabel.text = [NSString stringWithFormat:@"100%%"];
    }
}

- (NSString *) fileSizeNumber:(NSUInteger) size{
    if (size > 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f MB",size / (1024.0 * 1024.0)];
    }
    else{
        return [NSString stringWithFormat:@"%lu KB",size / 1024];
    }
}

@end
