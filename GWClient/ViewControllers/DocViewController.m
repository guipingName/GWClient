//
//  DocViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "DocViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface DocViewController ()<UITableViewDelegate, UITableViewDataSource, TZImagePickerControllerDelegate>{
    UITableView *myTableView;
    NSMutableArray *dataArray;
    NSMutableArray *imageNames;
    NSMutableArray *_selectedAssets;
}

@end

@implementation DocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的网盘";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:NAVIGATION_LEFTBAR] style:UIBarButtonItemStylePlain target:self action:@selector(enterMine)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    //self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    // 测试
    [self createTableView];
    
    

}

- (void) uploadImages:(UIButton *) sedner{
    [self pushImagePickerController];
}

#pragma mark - TZImagePickerController
- (void)pushImagePickerController {
    // 2最多选择2张  4每行显示的数量
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    
    #pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    //imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
     imagePickerVc.navigationBar.barTintColor = THEME_COLOR;
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. 设置是否可以选择视频/图片/原图
    //imagePickerVc.allowPickingVideo = self.allowPickingVideoSwitch.isOn;
    //imagePickerVc.allowPickingImage = self.allowPickingImageSwitch.isOn;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    //imagePickerVc.allowPickingGif = self.allowPickingGifSwitch.isOn;
    
    // 4. 照片排列按修改时间升序
    //imagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch.isOn;
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;

    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    
    // 使用block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        _selectedAssets = [NSMutableArray arrayWithArray:assets];
        dataArray = [photos mutableCopy];
        [self printAssetsName:assets];
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    NSMutableArray *imgNames = [NSMutableArray array];
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        }
        else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        [imgNames addObject:fileName];
        NSLog(@"图片名字:%@",fileName);
    }
    imageNames = imgNames;
    [myTableView reloadData];
    
    // 上传数据
    
    
     UserInfoModel *model = [Utils aDecoder];
     NSDictionary *params = @{@"userId":@(model.userId),
                              @"token":@"123",
                              @"uploadType":@(1),
                              @"imagePaths":imageNames
                              };
     [Utils GET:14 params:params succeed:^(id response) {
         NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
         NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
         NSLog(@"下载图片--返回的Json串:\n%@", tempStr);
         if ([response[@"success"] boolValue]) {
         
         }
     } fail:^(NSError * error) {
         NSLog(@"%@",error.localizedDescription);
     }];
}


- (void)enterMine{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.hidesBottomBarWhenPushed = YES;
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

- (void) createTableView{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 65, KSCREEN_WIDTH - 20, KSCREEN_HEIGHT * 2 / 3)];
    [self.view addSubview:myTableView];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTableView.rowHeight =  50;
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRegister setTitle:@"上传图片" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.backgroundColor = THEME_COLOR;
    btnRegister.frame = CGRectMake(KSCREEN_WIDTH / 2 - 176 / 2, CGRectGetMaxY(myTableView.frame) + 20, 176, 40);
    [self.view addSubview:btnRegister];
    btnRegister.layer.cornerRadius = 5;
    btnRegister.layer.masksToBounds = YES;
    [btnRegister addTarget:self action:@selector(uploadImages:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark --------------- UITableViewDelegate ----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
    }
    cell.imageView.image = dataArray[indexPath.row];
    cell.textLabel.text = imageNames[indexPath.row];
    return cell;
    
}
@end
