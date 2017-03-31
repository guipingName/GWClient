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
    UserInfoModel *user;
    NSMutableArray *array;
}
- (instancetype) init{
    @throw [NSException exceptionWithName:@"初始化对象异常" reason:@"不允许通过初始化方法创建对象" userInfo:nil];
    return self;
}

- (instancetype) initPrivate{
    if (self = [super init]) {
        user = [Utils aDecoder];
        array = [NSMutableArray array];
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


- (void)upArray:(NSMutableArray *) up
{
    array = up;
    [self upload];

}
- (int)findUp:(NSArray*) upArray {
    for (int i = 0; i < upArray.count; i++) {
        FileModel *model = upArray[i];
        if (model.fileState == 0) {
            model.fileState = 1;
            return i;
        }
    }
    self.sucess(YES);
    _uploadTaskArray = array;
    return -1;
}



- (void) upload
{
    NSInteger index = [self findUp:array];
    _uping = index;
    if (index != -1) {
        FileModel *temp = array[index];
        
        [self uploadFile:temp];
    }
}


- (void) uploadFile:(FileModel *) model{
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

- (void)setDownloadTaskArray:(NSMutableArray *)downloadTaskArray
{
    if (downloadTaskArray.count > 0) {
        
    }
}
@end
