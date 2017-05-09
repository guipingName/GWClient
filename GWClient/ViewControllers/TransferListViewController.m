//
//  TransferListViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TransferListViewController.h"
#import "PreviewPicViewController.h"
#import "TransferListTableViewCell.h"
#import "UpDownBtn.h"
#import "FileModel.h"
#import "Masonry.h"
#import "TaskManager.h"
#import "AppDelegate.h"


@interface TransferListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIButton *btnUpload;
    UIButton *btnDownload;
    NSMutableArray *dataArray;
    NSMutableArray *uploadArray;
    NSMutableArray *downloadArray;
    HintView *emptyUpView;          // 上传空View
    HintView *emptyDownView;        // 下载空View
    BOOL isUpButtonClicked;         // 上传选中
    UIView *btnBackView;
    UserInfoModel *user;
    NSDictionary *progressDic;
    NSDictionary *upDic;
    NSDictionary *downDic;
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
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    
    user = [DataBaseManager sharedManager].currentUser;
    
    
    dataArray = [NSMutableArray array];
    uploadArray = [NSMutableArray array];
    downloadArray = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadData {
    uploadArray = [[TaskManager sharedManager].uploadTaskArray mutableCopy];
    downloadArray = [[TaskManager sharedManager].downloadTaskArray mutableCopy];
    for (FileModel *temp in uploadArray) {
        if (temp.fileType == FileTypePicture) {
            temp.scaleImage = [Utils getImageWithImageName:[NSString stringWithFormat:@"scale_%@", temp.fileName]];
        }
    }
    for (FileModel *temp in downloadArray) {
        if (temp.fileType == FileTypePicture) {
            temp.scaleImage = [Utils getImageWithImageName:[NSString stringWithFormat:@"scale_%@", temp.fileName]];
        }
    }
    
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
    [TaskManager sharedManager].upProcessBlock = ^(NSInteger done, NSInteger total, float progress){
        upDic = @{@"done":@(done),
                  @"compelet":@(progress)
                  };
        //NSLog(@"========上传=============== compelet: %f =============",progress);
        if (dataArray.count > 0) {
            [self.currentTableView reloadData];
        }
    };
    
    [TaskManager sharedManager].downProcessBlock = ^(NSInteger done, NSInteger total, float progress){
        downDic = @{@"done":@(done),
                    @"compelet":@(progress)
                    };
        //NSLog(@"=========下载============== compelet: %f =============",progress);
        if (dataArray.count > 0) {
            [self.currentTableView reloadData];
        }
    };
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
    TransferListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TRANSFERLISTCELL forIndexPath:indexPath];
    FileModel *model = dataArray[indexPath.row];
    [cell configWithFileModel:model andCompelet:progressDic];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FileModel *fileModel = dataArray[indexPath.row];
        [dataArray removeObject:fileModel];
        [self deleteFileWithFileModel:fileModel];
        if (isUpButtonClicked) {
            [TaskManager sharedManager].uploadTaskArray = dataArray;
            [user deleteUpList:fileModel];
        }
        else{
            [TaskManager sharedManager].downloadTaskArray = dataArray;
            [user deleteDownList:fileModel];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
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

#pragma mark --------------- 删除文件 ----------------
- (void) deleteFileWithFileModel:(FileModel *) model{
    NSString *typeStr = nil;
    if (model.fileType == FileTypePicture) {
        typeStr = @"pictures";
    }
    else if (model.fileType == FileTypeVideo){
        typeStr = @"videos";
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@", pathDocuments, typeStr];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",createPath,model.fileName];
    NSString *filePath1 = [NSString stringWithFormat:@"%@/%@",createPath,[NSString stringWithFormat:@"scale_%@", model.fileName]];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    if ([fileManager fileExistsAtPath:filePath1]) {
        [fileManager removeItemAtPath:filePath1 error:nil];
    }
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
        float height = KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49;
        _upTableView = [UITableView new];
        _upTableView.tableFooterView = [UIView new];
        _upTableView.frame = CGRectMake(0, 0, KSCREEN_WIDTH, height);
    }
    return _upTableView;
}

- (UITableView *)downTableView
{
    if (!_downTableView) {
        float height = KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49;
        _downTableView = [UITableView new];
        _downTableView.tableFooterView = [UIView new];
        _downTableView.frame = CGRectMake(KSCREEN_WIDTH, 0, KSCREEN_WIDTH, height);
    }
    return _downTableView;
}

- (UITableView *)currentTableView
{
    _currentTableView = isUpButtonClicked ? self.upTableView : self.downTableView;
    progressDic = isUpButtonClicked ? upDic: downDic;
    _currentTableView.delegate = self;
    _currentTableView.dataSource = self;
    [_currentTableView registerClass:[TransferListTableViewCell class] forCellReuseIdentifier:TRANSFERLISTCELL];
    return _currentTableView;
}
@end



