//
//  DataBaseManager.m
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "DataBaseManager.h"
#import "FileModel.h"

@implementation DataBaseManager{
    FMDatabase *_fmdb;
}

- (instancetype) init{
    @throw [NSException exceptionWithName:@"初始化对象异常" reason:@"不允许通过初始化方法创建对象" userInfo:nil];
    return self;
}

- (instancetype) initPrivate{
    if (self = [super init]) {
        [self creatDataBase];
    }
    return self;
}

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static DataBaseManager *dataManager = nil;
    dispatch_once(&onceToken, ^{
        if (!dataManager) {
            dataManager = [[DataBaseManager alloc] initPrivate];
        }
    });
    return dataManager;
}

- (void) creatDataBase{
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[documentsPath firstObject] stringByAppendingPathComponent:@"fileTransferList.db"];
    NSLog(@"%@",dbPath);
    
    if (!_fmdb) {
        _fmdb = [[FMDatabase alloc] initWithPath:dbPath];
    }
    if ([_fmdb open]) {
        [_fmdb executeUpdate:@"create Table if not exists fileTransferList (fileId, fileName,fileTime,fileSize, fileType, fileOperateType, userId);"];
    }
}

- (BOOL) addFileWithfileId:(FileModel *) model fileOperateType:(NSInteger) fileOperateType userId:(NSInteger) userId{
    return [_fmdb executeUpdate:@"insert into fileTransferList (fileName, fileId, fileTime,fileSize, fileType, fileOperateType, userId) values (?,?,?,?,?,?,?);", model.fileName, @(model.fileId), @([Utils currentTimeStamp]), @(model.fileSize), @(model.fileType), @(model.fileOperateType), @(userId)];
}

// operateType 0下载  1上传 
-(NSArray *)loadFileListWithOperateType:(NSInteger) operateType userId:(NSInteger) userId{
    NSString *str = [NSString stringWithFormat:@"select *from fileTransferList where fileOperateType = %ld and userId = %ld;", (long)operateType, (long)userId];
    FMResultSet *rs = [_fmdb executeQuery:str];
    NSMutableArray *devices = [NSMutableArray array];
    while ([rs next]) {
        FileModel *model = [[FileModel alloc] init];
        model.fileName = [rs stringForColumn:@"fileName"];
        model.fileId = [rs longLongIntForColumn:@"fileId"];
        model.fileTime = [rs intForColumn:@"fileTime"];
        model.fileSize = [rs intForColumn:@"fileSize"];
        model.fileType = [rs intForColumn:@"fileType"];
        model.fileOperateType = [rs intForColumn:@"fileOperateType"];
        [devices addObject:model];
    }
    return [devices copy];
}


-(BOOL)deleteFileWithFile:(FileModel *) model fileOperateType:(NSInteger) fileOperateType userId:(NSInteger) userId{
    NSString *str = [NSString stringWithFormat:@"delete from fileTransferList where fileId = %ld and fileOperateType = %ld and userId = %ld;",(long)model.fileId, (long)fileOperateType, (long)userId];
    return [_fmdb executeUpdate:str];
}

//-(BOOL)deleteFileWithFileId:(NSInteger)fileId fileOperateType:(NSInteger) fileOperateType{
//    NSString *str = [NSString stringWithFormat:@"delete from fileTransferList where fileId = %ld and fileOperateType = %ld;",(long)fileId, (long)fileOperateType];
//    return [_fmdb executeUpdate:str];
//}





@end
