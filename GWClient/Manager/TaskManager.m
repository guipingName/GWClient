//
//  TaskManager.m
//  GWClient
//
//  Created by guiping on 2017/3/30.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TaskManager.h"
#import "FileModel.h"
#import "UserInfoModel.h"

@implementation TaskManager
{
    NSMutableArray *tempUpArray;
    NSMutableArray *tempDownArray;
}
- (instancetype) init{
    @throw [NSException exceptionWithName:@"初始化对象异常" reason:@"不允许通过初始化方法创建对象" userInfo:nil];
    return self;
}

-(NSMutableArray *)uploadTaskArray{
    if (!_uploadTaskArray) {
        _uploadTaskArray = [NSMutableArray array];
    }
    return _uploadTaskArray;
}

-(NSMutableArray *)downloadTaskArray{
    if (!_downloadTaskArray) {
        _downloadTaskArray = [NSMutableArray array];
    }
    return _downloadTaskArray;
}

- (instancetype) initPrivate{
    if (self = [super init]) {
        tempUpArray = [NSMutableArray array];
        tempDownArray = [NSMutableArray array];
        _uploadTaskArray = [NSMutableArray array];
    }
    return self;
}

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static TaskManager *taskManager = nil;
    dispatch_once(&onceToken, ^{
        if (!taskManager) {
            taskManager = [[TaskManager alloc] initPrivate];
        }
    });
    return taskManager;
}

-(void)reUpload{
    [self upArray:_uploadTaskArray];
}

- (void)reDownload{
    [self downLoadArray:_downloadTaskArray];
}

- (void)upArray:(NSMutableArray *) up {
    tempUpArray = up;
    [self upload];
    
//    NSOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
//        [self upload];
//    }];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    queue.maxConcurrentOperationCount = 2;
//    [queue addOperation:op1];
}

- (void) upload {
    _uploadTaskArray = tempUpArray;
    NSInteger index = [self lookFor:tempUpArray isUpload:YES];
    if (index != -1) {
        FileModel *temp = tempUpArray[index];
        [self uploadFile:temp];
    }
}

- (int)lookFor:(NSArray*) upArray1 isUpload:(BOOL) isUpload{
    for (int i = 0; i < upArray1.count; i++) {
        FileModel *model = upArray1[i];
        if (model.fileState == TransferStatusReady ||
            model.fileState == TransferStatusDuring) {
            model.fileState = TransferStatusDuring;
            return i;
        }
    }
    if (isUpload) {
        NSLog(@"没有上传文件，即将刷新文件列表");
    }
    if (self.sucess) {
       self.sucess(isUpload);
    }
    return -1;
}


- (void) uploadFile:(FileModel *) model{
    __weak typeof(self) weakSelf = self;
    UserInfoModel *user = [DataBaseManager sharedManager].currentUser;
    NSDictionary *fileDic = [NSDictionary dictionary];
    if (model.fileType == FileTypePicture) {
        fileDic = @{model.fileName:[Utils getImageWithImageName:model.fileName]};
    }
    else if (model.fileType == FileTypeVideo) {
        NSString *aa = [NSString stringWithFormat:@"Documents/%@",@"videos"];
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:aa];
        NSString *imgFileName = [NSString stringWithFormat:@"/%@", model.fileName];
        NSString *downLoadfilePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,imgFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:downLoadfilePath]) {
            model.videoData = [NSData dataWithContentsOfFile:downLoadfilePath];
            fileDic = @{model.fileName:model.videoData};
        }
        else{
            model.fileState = TransferStatusFailure;
            [self upload];
            return;
        }
    }
    NSDictionary *params = @{@"userId":@(user.userId),
                             @"token":user.token,
                             @"type":@(model.fileType),
                             @"fileDic":fileDic
                             };
    [Request GET:ApiTypeUpFile params:params succeed:^(id response) {
//        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
//        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
//        NSLog(@"上传图片--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response[@"success"] boolValue]) {
                NSLog(@"上传成功，即将上传下一个文件");
                model.fileState = TransferStatusFinished;
                [weakSelf upload];
            }
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        if (error.code == NO_NETWORK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.upProcessBlock) {
                    weakSelf.upProcessBlock(0, 0, 0.1);
                }
            });
        }
    } compeletProcess:^(NSInteger done, NSInteger total, float percentage) {
        if (isnan(percentage)) {
            percentage = 1.000000;
        }
        //NSLog(@"+++上传+++++++++ 完成=%ld --------全部=%ld,============进度=%f",(long)done, (long)total, percentage);
        if (weakSelf.upProcessBlock) {
            weakSelf.upProcessBlock(done, total, percentage);
        }
    }];
}

-(void)downLoadArray:(NSMutableArray *)downArray{
    tempDownArray = downArray;
    [self download];
}

- (void) download{
    _downloadTaskArray = tempDownArray;
    NSInteger index = [self lookFor:tempDownArray isUpload:NO];
    if (index != -1) {
        FileModel *temp = tempDownArray[index];
        [self downloadFile:temp];
    }
}

- (void) downloadFile:(FileModel *) model{
    __weak typeof(self) weakSelf = self;
    UserInfoModel *user = [DataBaseManager sharedManager].currentUser;
    NSDictionary *params = @{@"userId":@(user.userId),
                             @"token":user.token,
                             @"type":@(model.fileType),
                             @"filePaths":@[@(model.fileId)]
                             };
    [Request downLoad:ApiTypeGetFile params:params succeed:^(id response) {
        if ([response[@"success"] boolValue]) {
            id newObj = [response[@"result"][@"files"] firstObject];
            if ([newObj isKindOfClass:[UIImage class]]) {
                NSLog(@"下载图片成功");
                UIImage *image = [response[@"result"][@"files"] firstObject];
                NSData *data = UIImagePNGRepresentation(image);
                [Utils saveFileWithData:data fileName:model.fileName isPicture:YES];
                model.fileState = TransferStatusFinished;
                [weakSelf download];
            }
            if ([newObj isKindOfClass:[NSData class]]) {
                NSData *data = (NSData *)newObj;
                [Utils saveFileWithData:data fileName:model.fileName isPicture:NO];
                NSLog(@"下载视频成功");
                model.fileState = TransferStatusFinished;
                [weakSelf download];
            }
        }
        else{
            model.fileState = TransferStatusFailure;
            if (weakSelf.downLoadError) {
                weakSelf.downLoadError(nil);
            }
            [weakSelf download];
        }
    } fail:^(NSError * error) {
        NSLog(@"%@", error.localizedDescription);
        if (error.code == NO_NETWORK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.downProcessBlock) {
                    weakSelf.downProcessBlock(0, 0, 0.0);
                }
            });
        }
        else{
            if (weakSelf.downLoadError) {
                weakSelf.downLoadError(error);
            }
        }
    } downLoadProcess:^(NSInteger done, NSInteger total, float percentage) {
        if (isnan(percentage)) {
            percentage = 1.000000;
        }
        //NSLog(@"++++下载++++++++ 完成=%ld --------全部=%ld,============进度=%f",(long)done, (long)total, percentage);
        if (weakSelf.downProcessBlock) {
            weakSelf.downProcessBlock(done, total, percentage);
        }
    }];
}
@end
