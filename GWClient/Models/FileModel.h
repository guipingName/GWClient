//
//  FileModel.h
//  GWClient
//
//  Created by guiping on 2017/3/27.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TransferStatus) {
    TransferStatusReady,
    TransferStatusDuring,
    TransferStatusFinished,
};


typedef NS_ENUM(NSInteger, FileType) {
    FileTypePicture = 1,    // 图片
    FileTypeVideo = 2,      // 视频
};

typedef NS_ENUM(NSInteger, FileTransferType) {
    FileTransferTypeDownload,       // 下载
    FileTransferTypeUpload,         // 上传
};


@interface FileModel : NSObject


@property(nonatomic, assign)TransferStatus fileState;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) NSUInteger fileId;

@property (nonatomic, assign) NSUInteger fileTime;

@property (nonatomic, assign) FileType fileType;

@property (nonatomic, assign) NSUInteger fileSize;

@property (nonatomic, assign) FileTransferType fileOperateType;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSData *videoData;

@property (nonatomic, strong) UIImage *thumbnail;

@end
