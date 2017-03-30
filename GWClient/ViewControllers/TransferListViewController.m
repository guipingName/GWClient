//
//  TransferListViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TransferListViewController.h"
#import "UpDownBtn.h"
#import "FileModel.h"
#import "Masonry.h"

@interface TransferListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIButton *btnUpload;
    UIButton *btnDownload;
    NSMutableArray *dataArray;
    NSMutableArray *uploadArray;
    NSMutableArray *downloadArray;
    BOOL isEditing;
    UIButton *btnRightItem;
    UIView *btnBgView;
    HintView *emptyUpView; // 上传空View
    HintView *emptyDownView;// 下载空View
    BOOL isUpButtonClicked;// 上传选中
    UIView *btnBackView;
    UserInfoModel *user;
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
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    
    // 右边项
    btnRightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRightItem.frame = CGRectMake(0, 0, 50, 30);
    [btnRightItem addTarget:self action:@selector(dobtnRightItem:) forControlEvents:UIControlEventTouchDown];
    btnRightItem.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnRightItem setTitle:@"编辑" forState:UIControlStateNormal];
    [btnRightItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRightItem setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRightItem];
    
    user = [Utils aDecoder];
    
    [self createViews];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void) loadData{
    dataArray = [NSMutableArray array];
    uploadArray = [NSMutableArray array];
    downloadArray = [NSMutableArray array];
    
    uploadArray = [[user upLoadList] mutableCopy];
    downloadArray = [[user downLoadList] mutableCopy];
    
    
    if (isUpButtonClicked) {
        dataArray = uploadArray;
        if (dataArray.count == 0) {
            self.currentTableView.hidden = YES;
            emptyUpView.hidden = NO;
        }
        else{
            emptyUpView.hidden = YES;
            self.currentTableView.hidden = NO;
            [self.currentTableView reloadData];
        }
    }
    else{
        dataArray = downloadArray;
        if (dataArray.count == 0) {
            self.currentTableView.hidden = YES;
            emptyDownView.hidden = NO;
        }
        else{
            emptyDownView.hidden = YES;
            self.scrollView.hidden = NO;
            [self.currentTableView reloadData];
        }
    }
}

- (void) createViews {
    
    btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, 31)];
    btnBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:btnBackView];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, btnBackView.bounds.size.height -1, btnBackView.bounds.size.width, 1.2)];
    lineView.backgroundColor = [UIColor grayColor];
    [btnBackView addSubview:lineView];
    
    btnUpload = [self createButton:@"上传列表"];
    btnUpload.selected = YES;
    isUpButtonClicked = YES;
    [btnUpload setFrame:CGRectMake(btnBackView.bounds.size.width / 4 - 80 / 2, 0, 80, 30)];
    [btnUpload addTarget:self action:@selector(selectedListType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:btnUpload];
    
    btnDownload = [self createButton:@"下载列表"];
    [btnDownload setFrame:CGRectMake((btnBackView.bounds.size.width + 80) /2, 0, 80, 30)];
    [btnDownload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnDownload addTarget:self action:@selector(selectedListType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:btnDownload];
    
    [self.view addSubview:self.scrollView];
    btnBgView = [[UIView alloc] initWithFrame:CGRectMake(0, KSCREEN_HEIGHT - 49 - 50, KSCREEN_WIDTH, 49)];
    btnBgView.hidden = YES;
    btnBgView.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.5);
    [self.view addSubview:btnBgView];
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnBgView.bounds.size.width, btnBgView.bounds.size.height)];
    tempView.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.5);
    //[btnBgView addSubview:tempView];
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.frame = CGRectMake(tempView.bounds.size.width / 3, 10, tempView.bounds.size.width / 3, 29);
    btnDelete.layer.cornerRadius = 5;
    btnDelete.layer.masksToBounds = YES;
    [btnDelete addTarget:self action:@selector(deleteItems:) forControlEvents:UIControlEventTouchDown];
    btnDelete.backgroundColor = THEME_COLOR;
    btnDelete.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDelete setTitle:@"删除选中" forState:UIControlStateNormal];
    [btnBgView addSubview:btnDelete];
    
    emptyUpView = [[HintView alloc] initWithFrame:_upTableView.frame];
    [self.view addSubview:emptyUpView];
    
    [emptyUpView createHintViewWithTitle:@"你还没有上传记录哦~" image:[[UIImage imageNamed:@"upload_64"] rt_tintedImageWithColor:[UIColor grayColor]] block:nil];
    
    emptyDownView = [[HintView alloc] initWithFrame:_upTableView.frame];
    [self.view addSubview:emptyDownView];
    [emptyDownView createHintViewWithTitle:@"你还没有下载记录哦~" image:[[UIImage imageNamed:@"download_64"] rt_tintedImageWithColor:[UIColor grayColor]] block:nil];
    
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
    TransferListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[TransferListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
    }
    FileModel *model = dataArray[indexPath.row];
    [cell configWithFileModel:model andCompelet:@{}];
    return cell;
}

- (void)test
{
    for (int i =0; i < dataArray.count; i++) {
        FileModel *model = dataArray[i];
        if (model.fileState == 0) {
            [Utils GET:ApiTypeGetFile params:@{} succeed:^(id response) {
                
            } fail:nil compeletProcess:^(NSInteger done, NSInteger total, float percentage) {
                
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FileModel *fileModel = dataArray[indexPath.row];
        [dataArray removeObject:fileModel];
        if (isUpButtonClicked) {
            [user deleteUpList:fileModel];
        }
        else{
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
    [self normalState];
    sender.selected = YES;
    if([sender.titleLabel.text isEqualToString:@"上传列表"]){
        isUpButtonClicked = YES;
        btnDownload.selected = NO;
        [btnDownload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        dataArray = uploadArray;
        emptyDownView.hidden = YES;
        _scrollView.contentOffset = CGPointMake(0, 0);
        if (dataArray.count == 0) {
            self.currentTableView.hidden = YES;
            emptyUpView.hidden = NO;
        }
        else{
            self.currentTableView.hidden = NO;
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
            self.currentTableView.hidden = YES;
            emptyDownView.hidden = NO;
        }
        else{
            self.currentTableView.hidden = NO;
            [self.currentTableView reloadData];
        }
    }
}


- (void) dobtnRightItem:(UIButton *) sender{
    if (isEditing) {
        [self normalState];
    }
    else{
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        isEditing = YES;
        btnBgView.hidden = NO;
        [self.currentTableView setEditing:YES animated:YES];
    }
}
- (void) deleteItems:(UIButton *) sender{
    UITableView *tempTableView = isUpButtonClicked ? self.upTableView : self.downTableView;
    NSArray *indexPaths = tempTableView.indexPathsForSelectedRows;
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    for (NSIndexPath *indexPath in indexPaths) {
        FileModel *fileModel = dataArray[indexPath.row];
        [dataArray removeObject:fileModel];
        [user deleteDownList:fileModel];
    }
    [tempTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self normalState];
    if (dataArray.count == 0) {
        tempTableView.hidden = YES;
        if (isUpButtonClicked) {
            emptyUpView.hidden = NO;
        }
        else{
            emptyDownView.hidden = NO;
        }
    }
}

- (void) normalState{
    btnBgView.hidden = YES;
    [btnRightItem setTitle:@"编辑" forState:UIControlStateNormal];
    isEditing = NO;
    [self.currentTableView setEditing:NO animated:NO];
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
//        _scrollView.backgroundColor = [UIColor yellowColor];
        _scrollView.frame = CGRectMake(0, CGRectGetMaxY(btnBackView.frame), widith, height);
        _scrollView.contentSize = CGSizeMake(widith * 2,height);
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
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
    NSNumber *done = [dic valueForKey:@"done"];
    NSNumber *compelet = [dic valueForKey:@"compelet"];
    _iconImage.image = [UIImage imageNamed:[Utils ImageNameWithFileType:fileModel.fileType]];
    _nameLabel.text = fileModel.fileName;
    if (fileModel.fileState == 0) {
        _sizeLabel.text = [NSString stringWithFormat:@"正在等待..."];
    } else if(fileModel.fileState == 1) {
        _sizeLabel.text = [NSString stringWithFormat:@"%@k/%luK",done,(unsigned long)fileModel.fileSize / 1024];
    } else {
        _sizeLabel.text = [NSString stringWithFormat:@"已完成:%luK",(unsigned long)fileModel.fileSize / 1024];
    }
    _compeletLabel.text = [NSString stringWithFormat:@"%@%%",compelet];
}
@end
