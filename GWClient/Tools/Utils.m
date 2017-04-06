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

+ (void) showMessage:(NSString *) message superView:(UIView *) superView{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中...";
    hud.userInteractionEnabled = NO;
}

+ (void) hintMessage:(NSString *) message time:(int)time isSuccess:(BOOL) isSuccess{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isSuccess) {
            [MBProgressHUD showSuccessMessage:message];
        }
        else{
            [MBProgressHUD showErrorMessage:message];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });
}

+ (void) hintMessage:(NSString *) message superView:(UIView *) superView hud:(MBProgressHUD *) hud{
    if (![superView.subviews containsObject:hud]) {
        hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    }
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = message;
    hud.userInteractionEnabled = NO;
}

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
    label.font = [UIFont systemFontOfSize:15];
    CGRect rect = [content boundingRectWithSize:CGSizeMake(0, 0) options:1 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    label.frame = CGRectMake(15, 5, rect.size.width, rect.size.height);
    label.textColor = [UIColor whiteColor];
    UIView * view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, rect.size.width + 30, rect.size.height + 10);
    view.center = CGPointMake(KSCREEN_WIDTH / 2 , KSCREEN_HEIGHT * 3 / 4);
    view.backgroundColor = UICOLOR_RGBA(0, 0, 0,0.8);
    view.layer.cornerRadius = 8;
    [superView addSubview:view];
    [view addSubview:label];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}


+ (NSUInteger) savePhotoWithImage:(UIImage *)image imageName:(NSString *) imageName{
    NSData *data = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/pictures", pathDocuments];
    if (![fileManager fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * DocumentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/pictures"];
    NSString *imgFileName = [NSString stringWithFormat:@"/%@",imageName];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,imgFileName];
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
    return data.length;
}

+ (UIImage *) getImageWithImageName:(NSString *) imageName{
    NSString * DocumentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/pictures"];
    NSString *imgFileName = [NSString stringWithFormat:@"/%@",imageName];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@",DocumentsPath,imgFileName];
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    return img;
}


+ (void) saveVideoWithData:(NSData *)data videoName:(NSString *) videoName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    NSString *createPath = [NSString stringWithFormat:@"%@/videos", pathDocuments];
    //NSLog(@"createPath: %@", createPath);
    if (![fileManager fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * DocumentsPath = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/videos"];
    NSString *imgFileName = [NSString stringWithFormat:@"/%@",videoName];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:imgFileName] contents:data attributes:nil];
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

+ (NSString *) ImageNameWithFileType:(NSUInteger) fileType{
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
    return  str;
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
