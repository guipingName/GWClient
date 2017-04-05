//
//  TransferListViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TransferListViewController.h"
#import "PreviewPicViewController.h"
#import "UpDownBtn.h"
#import "FileModel.h"
#import "Masonry.h"
#import "TransforModel.h"
#import "TaskManager.h"
#import "AppDelegate.h"


@interface TransferListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIButton *btnUpload;
    UIButton *btnDownload;
    NSMutableArray *dataArray;
    NSMutableArray *uploadArray;
    NSMutableArray *downloadArray;
    HintView *emptyUpView; // 上传空View
    HintView *emptyDownView;// 下载空View
    BOOL isUpButtonClicked;// 上传选中
    UIView *btnBackView;
    UserInfoModel *user;
    NSDictionary *progressDic;
    NSTimer *timer;
}

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UITableView *upTableView;
@property(nonatomic, strong)UITableView *downTableView;
@property(nonatomic, strong)UITableView *currentTableView;

@end

@implementation TransferListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"传输列表";
    [self createViews];
    timer.fireDate = [NSDate distantFuture];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    
    user = [Utils aDecoder];
    
    
    dataArray = [NSMutableArray array];
    uploadArray = [NSMutableArray array];
    downloadArray = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}


- (void) loadData {
    uploadArray = [[TaskManager sharedManager].uploadTaskArray mutableCopy];
    downloadArray = [[TaskManager sharedManager].downloadTaskArray mutableCopy];
    //NSLog(@"uploadArray.count: %lu downloadArray.count:%lu", (unsigned long)uploadArray.count, (unsigned long)downloadArray.count);
    if (isUpButtonClicked) {
        dataArray = uploadArray;
        if (dataArray.count == 0) {
            self.scrollView.hidden = YES;
            emptyUpView.hidden = NO;
        }
        else{
            emptyUpView.hidden = YES;
            self.scrollView.hidden = NO;
            _scrollView.contentOffset = CGPointMake(0, 0);
            [self.currentTableView reloadData];
        }
    }
    else{
        dataArray = downloadArray;
        if (dataArray.count == 0) {
            self.scrollView.hidden = YES;
            emptyDownView.hidden = NO;
        }
        else{
            emptyDownView.hidden = YES;
            self.scrollView.hidden = NO;
            _scrollView.contentOffset = CGPointMake(KSCREEN_WIDTH, 0);
            [self.currentTableView reloadData];
        }
    }
    [[TaskManager sharedManager] setProcessBlock:^(NSInteger done, NSInteger total, float progress) {
        progressDic = @{@"done":@(done),
                        @"compelet":@(progress)};
        NSLog(@"=======================\n compelet: %f\n=============",progress);
        
        if (isnan(progress)) {
            NSLog(@"#############################");
            progressDic = @{@"done":@([TaskManager sharedManager].done),
                            @"compelet":@(1)};
            [timer invalidate];
        }
            if (dataArray.count > 0) {
                    [self.currentTableView reloadData];
            }
    }];
    
}

- (void) createViews {
    btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, 36)];
    btnBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:btnBackView];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, btnBackView.bounds.size.height - 0.5, btnBackView.bounds.size.width, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [btnBackView addSubview:lineView];
    
    btnUpload = [self createButton:@"上传列表"];
    btnUpload.selected = YES;
    isUpButtonClicked = YES;
    [btnUpload setFrame:CGRectMake(btnBackView.bounds.size.width / 4 - 80 / 2, 0, 80, 35)];
    [btnUpload addTarget:self action:@selector(selectedListType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:btnUpload];
    
    btnDownload = [self createButton:@"下载列表"];
    [btnDownload setFrame:CGRectMake((btnBackView.bounds.size.width + 80) /2, 0, 80, 35)];
    [btnDownload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnDownload addTarget:self action:@selector(selectedListType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:btnDownload];
    
    [self.view addSubview:self.scrollView];
    
    
    emptyUpView = [[HintView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBackView.frame), KSCREEN_WIDTH, KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49)];
    [self.view addSubview:emptyUpView];
    [emptyUpView createHintViewWithTitle:@"你还没有上传记录哦~" image:[[UIImage imageNamed:@"upload_64"] rt_tintedImageWithColor:[UIColor grayColor]] block:nil];
    
    emptyDownView = [[HintView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBackView.frame), KSCREEN_WIDTH, KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49)];
    [self.view addSubview:emptyDownView];
    [emptyDownView createHintViewWithTitle:@"还没有下载记录~" image:[[UIImage imageNamed:@"download_64"] rt_tintedImageWithColor:[UIColor grayColor]] block:nil];
}




#pragma mark --------------- UITableViewDelegate ----------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TransferListCell *cell = [tableView dequeueReusableCellWithIdentifier:TRANSFERLISTCELL forIndexPath:indexPath];
    FileModel *model = dataArray[indexPath.row];
    [cell configWithFileModel:model andCompelet:progressDic];
    return cell;
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FileModel *fileModel = dataArray[indexPath.row];
        [dataArray removeObject:fileModel];
        
        if (isUpButtonClicked) {
            [TaskManager sharedManager].uploadTaskArray = dataArray;
            [user deleteUpList:fileModel];
        }
        else{
            [TaskManager sharedManager].downloadTaskArray = dataArray;
            [user deleteDownList:fileModel];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (dataArray.count == 0) {
            _scrollView.hidden = YES;
            if (isUpButtonClicked) {
                emptyUpView.hidden = NO;
            }
            else{
                emptyDownView.hidden = NO;
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileModel *model = dataArray[indexPath.row];
    PreviewPicViewController *preVC = [[PreviewPicViewController alloc] init];
    preVC.hidesBottomBarWhenPushed = YES;
    preVC.model = model;
    if (model.fileType == FileTypePicture) {
        preVC.isPicture = YES;
    }
    else{
        preVC.isPicture = NO;
    }
    [self.navigationController pushViewController:preVC animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


- (UIButton *) createButton:(NSString *) title{
    UIButton *button = [UpDownBtn buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setImage:[UIImage imageNamed:@"bimar背景"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    return button;
}

-(void) selectedListType:(UIButton *) sender{
    [sender setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    sender.selected = YES;
    
    if([sender.titleLabel.text isEqualToString:@"上传列表"]){
        isUpButtonClicked = YES;
        btnDownload.selected = NO;
        [btnDownload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        dataArray = uploadArray;
        emptyDownView.hidden = YES;
        _scrollView.contentOffset = CGPointMake(0, 0);
        if (dataArray.count == 0) {
            _scrollView.hidden = YES;
            emptyUpView.hidden = NO;
        }
        else{
            _scrollView.hidden = NO;
            [self.currentTableView reloadData];
        }
    }
    else{
        isUpButtonClicked = NO;
        btnUpload.selected = NO;
        [btnUpload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _scrollView.contentOffset = CGPointMake(KSCREEN_WIDTH, 0);
        dataArray = downloadArray;
        emptyUpView.hidden = YES;
        if (dataArray.count == 0) {
            _scrollView.hidden = YES;
            emptyDownView.hidden = NO;
        }
        else{
            _scrollView.hidden = NO;
            [self.currentTableView reloadData];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 懒加载
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        float widith = KSCREEN_WIDTH;
        float height = KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49;
        _scrollView.backgroundColor = [UIColor yellowColor];
        _scrollView.frame = CGRectMake(0, CGRectGetMaxY(btnBackView.frame), widith, height);
        _scrollView.contentSize = CGSizeMake(widith * 2,height);
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
        _scrollView.hidden = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView addSubview:self.upTableView];
        [_scrollView addSubview:self.downTableView];
    }
    return _scrollView;
}

- (UITableView *)upTableView
{
    if (!_upTableView) {
        float widith = KSCREEN_WIDTH;
        float height = KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49;
        _upTableView = [UITableView new];
        _upTableView.tableFooterView = [UIView new];
        _upTableView.frame = CGRectMake(0, 0, widith, height);
    }
    return _upTableView;
}

- (UITableView *)downTableView
{
    if (!_downTableView) {
        float widith = KSCREEN_WIDTH;
        float height = KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49;
        
        _downTableView = [UITableView new];
        _downTableView.tableFooterView = [UIView new];
        _downTableView.frame = CGRectMake(widith, 0, widith, height);
    }
    return _downTableView;
}

- (UITableView *)currentTableView
{
    _currentTableView = isUpButtonClicked ? self.upTableView : self.downTableView;
    _currentTableView.delegate = self;
    _currentTableView.dataSource = self;
    [_currentTableView registerClass:[TransferListCell class] forCellReuseIdentifier:TRANSFERLISTCELL];
    return _currentTableView;
}
@end
#pragma mark - TransferListCell


@interface TransferListCell()

@property(nonatomic, strong)UIImageView *iconImage;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *sizeLabel;
@property(nonatomic, strong)UILabel *compeletLabel;


@end
@implementation TransferListCell

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

- (void)configWithFileModel:(FileModel *)fileModel andCompelet: (NSDictionary *) dic
{
    NSNumber *done;
    NSNumber *compelet;
    if (dic) {
        done = [dic valueForKey:@"done"];
        compelet = [dic valueForKey:@"compelet"];
    } else {
        done = @(0);
        compelet = @(0);
    }
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    _iconImage.image = [UIImage imageNamed:[Utils ImageNameWithFileType:fileModel.fileType]];
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
    } else if(fileModel.fileState == TransferStatusDuring) {
        _sizeLabel.text = [NSString stringWithFormat:@"%ldk/%luK",[done integerValue]/1024,(unsigned long)fileModel.fileSize / 1024];
        if (appdelegate.netState != NetStatusViaWiFi) {
            _sizeLabel.text = @"网络断开";
            _sizeLabel.textColor = [UIColor redColor];
        }
        else{
             _sizeLabel.textColor = [UIColor lightGrayColor];
        }
        _compeletLabel.text = [NSString stringWithFormat:@"%.f%%",[compelet floatValue] * 100];
    } else {
        _sizeLabel.text = [NSString stringWithFormat:@"已完成:%luK",(unsigned long)fileModel.fileSize / 1024];
        _sizeLabel.textColor = [UIColor lightGrayColor];
        _compeletLabel.text = [NSString stringWithFormat:@"100%%"];
    }
}
@end
