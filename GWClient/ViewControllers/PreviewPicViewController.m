//
//  PreviewPicViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/31.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "PreviewPicViewController.h"
#import "FileModel.h"
#import "PlayerView.h"

@interface PreviewPicViewController (){
    UIImageView *imageView;
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation PreviewPicViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_isPicture) {
        self.title = @"图片预览";
    }
    else{
        self.title = @"播放器";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, KSCREEN_HEIGHT - 64)];
    bgView.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.8);
    [self.view addSubview:bgView];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicator.center = CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2 );
    [bgView addSubview:activityIndicator];
    
    if (_isPicture) {
        [self showImageView:bgView];
    }
    else{
        [self showPlayerView:bgView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"dealloc %s", object_getClassName(self));
}

- (void) showPlayerView:(UIView *) superView{
    CGRect playerRect = CGRectMake(0, 0, KSCREEN_WIDTH, 200);
    NSString *filePath = [self fileExistPathfileName:_model.fileName isPicture:NO];
    if (filePath) {
        PlayerView *playerView = [[PlayerView alloc]initWithFrame:playerRect playerUrl:filePath];
        playerView.center = CGPointMake(KSCREEN_WIDTH / 2, superView.bounds.size.height / 2);
        playerView.videoTitle = _model.fileName;
        [self.view addSubview:playerView];
        [playerView play];
    }
    else{
        __weak typeof(self) weakSelf = self;
        [activityIndicator startAnimating];
        UserInfoModel *currentUser = [DataBaseManager sharedManager].currentUser;
        NSDictionary *params = @{@"userId":@(currentUser.userId),
                                 @"token":currentUser.token,
                                 @"type":@(_model.fileType),
                                 @"filePaths":@[@(_model.fileId)]
                                 };
        [Request GET:ApiTypeGetFile params:params succeed:^(id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
            });
            if ([response[@"success"] boolValue]) {
                id newObj = [response[@"result"][@"files"] firstObject];
                if ([newObj isKindOfClass:[NSData class]]) {
                    [weakSelf cacheVideoWithData:(NSData *)newObj videoName:_model.fileName];
                    NSLog(@"下载视频成功 ");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showPlayerView:superView];
                    });
                }
            }
            else{
                [MBProgressHUD showErrorMessage:@"查看失败"];
            }
        } fail:^(NSError * error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
            });
            NSLog(@"%@",error.localizedDescription);
        }];
    }
}

- (void) showImageView:(UIView *) superView{
    imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor blackColor];
    [superView addSubview:imageView];
    NSString *filePath = [self fileExistPathfileName:_model.fileName isPicture:YES];
    if (filePath) {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        imageView.frame = CGRectMake(0, 0, image.size.width > KSCREEN_WIDTH ? KSCREEN_WIDTH:image.size.width, image.size.width>KSCREEN_WIDTH?image.size.height * KSCREEN_WIDTH / image.size.width:image.size.height);
        imageView.center = CGPointMake(KSCREEN_WIDTH / 2, superView.bounds.size.height / 2);
        imageView.image = image;
    }
    else{
        [activityIndicator stopAnimating];
        __weak typeof(self) weakSelf = self;
        UserInfoModel *currentUser = [DataBaseManager sharedManager].currentUser;
        NSDictionary *params = @{@"userId":@(currentUser.userId),
                                 @"token":currentUser.token,
                                 @"type":@(_model.fileType),
                                 @"filePaths":@[@(_model.fileId)]
                                 };
        [Request GET:ApiTypeGetFile params:params succeed:^(id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
            });
            if ([response[@"success"] boolValue]) {
                id newObj = [response[@"result"][@"files"] firstObject];
                if ([newObj isKindOfClass:[UIImage class]]) {
                    NSLog(@"图片下载成功 " );
                    UIImage *image = [response[@"result"][@"files"] firstObject];
                    [weakSelf cachePhotoWithImage:image imageName:_model.fileName];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.frame = CGRectMake(0, 0, image.size.width > KSCREEN_WIDTH ? KSCREEN_WIDTH:image.size.width, image.size.width>KSCREEN_WIDTH?image.size.height * KSCREEN_WIDTH / image.size.width:image.size.height);
                        imageView.center = CGPointMake(KSCREEN_WIDTH / 2, superView.bounds.size.height / 2);
                        imageView.image = image;
                    });
                }
            }
            else{
                [MBProgressHUD showErrorMessage:@"查看失败"];
            }
        } fail:^(NSError * error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
            });
            NSLog(@"%@",error.localizedDescription);
        }];
    }
}

#pragma mark --------------- 缓存视频 ----------------
- (void) cacheVideoWithData:(NSData *)data videoName:(NSString *) videoName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches"];
    NSString *createPath = [NSString stringWithFormat:@"%@/videos", pathDocuments];
    if (![fileManager fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/videos/"];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,videoName];
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
}

#pragma mark --------------- 缓存图片 ----------------
- (void) cachePhotoWithImage:(UIImage *)image imageName:(NSString *) imageName{
    NSData *data = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches"];
    NSString *createPath = [NSString stringWithFormat:@"%@/pictures", pathDocuments];
    if (![fileManager fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/pictures/"];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,imageName];
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
}

#pragma mark --------------- 从沙盒中查找文件 ----------------
- (NSString *) fileExistPathfileName:(NSString *) fileName isPicture:(BOOL) isPicture{
    NSString *typeStr = nil;
    if (isPicture) {
        typeStr = @"pictures";
    }
    else{
        typeStr = @"videos";
    }
    NSString *aa = [NSString stringWithFormat:@"Documents/%@",typeStr];
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:aa];
    NSString *imgFileName = [NSString stringWithFormat:@"/%@", fileName];
    NSString *downLoadfilePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,imgFileName];
    //NSLog(@"downLoadfilePath:%@", downLoadfilePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches"];
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@/%@",cachePath, typeStr, fileName];
    //NSLog(@"cacheFilePath:%@", cacheFilePath);
    
    NSString *filePath = nil;
    if ([fileManager fileExistsAtPath:downLoadfilePath]) {
        filePath = downLoadfilePath;
    }
    else if ([fileManager fileExistsAtPath:cacheFilePath]) {
        filePath = cacheFilePath;
    }
    NSLog(@"filePath:%@", filePath);
    return filePath;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
