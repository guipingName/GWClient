//
//  FileModel.h
//  GWClient
//
//  Created by guiping on 2017/3/27.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) NSUInteger fileId;

@property (nonatomic, assign) NSUInteger fileTime;

@property (nonatomic, assign) NSUInteger fileType;

@end
