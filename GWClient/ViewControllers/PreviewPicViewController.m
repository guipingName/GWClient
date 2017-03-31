//
//  PreviewPicViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/31.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "PreviewPicViewController.h"
#import "FileModel.h"

@interface PreviewPicViewController (){
    UIImageView *imageView;
}

@end

@implementation PreviewPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"图片预览";
    self.view.backgroundColor = [UIColor whiteColor];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, KSCREEN_HEIGHT - 64)];
    bgView.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.8);
    [self.view addSubview:bgView];
    
    
    imageView = [[UIImageView alloc] init];
    
    imageView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:imageView];
    UIImage *image = [Utils getImageWithImageName:_model.fileName];
    if (image) {
        imageView.frame = CGRectMake(0, 0, image.size.width > KSCREEN_WIDTH ? KSCREEN_WIDTH:image.size.width, image.size.width>KSCREEN_WIDTH?image.size.height * KSCREEN_WIDTH / image.size.width:image.size.height);
        imageView.center = CGPointMake(KSCREEN_WIDTH / 2, bgView.bounds.size.height / 2);
        imageView.image = image;
    }
    else{
        UserInfoModel *currentUser = [Utils aDecoder];
        NSDictionary *params = @{@"userId":@(currentUser.userId),
                                 @"token":currentUser.token,
                                 @"type":@(_model.fileType),
                                 @"filePaths":@[@(_model.fileId)]
                                 };
        [Utils GET:ApiTypeGetFile params:params succeed:^(id response) {
            if ([response[@"success"] boolValue]) {
                id newObj = [response[@"result"][@"files"] firstObject];
                if ([newObj isKindOfClass:[UIImage class]]) {
                    NSLog(@"下载加载成功 " );
                    UIImage *image = [response[@"result"][@"files"] firstObject];
                    [Utils savePhotoWithImage:image imageName:_model.fileName];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.frame = CGRectMake(0, 0, image.size.width > KSCREEN_WIDTH ? KSCREEN_WIDTH:image.size.width, image.size.width>KSCREEN_WIDTH?image.size.height * KSCREEN_WIDTH / image.size.width:image.size.height);
                        imageView.center = CGPointMake(KSCREEN_WIDTH / 2, bgView.bounds.size.height / 2);
                        imageView.image = image;
                    });
                }
            }
            else{
                [Utils hintMessage:@"下载失败" time:1 isSuccess:NO];
            }
        } fail:^(NSError * error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
