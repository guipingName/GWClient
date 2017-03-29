//
//  DataBaseManager.h
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileModel;
@interface DataBaseManager : NSObject

/**
 *  创建单例对象
 *
 *  @return DataBaseManager对象
 */
+ (instancetype) sharedManager;

- (BOOL) addFileWithfileId:(FileModel *) model fileOperateType:(NSInteger) fileOperateType userId:(NSInteger) userId;

// operateType 1上传  2 下载
-(NSArray *)loadFileListWithOperateType:(NSInteger) operateType userId:(NSInteger) userId;
// operateType 1上传  2 下载
//-(NSArray *)loadFileListWithOperateType:(NSInteger) operateType;


//-(BOOL)deleteFileWithFileId:(NSInteger)fileId fileOperateType:(NSInteger) fileOperateType;
-(BOOL)deleteFileWithFile:(FileModel *) model fileOperateType:(NSInteger) fileOperateType userId:(NSInteger) userId;
@end