//
//  UserInfoModel.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "UserInfoModel.h"
#import "FileModel.h"
#import "TaskManager.h"

@implementation UserInfoModel



-(BOOL)downloadFile:(FileModel *) fileModel{
    return [[DataBaseManager sharedManager] addFileWithfileId:fileModel fileOperateType:0 userId:_userId];
}

-(NSArray *) downLoadList{
    return [[DataBaseManager sharedManager] loadFileListWithOperateType:0 userId:_userId];
}

- (BOOL)deleteDownList:(FileModel *)fileModel{
    return [[DataBaseManager sharedManager] deleteFileWithFile:fileModel fileOperateType:0 userId:_userId];
}

-(BOOL)uploadFile:(FileModel *)fileModel{
    return [[DataBaseManager sharedManager] addFileWithfileId:fileModel fileOperateType:1 userId:_userId];
}


-(NSArray *)upLoadList{
    return [[DataBaseManager sharedManager] loadFileListWithOperateType:1 userId:_userId];
}

- (BOOL)deleteUpList:(FileModel *)fileModel{
    return [[DataBaseManager sharedManager] deleteFileWithFile:fileModel fileOperateType:1 userId:_userId];
}


-(BOOL)checkDownload:(FileModel *)fileModel{
   return [[DataBaseManager sharedManager] checkDownloadfile:fileModel.fileId userId:_userId];
}

-(void)deleteAllRecord{
    [[DataBaseManager sharedManager] deleteAllRecord];
}













// 归档时要使用的方法
- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (aCoder) {
        [aCoder encodeInteger:_userId forKey:@"userId"];
        [aCoder encodeObject:_token forKey:@"token"];
        [aCoder encodeObject:_nickName forKey:@"nickName"];
        [aCoder encodeObject:_headImgUrl forKey:@"headImgUrl"];
        [aCoder encodeInteger:_age forKey:@"age"];
        [aCoder encodeInteger:_sex forKey:@"sex"];
        [aCoder encodeObject:_location forKey:@"location"];
        [aCoder encodeObject:_signature forKey:@"signature"];
    }
}

// 解归档时要使用的方法
- (instancetype) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        if (aDecoder) {
            _userId = [aDecoder decodeIntegerForKey:@"userId"];
            _token = [aDecoder decodeObjectForKey:@"token"];
            _nickName = [aDecoder decodeObjectForKey:@"nickName"];
            _headImgUrl = [aDecoder decodeObjectForKey:@"headImgUrl"];
            _age = [aDecoder decodeIntegerForKey:@"age"];
            _sex = [aDecoder decodeIntegerForKey:@"sex"];
            _location = [aDecoder decodeObjectForKey:@"location"];
            _signature = [aDecoder decodeObjectForKey:@"signature"];
        }
    }
    return self;
}


@end
