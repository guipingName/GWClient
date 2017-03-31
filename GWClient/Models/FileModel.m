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
    
    if (self.image) {
        NSData *data = UIImagePNGRepresentation(self.image);
        return data.length;
    }
    return _fileSize;
}

@end
