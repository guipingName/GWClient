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

/**上传、下载状态*/
@property(nonatomic, assign)TransferStatus fileState;

/**文件名*/
@property (nonatomic, copy) NSString *fileName;

/**文件Id*/
@property (nonatomic, assign) NSUInteger fileId;

/**上传时间*/
@property (nonatomic, assign) NSUInteger fileTime;

/**文件类型*/
@property (nonatomic, assign) FileType fileType;

/**文件大小*/
@property (nonatomic, assign) NSUInteger fileSize;

/**文件操作类型(上传、下载)*/
@property (nonatomic, assign) FileTransferType fileOperateType;

/**图片url(如果是图片)*/
@property (nonatomic, copy) NSString *imagePath;

/**视频数据(如果是视频)*/
@property (nonatomic, strong) NSData *videoData;

/**缩略图*/
@property (nonatomic, strong) UIImage *thumbnail;

@end
