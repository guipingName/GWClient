//
//  UserInfoViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoTableViewCell.h"
#import "ModifyViewController.h"


@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UITableView *myTableView;
    NSArray *titleArray;
    NSArray *titleInfoArray;
}


@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"个人信息";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, KSCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    [self.view addSubview:myTableView];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [myTableView registerClass:[UserInfoTableViewCell class] forCellReuseIdentifier:@"UserInfoTableViewCell"];
    
    [self infomation];
}

- (void) back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) infomation{
    NSArray *systemInfo = @[@"头像", @"昵称"];
    NSArray *WiFi = @[@"性别", @"地区", @"个性签名"];
    titleArray = @[systemInfo, WiFi];
    NSArray *img = @[@"bimar模式大火", @"这里是昵称"];
    NSArray *img1 = @[@"男", @"成都", @"还没有设置个性签名"];
    titleInfoArray = @[img, img1];
    [myTableView reloadData];
}

#pragma mark --------------- UITableViewDelegate ----------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = titleArray[section];
    return array.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.00001f;
    }
    return 40;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = UICOLOR_RGBA(230, 231, 232, 1.0);
    return label;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserInfoTableViewCell" forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.isHead = YES;
    }
    else{
        cell.isHead = NO;
    }
    cell.subtitle = titleInfoArray[indexPath.section][indexPath.row];
    cell.title = titleArray[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 修改头像
        [self modifyPhoto];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        // 修改昵称
        //[self presentViewController:[[ModifyViewController alloc] init] animated:YES completion:nil];
        [self.navigationController pushViewController:[[ModifyViewController alloc] init] animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 2) {
        // 修改个性签名
    }
    else{
        // Todo:
    }
}

- (void) modifyPhoto{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.allowsEditing = YES;
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


// 选中照片的回调方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 原始图片UIImagePickerControllerOriginalImage
    // 编辑图片UIImagePickerControllerEditImage
    //imageView.image = info [UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --------------- UITableViewDelegate ----------------

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
