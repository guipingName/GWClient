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
#import "FileDetailViewController.h"
#import "TZImageManager.h"
#import "FileModel.h"
#import "FileListTableViewCell.h"


@interface DocViewController ()<UITableViewDelegate, UITableViewDataSource, TZImagePickerControllerDelegate>{
    UITableView *myTableView;
    NSMutableArray *dataArray;
    NSMutableArray *_selectedAssets;
    BOOL isEditing;
    UIView *bgView;
    BOOL isClickedRight;
    
    NSInteger selectRow;
    float selectRowHeight;
    HintView *emptyView;
    UserInfoModel *user;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Upload_38"] style:UIBarButtonItemStylePlain target:self action:@selector(upload)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    dataArray = [NSMutableArray array];
    user = [Utils aDecoder];
    // 测试
    [self createTableView];
    [self creatRightItem];
    [self fileList];
    
    selectRowHeight = 50;
    selectRow = -1;
    
    
}

- (void)enterMine{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) upload{
    isClickedRight = !isClickedRight;
    if (isClickedRight) {
        bgView.hidden = NO;
    }
    else{
        bgView.hidden = YES;
    }
}

- (void) fileList{
    NSLog(@"请求文件列表相关数据");
    NSDictionary *params = @{@"userId":@(user.userId),
                             @"token":user.token
                             };
    [Utils GET:ApiTypeGetUserFileList params:params succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"获取文件列表--返回的Json串:\n%@", tempStr);
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [emptyView createHintViewWithTitle:@"加载失败，点击再试一次" image:[UIImage imageNamed:@"download_64"] block:^{
                        [self fileList];
                    }];
                    myTableView.hidden = YES;
                    emptyView.hidden = NO;
                });
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                myTableView.hidden = YES;
                emptyView.hidden = NO;
            });
        }
    } fail:^(NSError * error) {
        NSLog(@"%@",error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            myTableView.hidden = YES;
            emptyView.hidden = NO;
        });
    }];
}

- (void) btnOpenFile:(UIButton *) sedner{
    FileDetailViewController *VC = [[FileDetailViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void) uploadImages:(UIButton *) sedner{
    isClickedRight = !isClickedRight;
    bgView.hidden = YES;
    [self pushImagePickerController:YES];
}

- (void) uploadVodeos:(UIButton *) sedner{
    isClickedRight = !isClickedRight;
    bgView.hidden = YES;
    [self pushImagePickerController:NO];
}

#pragma mark - TZImagePickerController
- (void)pushImagePickerController:(BOOL) isPicture {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    
   //imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
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

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    //_selectedAssets = [NSMutableArray arrayWithArray:assets];
    // 打印图片名字
    [self printAssetsName:assets photis:photos];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        // Export completed, send video here, send by outputPath or NSData
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
        NSData *data = [NSData dataWithContentsOfFile:outputPath];
        //NSLog(@"data: %@", data);
        UserInfoModel *model = [Utils aDecoder];
        NSDictionary *params = @{@"userId":@(model.userId),
                                  @"token":model.token,
                                  @"type":@(2),
                                 @"fileDic":@{@"2017-03-27-16:30:42.mp4":data}
                                  };
        [Utils GET:ApiTypeUpFile params:params succeed:^(id response) {
            NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
            NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
            NSLog(@"上传视频--返回的Json串:\n%@", tempStr);
            if ([response isKindOfClass:[NSDictionary class]]) {
                if ([response[@"success"] boolValue]) {
                    [self fileList];
                }
            }
        } fail:^(NSError * error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }];
    [myTableView reloadData];
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    //dataArray = [NSMutableArray arrayWithArray:@[animatedImage]];
    //_selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    //[myTableView reloadData];
}


// 打印图片名字
- (void)printAssetsName:(NSArray *)assets photis:(NSArray *) photos{
    NSString *fileName;
    NSMutableArray *imgNames = [NSMutableArray array];
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        }
        else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        [imgNames addObject:fileName];
        //NSLog(@"图片名字:%@",fileName);
    }
    // 上传图片
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:photos forKeys:imgNames];
    NSDictionary *params = @{@"userId":@(user.userId),
                              @"token":user.token,
                              @"type":@(1),
                              @"fileDic":dic
                              };
    [Utils GET:ApiTypeUpFile params:params succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"上传图片--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response[@"success"] boolValue]) {
                [self fileList];
            }
        }
    } fail:^(NSError * error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isClickedRight = !isClickedRight;
    bgView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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
    [emptyView createHintViewWithTitle:@"还没有文件哦~" image:[UIImage imageNamed:@"download"] block:nil];
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
    
    [cell setDeleteBlock:^(FileModel *aa) {
        UserInfoModel *model = [Utils aDecoder];
        NSDictionary *params = @{@"userId":@(model.userId),
                                 @"deleteFileIds":@[@(aa.fileId)],
                                 @"token":model.token
                                 };
        [Utils GET:ApiTypeDeleteFiles params:params succeed:^(id response) {
            NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
            NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
            NSLog(@"删除文件列表--返回的Json串:\n%@", tempStr);
            if ([response isKindOfClass:[NSDictionary class]]) {
                if ([response[@"success"] boolValue]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [dataArray removeObject:aa];
                        selectRow = -1;
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        if (dataArray.count == 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                myTableView.hidden = YES;
                                emptyView.hidden = NO;
                            });
                        }
                    });
                }
            }
        } fail:^(NSError * error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }];
    
    [cell setDownLoadBlock:^(FileModel *tempModel) {
        [user downloadFile:tempModel];
        NSDictionary *params = @{@"userId":@(user.userId),
                                 @"token":user.token,
                                 @"type":@(1),
                                 @"filePaths":@[@(tempModel.fileId)]
                                 };
        [Utils GET:ApiTypeGetFile params:params succeed:^(id response) {
            if ([response[@"success"] boolValue]) {
                //UIImage *image = [response[@"result"][@"files"] firstObject];
                id newObj = [response[@"result"][@"files"] firstObject];
                if ([newObj isKindOfClass:[UIImage class]]) {
                    NSLog(@"下载图片成功 " );
                }
                if ([newObj isKindOfClass:[NSData class]]) {
                    NSLog(@"下载视频成功 " );
                }
            }
        } fail:^(NSError * error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }];
    return cell;
    
}

- (void) creatRightItem{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH - 90, 64, 80, 68)];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self drawTriangle]];
    imageView.frame = CGRectMake(bgView.bounds.size.width - 20, 1, 6, 6);
    [bgView addSubview:imageView];
    bgView.hidden = YES;
    
    UIView *btnBg = [[UIView alloc] initWithFrame:CGRectMake(0, 7, bgView.bounds.size.width, bgView.bounds.size.height - 7)];
    [bgView addSubview:btnBg];
    btnBg.layer.cornerRadius = 4;
    btnBg.layer.masksToBounds = YES;
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegister setTitle:@"上传图片" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont systemFontOfSize:13];
    btnRegister.backgroundColor = [UIColor blackColor];
    btnRegister.frame = CGRectMake(0, 0, bgView.bounds.size.width, 30);
    [btnBg addSubview:btnRegister];
    [btnRegister addTarget:self action:@selector(uploadImages:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 30, bgView.bounds.size.width, 1)];
    line.backgroundColor = [UIColor grayColor];
    [btnBg addSubview:line];
    
    UIButton *btnVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnVideo setTitle:@"上传视频" forState:UIControlStateNormal];
    [btnVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnVideo.titleLabel.font = [UIFont systemFontOfSize:13];
    btnVideo.backgroundColor = [UIColor blackColor];
    btnVideo.frame = CGRectMake(0, 31, bgView.bounds.size.width, 30);
    [btnBg addSubview:btnVideo];
    [btnVideo addTarget:self action:@selector(uploadVodeos:) forControlEvents:UIControlEventTouchUpInside];
    
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

@end

