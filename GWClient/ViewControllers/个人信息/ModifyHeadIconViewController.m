//
//  ModifyHeadIconViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/22.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ModifyHeadIconViewController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"


@interface ModifyHeadIconViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, TZImagePickerControllerDelegate>
{
    UIImageView *_imageView;
}

@end

@implementation ModifyHeadIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"个人头像";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = (_image.size.height / _image.size.width) * self.view.frame.size.width;
    
    _imageView = [[UIImageView alloc]init];
    [_imageView setImage:_image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_imageView setFrame:CGRectMake(0, 0, width, height)];
    [_imageView setCenter:self.view.center];
    [self.view addSubview:_imageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bimar关于"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked)];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_imageBlock) {
        _imageBlock(_imageView.image);
    }
}


- (void) rightBarButtonClicked{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *new = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self chooseFromLibrary];
    }];
    UIAlertAction *old = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:new];
    [alertController addAction:old];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void) takePhoto{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 相机可用
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else{
        // 相机不可用
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"相机不可用" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    // 允许编辑
    ipc.allowsEditing = YES;
    
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}


- (void) chooseFromLibrary{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.navigationBar.barTintColor = THEME_COLOR;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = YES;
    imagePickerVc.needCircleCrop = NO;
    imagePickerVc.circleCropRadius = 120;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSString *fileName;
    id asset = assets.firstObject;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        fileName = [phAsset valueForKey:@"filename"];
    }
    else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        fileName = alAsset.defaultRepresentation.filename;;
    }
    //NSLog(@"图片名字:%@",fileName);
    UIImage *image = photos.firstObject;
    [self upLoadHeadImge:image imageName:fileName];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset){
        //NSLog(@"ALAssetPropertyDate:%@",[myasset valueForProperty:ALAssetPropertyDate]);
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        NSString *fileName = [representation filename];
        NSLog(@"fileName %@", fileName);
        [self upLoadHeadImge:image imageName:@"20170330"];
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:imageURL
                   resultBlock:resultblock
                  failureBlock:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) upLoadHeadImge:(UIImage *) image imageName:(NSString *) imageName{
    [MBProgressHUD showActivityMessageInView:@"正在上传"];
    UserInfoModel *model = [Utils aDecoder];
    NSDictionary *paramDic = @{@"userId":@(model.userId),
                               @"token":model.token,
                               @"type":@(0),
                               @"fileDic":@{imageName:image}
                               };
    [Utils GET:ApiTypeUpFile params:paramDic succeed:^(id response) {
//        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
//        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
//        NSLog(@"修改用户头像--返回的Json串:\n%@", tempStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        if ([response[@"success"] boolValue]) {
            _imageView.image = image;
            [Utils savePhotoWithImage:image imageName:model.headImgUrl];
            model.headImgUrl = [response[@"result"][@"imagePaths"] firstObject];
            [Utils aCoder:model];
            //NSLog(@"model.headImgUrl  修改头像:%@", model.headImgUrl);
        }
    } fail:^(NSError * error) {
        NSLog(@"%@",error.localizedDescription);
    }];
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
