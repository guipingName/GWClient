//
//  ModifyHeadIconViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/22.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ModifyHeadIconViewController.h"
#import "PhotoEdittViewController.h"

#import <AssetsLibrary/ALAssetsLibrary.h>

#import <AssetsLibrary/ALAssetsGroup.h>

#import <AssetsLibrary/ALAssetRepresentation.h>

@interface ModifyHeadIconViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, ClipViewControllerDelegate>
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
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = (_image.size.height / _image.size.width) * self.view.frame.size.width;
    
    _imageView = [[UIImageView alloc]init];
    [_imageView setImage:_image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_imageView setFrame:CGRectMake(0, 0, width, height)];
    [_imageView setCenter:self.view.center];
    [self.view addSubview:_imageView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bimar关于"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

}

- (void) back{
    if (_imageBlock) {
        _imageBlock(_imageView.image);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) rightBarButtonClicked{
    [self modifyPhoto];
}

- (void) modifyPhoto{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:ipc animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
            ipc.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:ipc animated:YES completion:nil];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *ima = info[@"UIImagePickerControllerOriginalImage"];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        
        //NSLog(@"ALAssetPropertyDate:%@",[myasset valueForProperty:ALAssetPropertyDate]);
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        NSString *fileName = [representation filename];
         PhotoEdittViewController * clipView = [[PhotoEdittViewController alloc]initWithImage:ima imageName:fileName];
        NSLog(@"fileName %@", fileName);
        clipView.delegate = self;
        clipView.clipType = 1; //支持圆形(默认) 方形裁剪
        clipView.radius = 120;   //设置 裁剪框的半径  默认120
        //clipView.scaleRation = 5;// 图片缩放的最大倍数 默认为10
        [picker pushViewController:clipView animated:YES];
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:imageURL
                   resultBlock:resultblock
                  failureBlock:nil];
}

#pragma mark - ClipViewControllerDelegate
-(void)ClipViewController:(PhotoEdittViewController *)clipViewController FinishClipImage:(UIImage *)editImage imageName:(NSString *)imageName{
    [clipViewController dismissViewControllerAnimated:YES completion:^{
        //NSData *data = UIImagePNGRepresentation(editImage);
        //NSLog(@"data1.length:%lu", (unsigned long)data.length);
        //UIImage *im2 = [self imageWithImage:editImage scaledToSize:CGSizeMake(40, 40)];
        //NSData *data1 = UIImagePNGRepresentation(im2);
        //NSLog(@"data2.length:%lu", (unsigned long)data1.length);
        //NSLog(@"imageName %@", imageName);
        UserInfoModel *model = [Utils aDecoder];
        
        NSDictionary *params = @{@"userId":@(model.userId),
                                 @"token":@"123",
                                 @"uploadType":@(1),
                                 @"images":@[editImage],
                                 @"imgNames":@[imageName]
                                 };
        [Utils GETaa:14 params:params succeed:^(id response) {
            NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
            NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
            NSLog(@"修改用户头像--返回的Json串:\n%@", tempStr);
            if ([response[@"success"] boolValue]) {
                _imageView.image = editImage;
            }
        } fail:^(NSError * error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }];;
}

- (UIImage *)imageWithImage:(UIImage*)image
               scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
