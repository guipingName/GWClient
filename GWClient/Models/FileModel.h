//
//  FileModel.h
//  GWClient
//
//  Created by guiping on 2017/3/27.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject


/**
 0: 未开始下载 1: 正在下载 2: 下载完成
 */
@property(nonatomic, assign)NSInteger fileState;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) NSUInteger fileId;

@property (nonatomic, assign) NSUInteger fileTime;

@property (nonatomic, assign) NSUInteger fileType;

@property (nonatomic, assign) NSUInteger fileSize;

@property (nonatomic, assign) NSUInteger fileOperateType;

@end
