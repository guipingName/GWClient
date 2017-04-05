//
//  FileModel.m
//  GWClient
//
//  Created by guiping on 2017/3/27.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel

- (NSUInteger)fileSize
{
    
    if (_fileType == FileTypePicture) {
        if (_image) {
            NSData *data = UIImagePNGRepresentation(_image);
            return data.length;
        }
    }
    
    if (_fileType == FileTypeVideo) {
        if (_videoData) {
            return  _videoData.length;
        }
    }
    
    return _fileSize;
}

@end
