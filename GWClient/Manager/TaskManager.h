//
//  TaskManager.h
//  GWClient
//
//  Created by guiping on 2017/3/30.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FileModel;
@interface TaskManager : NSObject


@property (nonatomic, strong) NSMutableArray *uploadTaskArray;

@property (nonatomic, strong) NSMutableArray *downloadTaskArray;

@property(nonatomic, copy)void (^sucess)(BOOL);
@property(nonatomic, copy)void (^downLoadError)(NSError * error);

@property(nonatomic, copy)void (^upProcessBlock)(NSInteger done, NSInteger total, float percentage);
@property(nonatomic, copy)void (^downProcessBlock)(NSInteger done, NSInteger total, float percentage);

+ (instancetype) sharedManager;

- (void)upArray:(NSMutableArray *) up;

- (void) reUpload;

- (void) downLoadArray:(NSMutableArray *) downArray;

- (void) reDownload;
@end
