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
    NSMutableArray *upArray;
    NSMutableArray *tempDownArray;
}
- (instancetype) init{
    @throw [NSException exceptionWithName:@"初始化对象异常" reason:@"不允许通过初始化方法创建对象" userInfo:nil];
    return self;
}

- (instancetype) initPrivate{
    if (self = [super init]) {
        upArray = [NSMutableArray array];
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


- (void)upArray:(NSMutableArray *) up {
    upArray = up;
    [self upload];
    
}

- (int)lookFor:(NSArray*) upArray1 isUpload:(BOOL) isUpload{
    for (int i = 0; i < upArray1.count; i++) {
        FileModel *model = upArray1[i];
        if (model.fileState == 0) {
            model.fileState = 1;
            return i;
        }
    }
    if (self.sucess) {
       self.sucess(isUpload);
    }
    return -1;
}

- (void) upload {
    _uploadTaskArray = upArray;
    NSInteger index = [self lookFor:upArray isUpload:YES];
    if (index != -1) {
        FileModel *temp = upArray[index];
        
        [self uploadFile:temp];
    }
}

- (void) uploadFile:(FileModel *) model{
    UserInfoModel *user = [Utils aDecoder];
    NSDictionary *ddd;
    if (model.fileType == 1) {
        ddd = @{model.fileName:model.image};
    }
    else if (model.fileType == 2) {
        ddd = @{model.fileName:model.videoData};
    }
    NSDictionary *params = @{@"userId":@(user.userId),
                             @"token":user.token,
                             @"type":@(model.fileType),
                             @"fileDic":ddd
                             };
    [Utils GET:ApiTypeUpFile params:params succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"上传图片--返回的Json串:\n%@", tempStr);
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response[@"success"] boolValue]) {
                // 上传成功 修改本地记录
                model.fileState = 2;
                [self upload];
            }
        }
    } fail:^(NSError *error) {
        
    } compeletProcess:^(NSInteger done, NSInteger total, float percentage) {
        NSLog(@"++++++++++++ 完成=%ld --------全部=%ld,============进度=%f",(long)done, (long)total, percentage);
        self.done = done;
        self.compelet = percentage;
        if (self.processBlock) {
            self.processBlock(done, total, percentage);
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
    UserInfoModel *user = [Utils aDecoder];
    NSDictionary *params = @{@"userId":@(user.userId),
                             @"token":user.token,
                             @"type":@(model.fileType),
                             @"filePaths":@[@(model.fileId)]
                             };
    [Utils downLoad:ApiTypeGetFile params:params succeed:^(id response) {
        if ([response[@"success"] boolValue]) {
            id newObj = [response[@"result"][@"files"] firstObject];
            if ([newObj isKindOfClass:[UIImage class]]) {
                NSLog(@"下载图片成功 " );
                UIImage *image = [response[@"result"][@"files"] firstObject];
                [Utils savePhotoWithImage:image imageName:model.fileName];
                model.fileState = 2;
                [self download];
            }
            if ([newObj isKindOfClass:[NSData class]]) {
                NSData *dataaa = (NSData *)newObj;
                [Utils saveVideoWithData:dataaa videoName:model.fileName];
                NSLog(@"下载视频成功 ");
                model.fileState = 2;
                [self download];
            }
        }
        else{
            //[Utils hintMessage:@"下载失败" time:1 isSuccess:NO];
        }
    } fail:^(NSError * error) {
        NSLog(@"%@",error.localizedDescription);
    } downLoadProcess:^(NSInteger done, NSInteger total, float percentage) {
        NSLog(@"++++++++++++ 完成=%ld --------全部=%ld,============进度=%f",(long)done, (long)total, percentage);
        self.done = done;
        self.compelet = percentage;
        if (self.processBlock) {
            self.processBlock(done, total, percentage);
    }
}];
}
@end
