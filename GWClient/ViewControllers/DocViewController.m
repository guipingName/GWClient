//
//  DocViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "DocViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"
#import "FileModel.h"
#import "FileListTableViewCell.h"
#import "TransforModel.h"
#import "TaskManager.h"
#import "PreviewPicViewController.h"
#import "LoginViewController.h"


@interface DocViewController ()<UITableViewDelegate, UITableViewDataSource, TZImagePickerControllerDelegate>{
    UITableView *myTableView;
    NSMutableArray *dataArray;
    NSMutableArray *_selectedAssets;
    BOOL isEditing;
    BOOL isClickedRight;
    
    NSInteger selectRow;
    float selectRowHeight;
    HintView *emptyView;
    UserInfoModel *user;
    UIView *clearView;
    MBProgressHUD *hud;
}

@end

@implementation DocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"我的网盘";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:NAVIGATION_LEFTBAR] style:UIBarButtonItemStylePlain target:self action:@selector(enterMine)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upload_24"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClicked)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    dataArray = [NSMutableArray array];
    user = [DataBaseManager sharedManager].currentUser;
    // 测试
    [self createTableView];
    [self creatRightItem];
    [self fileList];
    
    selectRowHeight = 50;
    selectRow = -1;
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isClickedRight = NO;
    clearView.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enterMine{
    isClickedRight = NO;
    clearView.hidden = YES;
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) rightItemClicked{
    isClickedRight = !isClickedRight;
    if (isClickedRight) {
        clearView.hidden = NO;
    }
    else{
        clearView.hidden = YES;
    }
}

- (void) fileList{
    __weak typeof(self) weakSelf = self;
    NSDictionary *params = @{@"userId":@(user.userId),
                             @"token":user.token
                             };
    [Request GET:ApiTypeGetUserFileList params:params succeed:^(id response) {
//        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
//        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
//        NSLog(@"文件列表--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response[@"success"] boolValue]) {
                NSDictionary *dic = response[@"result"];
                NSArray *array = dic[@"fileList"];
                if (dataArray) {
                    [dataArray removeAllObjects];
                }
                for (NSDictionary *ddic in array) {
                    FileModel *model = [FileModel yy_modelWithDictionary:ddic];
                    [dataArray addObject:model];
                }
                //NSLog(@"文件列表个数: %lu", (unsigned long)dataArray.count);
                if (dataArray.count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        emptyView.hidden = YES;
                        myTableView.hidden = NO;
                        [myTableView reloadData];
                    });
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        myTableView.hidden = YES;
                        emptyView.hidden = NO;
                    });
                }
            }
            else{
                if ([response[@"message"] isEqualToString:@"非法登录"]) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"已在其它设备登录，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *new = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                        [userDef setBool:NO forKey:IS_HAS_LOGIN];
                        [userDef synchronize];
                        LoginViewController *loginVC = [[LoginViewController alloc] init];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                        self.view.window.rootViewController = nav;
                    }];
                    [alertController addAction:new];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [emptyView createHintViewWithTitle:@"加载失败，点击再试一次" image:[UIImage imageNamed:@"folder"] block:^{
                            [weakSelf fileList];
                        }];
                        myTableView.hidden = YES;
                        emptyView.hidden = NO;
                    });
                }
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                myTableView.hidden = YES;
                emptyView.hidden = NO;
            });
        }
    } fail:^(NSError * error) {
        NSLog(@"%ld %@",(long)error.code, error.localizedDescription);
        if (error.code != NO_NETWORK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [emptyView createHintViewWithTitle:@"加载失败，点击再试一次" image:[UIImage imageNamed:@"folder"] block:^{
                    [weakSelf fileList];
                }];
                myTableView.hidden = YES;
                emptyView.hidden = NO;
            });
        }
    }];
}

- (void) uploadImages:(UIButton *) sedner{
    [self pushImagePickerController:YES];
}

- (void) uploadVodeos:(UIButton *) sedner{
    [self pushImagePickerController:NO];
}


#pragma mark --------------- UITableViewDelegate ----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == selectRow) {
        return selectRowHeight;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FileListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    cell.model = dataArray[indexPath.row];
    cell.cellOn = indexPath.row == selectRow ? NO : YES;
    [cell setOnOffBlock:^(BOOL on) {
        selectRow = on? indexPath.row : -1;
        selectRowHeight = on? 100 : 50;
        [tableView reloadData];
    }];
    [cell setDeleteBlock:^(FileModel *tempModel) {
        [self deleteFile:tempModel indexPaths:@[indexPath]];
    }];
    [cell setDownLoadBlock:^(FileModel *tempModel) {
        [self downLoadFile:tempModel];
    }];
    return cell;
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


#pragma mark --------------- TZImagePickerController ----------------
- (void)pushImagePickerController:(BOOL) isPicture {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.navigationBar.barTintColor = THEME_COLOR;
    if (isPicture) {
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingOriginalPhoto = YES;
    }
    else{
        imagePickerVc.allowPickingVideo = YES;
        imagePickerVc.allowPickingImage = NO;
    }
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

// 图片回调
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    [self printAssets:assets photos:photos];
}

#pragma mark --------------- 上传图片 ----------------
- (void) printAssets:(NSArray *)assets photos:(NSArray *) photos{
    NSString *fileName = nil;
    NSMutableArray *ImageArray = [NSMutableArray array];
    NSMutableArray *imageNames = [NSMutableArray array];
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        }
        else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        [imageNames addObject:fileName];
    }
    [ImageArray addObjectsFromArray:photos];
    NSMutableArray *images = [NSMutableArray array];
    for (int i=0; i<ImageArray.count; i++) {
        FileModel *model = [[FileModel alloc] init];
        model.fileState = TransferStatusReady;
        model.fileType = FileTypePicture;
        model.fileName = imageNames[i];
        UIImage *image = ImageArray[i];
        model.fileSize = [Utils savePhotoWithImage:image imageName:model.fileName];
        [images addObject:model];
    }
    
    NSMutableArray *temp = [TaskManager sharedManager].uploadTaskArray;
    [temp addObjectsFromArray:images];
    [[TaskManager sharedManager] setSucess:^(BOOL success) {
        if (success) {
            [self fileList];
        }
    }];
    [[TaskManager sharedManager] upArray:temp];
    //[MBProgressHUD showActivityMessageInView:@"正在上传" timer:1];
}


// 视频回调
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    if ([asset isKindOfClass:[PHAsset class]]) {
        [self video:asset];
    }
}

#pragma mark --------------- 上传视频 ----------------
- (void) video:(PHAsset *) asset{
    __weak typeof(self) weakSelf = self;
    NSArray * assetResources = [PHAssetResource assetResourcesForAsset: asset];
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo || assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = nil;
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    if (!fileName) {
        NSDate *datenow = [NSDate date];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentTime = [formater stringFromDate:datenow];
        fileName = [NSString stringWithFormat:@"%@.MOV", currentTime];
    }
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        NSLog(@"111111111");
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            NSURL *url = urlAsset.URL;
            NSData *data = [NSData dataWithContentsOfURL:url];
            //[Utils saveVideoWithData:data videoName:@"2017.MOV"];
            NSLog(@"%@  data.length:%.2f M",url, (unsigned long)data.length /(1024.0 * 1024));
            
            // 准备上传视频
            FileModel *model = [[FileModel alloc] init];
            model.fileState = TransferStatusReady;
            model.fileType = FileTypeVideo;
            model.fileName = fileName;
            model.videoData = data;
            model.fileSize = data.length;
            NSMutableArray *temp = [TaskManager sharedManager].uploadTaskArray;
            [temp addObject:model];
            [[TaskManager sharedManager] setSucess:^(BOOL success) {
                if (success) {
                    [weakSelf fileList];
                }
            }];
            [[TaskManager sharedManager] upArray:temp];
        }];
    }
    else {
        NSLog(@"失败");
    }
}


// Gif图片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    
}


#pragma mark --------------- 删除文件 ----------------
- (void) deleteFile:(FileModel *) file indexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    NSDictionary *params = @{@"userId":@(user.userId),
                             @"deleteFileIds":@[@(file.fileId)],
                             @"token":user.token
                             };
    [Request GET:ApiTypeDeleteFiles params:params succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"删除文件列表--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response[@"success"] boolValue]) {
                [dataArray removeObject:file];
                selectRow = -1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showSuccessMessage:@"删除成功"];
                    [myTableView reloadData];
                    if (dataArray.count == 0) {
                        [emptyView createHintViewWithTitle:@"这里是空的~" image:[UIImage imageNamed:@"folder"] block:nil];
                        myTableView.hidden = YES;
                        emptyView.hidden = NO;
                    }
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showErrorMessage:@"删除失败"];
                });
            }
        }
    } fail:^(NSError * error) {
        NSLog(@"error.code:%ld %@", (long)error.code, error.localizedDescription);
        if (error.code != NO_NETWORK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showErrorMessage:@"删除失败"];
            });
        }
    }];
}

#pragma mark --------------- 下载文件 ----------------
- (void) downLoadFile:(FileModel *) file{
    
    NSMutableArray *temp = [TaskManager sharedManager].downloadTaskArray;
    for (FileModel *model in temp) {
        if (model.fileId == file.fileId) {
            [MBProgressHUD showErrorMessage:@"不能重复下载"];
            return;
        }
    }
    file.fileState = TransferStatusReady;
    [temp addObject:file];
    [[TaskManager sharedManager] downLoadArray:temp];
    [MBProgressHUD showSuccessMessage:@"已加入下载列表"];
}


#pragma mark --------------- createViews ----------------
- (void) creatRightItem{
    clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, KSCREEN_HEIGHT - 64 -49)];
    [self.view addSubview:clearView];
    clearView.backgroundColor = [UIColor clearColor];
    clearView.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelView:)];
    [clearView addGestureRecognizer:tap];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH - 110, 0, 100, 88)];
    [clearView addSubview:bgView];
    bgView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self drawTriangle]];
    imageView.frame = CGRectMake(bgView.bounds.size.width - 20, 1, 6, 6);
    [bgView addSubview:imageView];

    
    UIView *btnBg = [[UIView alloc] initWithFrame:CGRectMake(0, 7, bgView.bounds.size.width, bgView.bounds.size.height - 7)];
    [bgView addSubview:btnBg];
    btnBg.layer.cornerRadius = 4;
    btnBg.layer.masksToBounds = YES;
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegister setTitle:@"上传图片" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont systemFontOfSize:13];
    btnRegister.backgroundColor = [UIColor blackColor];
    btnRegister.frame = CGRectMake(0, 0, btnBg.bounds.size.width, 40);
    [btnBg addSubview:btnRegister];
    [btnRegister addTarget:self action:@selector(uploadImages:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 40, btnBg.bounds.size.width, 1)];
    line.backgroundColor = [UIColor grayColor];
    [btnBg addSubview:line];
    
    UIButton *btnVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnVideo setTitle:@"上传视频" forState:UIControlStateNormal];
    [btnVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnVideo.titleLabel.font = [UIFont systemFontOfSize:13];
    btnVideo.backgroundColor = [UIColor blackColor];
    btnVideo.frame = CGRectMake(0, 41, bgView.bounds.size.width, 40);
    [btnBg addSubview:btnVideo];
    [btnVideo addTarget:self action:@selector(uploadVodeos:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) createTableView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, KSCREEN_WIDTH, KSCREEN_HEIGHT - 65 - 49)];
    [self.view addSubview:myTableView];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.hidden = YES;
    myTableView.tableFooterView = [[UIView alloc] init];
    [myTableView registerClass:[FileListTableViewCell class] forCellReuseIdentifier:@"CELL"];
    
    emptyView = [[HintView alloc] initWithFrame:myTableView.frame];
    [self.view addSubview:emptyView];
    
    [emptyView createHintViewWithTitle:@"这里是空的~" image:[UIImage imageNamed:@"folder"] block:nil];
    emptyView.hidden = NO;
}



- (UIImage *)drawTriangle {
    int Trianglewidth = 3;
    UIGraphicsBeginImageContextWithOptions( CGSizeMake(2 * Trianglewidth, 2 * Trianglewidth), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, Trianglewidth, 0);
    CGContextAddLineToPoint(context, 2 * Trianglewidth, 2 * Trianglewidth);
    CGContextAddLineToPoint(context, 0, 2 * Trianglewidth);
    CGContextSetLineWidth(context, 2);
    CGContextClosePath(context);
    [[UIColor blackColor] setFill];
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

- (void) cancelView:(UITapGestureRecognizer *) sender{
    clearView.hidden = YES;
    isClickedRight = !isClickedRight;
}
@end

