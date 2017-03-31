//
//  FileListTableViewCell.m
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "FileListTableViewCell.h"
#import "FileModel.h"
#import "UpImageDownTitle.h"

@interface FileListTableViewCell(){
    BOOL onOff;
}

@property(nonatomic, strong)UIImageView *iconImage;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *timeLabel;
@property(nonatomic, strong)UILabel *sizeLabel;
@property(nonatomic, strong)UIButton *onOffBtn;
@property(nonatomic, strong)UIButton *downBtn;
@property(nonatomic, strong)UIButton *deleteBtn;
@property(nonatomic, strong)UIView *bottomView;
@end

@implementation FileListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setModel:(FileModel *)model {
    _model = model;
    _nameLabel.text = model.fileName;
    _timeLabel.text = [Utils getTimeToShowWithTimestamp:model.fileTime];
    _iconImage.image = [UIImage imageNamed:[Utils ImageNameWithFileType:model.fileType]];
    _sizeLabel.text = [NSString stringWithFormat:@"%lu K",(unsigned long)model.fileSize / 1024];
}

- (void)setCellOn:(BOOL)cellOn{
    self.bottomView.hidden = cellOn;
    self.onOffBtn.selected = !cellOn;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *topView = [UIView new];
        [self.contentView addSubview:topView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
        
        _iconImage = [UIImageView new];
        [topView addSubview:_iconImage];
        [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topView).offset(5);
            make.top.equalTo(topView).offset(5);
            make.height.width.mas_equalTo(40);
        }];
        
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        [topView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(topView.mas_centerY).offset(-5);
            make.left.equalTo(_iconImage.mas_right).offset(10);
        }];
        
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textColor = [UIColor lightGrayColor];
        [topView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topView.mas_centerY).offset(5);
            make.left.equalTo(_nameLabel);
        }];
        
        _onOffBtn = [UIButton new];
        //_onOffBtn.backgroundColor = [UIColor redColor];
        [topView addSubview:_onOffBtn];
        [_onOffBtn addTarget:self action:@selector(cellOnOff:) forControlEvents:UIControlEventTouchUpInside];
        [_onOffBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [_onOffBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateSelected];
        [_onOffBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_iconImage);
            make.height.mas_equalTo(30);
            make.width.mas_offset(40);
            make.right.mas_equalTo(topView).offset(-5);
        }];
        
        _sizeLabel = [UILabel new];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.textColor = [UIColor lightGrayColor];
        [topView addSubview:_sizeLabel];
        
        [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_onOffBtn.mas_left).offset(-10);
            make.centerY.mas_equalTo(_timeLabel);
        }];
        
        [self.contentView addSubview:self.bottomView];
    }
    return self;
}

- (void)cellOnOff:(UIButton *) sender {
    sender.selected = !sender.selected;
    if (self.onOffBlock) {
        self.onOffBlock(sender.selected);
    }
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.hidden = YES;
        _bottomView.backgroundColor = UICOLOR_RGBA(242, 242, 242, 1.0);
        [self.contentView addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_centerY);
            make.left.right.mas_equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
        
        _downBtn = [UpImageDownTitle buttonWithType:UIButtonTypeCustom];
        [_downBtn setTitle:@"下载" forState:UIControlStateNormal];
        _downBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _downBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_downBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_downBtn addTarget:self action:@selector(downLoadFile:) forControlEvents:UIControlEventTouchUpInside];
        [_downBtn setImage:[[UIImage imageNamed:@"download"] rt_tintedImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [_bottomView addSubview:_downBtn];
        [_downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_bottomView);
            make.centerX.mas_equalTo(_bottomView).dividedBy(2);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(50);
        }];
        
        _deleteBtn = [UpImageDownTitle buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_deleteBtn setImage:[[UIImage imageNamed:@"delete"] rt_tintedImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteFile:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_deleteBtn];
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_bottomView);
            make.centerX.mas_equalTo(_bottomView).multipliedBy(1.5);
            make.height.width.equalTo(_downBtn);
        }];
        
    }
    return _bottomView;
}

- (void)deleteFile:(UIButton *) sender {
    if (self.deleteBlock) {
        self.deleteBlock(_model);
    }
}

- (void)downLoadFile:(UIButton *) sender {
    if (self.downLoadBlock) {
        self.downLoadBlock(_model);
    }
}

@end
