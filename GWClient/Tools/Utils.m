//
//  Utils.m
//  GWClient
//
//  Created by guiping on 2017/3/21.
//  Copyright © 2017年 guiping. All rights reserved.
//


#import "Utils.h"
#import "MBProgressHUD.h"
#import "EXTScope.h"
#import "AppDelegate.h"

@implementation Utils

+(void)aCoder:(UserInfoModel *) model{
    NSMutableData *mData = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mData];
    [archiver encodeObject:model forKey:@"userInfo"];
    [archiver finishEncoding];
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[documentsPath firstObject] stringByAppendingPathComponent:@"userInfo"];
    [mData writeToFile:dbPath atomically:YES];
}

+(UserInfoModel *)aDecoder{
    NSArray *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[documentsPath firstObject] stringByAppendingPathComponent:@"userInfo"];
    NSData *data = [NSData dataWithContentsOfFile:dbPath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    UserInfoModel *model = [unarchiver decodeObjectForKey:@"userInfo"];
    return model;
}

+(UITextField *)createTextField{
    UITextField *tf = [[UITextField alloc] init];
    tf.layer.borderColor = UICOLOR_RGBA(204, 204, 204, 1.0).CGColor;
    tf.layer.borderWidth= 1.0f;
    tf.layer.cornerRadius = 5.0f;
    tf.returnKeyType = UIReturnKeyDone;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    [tf setValue:UICOLOR_RGBA(128, 128, 128, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
    return tf;
}


+ (void)addDialogueBoxWithSuperView:(UIView *)superView Content:(NSString *)content{
    UILabel * label = [[UILabel alloc]init];
    label.text = content;
    label.font = [UIFont systemFontOfSize:22];
    CGRect rect = [content boundingRectWithSize:CGSizeMake(0, 0) options:1 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22]} context:nil];
    label.frame = CGRectMake(15, 10, rect.size.width, rect.size.height);
    label.textColor = [UIColor whiteColor];
    
    UIView * view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, rect.size.width + 30, rect.size.height + 20);
    view.center = CGPointMake(KSCREEN_WIDTH / 2 , KSCREEN_HEIGHT * 3 / 4);
    view.backgroundColor = UICOLOR_RGBA(0, 0, 0,0.8);
    view.layer.cornerRadius = 10;
    [superView addSubview:view];
    [view addSubview:label];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}

+ (UIImage *) getImageWithImageName:(NSString *) imageName{
    NSString * DocumentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/pictures"];
    NSString *imgFileName = [NSString stringWithFormat:@"/%@",imageName];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,imgFileName];
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return img;
}

+ (NSUInteger) saveFileWithData:(NSData *)data fileName:(NSString *) fileName isPicture:(BOOL) isPicture{
    NSString *typeStr = nil;
    if (isPicture) {
        typeStr = @"pictures";
    }
    else{
        typeStr = @"videos";
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/%@", pathDocuments, typeStr];
    if (![fileManager fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",createPath,fileName];
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
    return data.length;
}

+(NSInteger)currentTimeStamp{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return [timeSp integerValue];
}

+ (NSString *)getTimeToShowWithTimestamp:(NSUInteger)timestamp {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *publishString = [formater stringFromDate:startDate];
    return publishString;
}

+ (UIImage *) ImageNameWithFileType:(NSUInteger) fileType{
    NSString *str = nil;
    switch (fileType) {
        case 1:
            str = DEFAULT_HEAD_IMAGENAME;
            break;
        case 2:
            str = @"video";
            break;
        case 3:
            str = @"word";
            break;
        case 4:
            str = @"excel";
            break;
        case 5:
            str = @"pdf";
            break;
        case 6:
            str = @"folder";
        default:
            break;
    }
    return [UIImage imageNamed:str];
}

+ (UIView *) createHintViewWithFrame:(CGRect) frame superView:(UIView *) superView title:(NSString *) title imageName:(NSString *) imageName{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [superView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [view addSubview:imageView];
    imageView.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    imageView.image = [UIImage imageNamed:imageName];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), view.bounds.size.width, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [view addSubview:label];
    view.hidden = YES;
    return view;
}


@end
