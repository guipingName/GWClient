//
//  UserInfoViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoTableViewCell.h"
#import "ModifyNickNameViewController.h"
#import "ModifySignatureViewController.h"
#import "ModifyHeadIconViewController.h"
#import "ModifySexViewController.h"


typedef NS_ENUM(NSInteger, UserInfoSectionType) {
    UserInfoSectionTypeBasic = 0,
    UserInfoSectionTypeOther = 1,
};

typedef NS_ENUM(NSInteger, UserInfoSectionTypeBasicRow) {
    UserInfoSectionTypeBasicRowHead = 0,
    UserInfoSectionTypeBasicRowNickName = 1,
};

typedef NS_ENUM(NSInteger, UserInfoSectionTypeOtherRow) {
    UserInfoSectionTypeOtherSex = 0,
    UserInfoSectionTypeOtherLocation = 1,
    UserInfoSectionTypeOtherSignature = 2,
};

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *myTableView;
    NSArray *titleArray;
    NSMutableArray *titleInfoArray;
    UIImageView *imageView;
    // 信息
    UIImage *headImage;
    NSString *nickNameStr;
    NSString *sexStr;
    NSString *locationStr;
    NSString *signatureStr;
    UserInfoModel *model;
}


@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"个人信息";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, KSCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    [self.view addSubview:myTableView];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [myTableView registerClass:[UserInfoTableViewCell class] forCellReuseIdentifier:USERINFOCELL];
    
    [self infomation];
}

- (void) back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) infomation{
    model = [DataBaseManager sharedManager].currentUser;
    if (!model) {
        return;
    }
    NSArray *systemInfo = @[@"头像", @"昵称"];
    NSArray *WiFi = @[@"性别", @"地区", @"个性签名"];
    titleArray = @[systemInfo, WiFi];
    
    UIImage *image = [Utils getImageWithImageName:model.headImgUrl];
    if (image) {
         headImage = image;
    }
    else{
        headImage = [UIImage imageNamed:DEFAULT_HEAD_IMAGENAME];
        NSDictionary *params = @{@"userId":@(model.userId),
                                 @"token":model.token,
                                 @"type":@(0),
                                 @"imagePaths":@[model.headImgUrl]
                                 };
        [Request GET:ApiTypeGetFile params:params succeed:^(id response) {
            if ([response[@"success"] boolValue]) {
                UIImage *image = [response[@"result"][@"images"] firstObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        headImage = image;
                    }
                    NSData *data = UIImagePNGRepresentation(image);
                    [Utils saveFileWithData:data fileName:model.headImgUrl isPicture:YES];
                });
            }
        } fail:^(NSError * error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
    nickNameStr = model.nickName;
    sexStr = model.gender == 1 ? @"男" : model.gender == 2 ? @"女":@"未知";
    locationStr = model.location;
    signatureStr = model.signature;
    NSMutableArray *img = [@[headImage, nickNameStr] mutableCopy];
    NSMutableArray *img1 = [@[sexStr, locationStr, signatureStr] mutableCopy];
    titleInfoArray = [@[img, img1] mutableCopy];
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
    if (indexPath.section == UserInfoSectionTypeBasic && indexPath.row == UserInfoSectionTypeBasicRowHead) {
        return 70;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == UserInfoSectionTypeBasic) {
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
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USERINFOCELL forIndexPath:indexPath];
    if (indexPath.section == UserInfoSectionTypeBasic && indexPath.row == UserInfoSectionTypeBasicRowHead) {
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
    if (indexPath.section == UserInfoSectionTypeBasic && indexPath.row == UserInfoSectionTypeBasicRowHead) {
        // 修改头像
        ModifyHeadIconViewController *headVC = [[ModifyHeadIconViewController alloc] init];
        headVC.image = titleInfoArray[indexPath.section][indexPath.row];
        headVC.imageBlock = ^(UIImage *image){
            [self reloadTableViewWithSection:indexPath.section row:indexPath.row object:image];
        };
        [self.navigationController pushViewController:headVC animated:YES];
    }
    else if (indexPath.section == UserInfoSectionTypeBasic && indexPath.row == UserInfoSectionTypeBasicRowNickName) {
        // 修改昵称
        ModifyNickNameViewController *nickNameVC = [[ModifyNickNameViewController alloc] init];
        nickNameVC.titleStr = titleArray[indexPath.section][indexPath.row];
        nickNameVC.nickName = titleInfoArray[indexPath.section][indexPath.row];
        nickNameVC.nameStrBlock = ^(NSString *newStr){
            if (newStr.length == 0 || [model.nickName isEqualToString:newStr]) {
                return ;
            }
            model.nickName = newStr;
            NSDictionary *dic = @{@"nickName":model.nickName};
            [self uploadDictionary:dic section:indexPath.section row:indexPath.row];
        };
        [self.navigationController pushViewController:nickNameVC animated:YES];
    }
    else if (indexPath.section == UserInfoSectionTypeOther && indexPath.row == UserInfoSectionTypeOtherSex) {
        // 修改性别
        ModifySexViewController *sexVC = [[ModifySexViewController alloc] init];
        sexVC.sexStr = titleInfoArray[indexPath.section][indexPath.row];
        sexVC.sexStrBlock = ^(NSString *sexStra){
            NSString *aa = titleInfoArray[indexPath.section][indexPath.row];
            if ([aa isEqualToString:sexStra] || sexStra == nil) {
                return ;
            }
            if ([sexStra isEqualToString:@"男"]) {
                model.gender = GenderTypeMan;
            }
            else if ([sexStra isEqualToString:@"女"]){
                model.gender = GenderTypeWoman;
            }
            NSDictionary *dic = @{@"gender":@(model.gender)};
            [self uploadDictionary:dic section:indexPath.section row:indexPath.row];
        };
        [self.navigationController pushViewController:sexVC animated:YES];
    }
    else if (indexPath.section == UserInfoSectionTypeOther && indexPath.row == UserInfoSectionTypeOtherLocation) {
        // 修改地区
        ModifyNickNameViewController *locationVC = [[ModifyNickNameViewController alloc] init];
        locationVC.isLocation = YES;
        locationVC.titleStr = titleArray[indexPath.section][indexPath.row];
        locationVC.nickName = titleInfoArray[indexPath.section][indexPath.row];
        locationVC.nameStrBlock = ^(NSString *newStr){
            if (newStr.length == 0 || [model.location isEqualToString:newStr]) {
                return ;
            }
            model.location = newStr;
            NSDictionary *dic = @{@"location":model.location};
            [self uploadDictionary:dic section:indexPath.section row:indexPath.row];
        };
        [self.navigationController pushViewController:locationVC animated:YES];
    }
    else if (indexPath.section == UserInfoSectionTypeOther && indexPath.row == UserInfoSectionTypeOtherSignature) {
        // 修改个性签名
        ModifySignatureViewController *signVC = [[ModifySignatureViewController alloc] init];
        signVC.isModifySignature = YES;
        signVC.titleStr = titleInfoArray[indexPath.section][indexPath.row];
        signVC.strBlock = ^(NSString *signStr){
            if (signStr.length == 0 || [model.signature isEqualToString:signStr]) {
                return ;
            }
            model.signature = signStr;
            NSDictionary *dic = @{@"signature":model.signature};
            [self uploadDictionary:dic section:indexPath.section row:indexPath.row];
        };
        [self.navigationController pushViewController:signVC animated:YES];
    }
}


#pragma mark --------------- 修改用户信息 ----------------
- (void) uploadDictionary:(NSDictionary *) dic section:(NSUInteger) section row:(NSUInteger) row{
    NSDictionary *paramDic = @{@"userId":@(model.userId),
                               @"token":model.token,
                               @"modifyDic":dic
                               };
    [Request GET:ApiTypeModifyUserInfo params:paramDic succeed:^(id response) {
        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"修改用户信息--返回的Json串:\n%@", tempStr);
        if ([response[@"success"] boolValue]) {
            [Utils aCoder:model];
            [MBProgressHUD showSuccessMessage:@"修改成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dic.allKeys.firstObject isEqualToString:@"gender"]) {
                    NSString *str = [dic.allValues.firstObject integerValue] == GenderTypeMan ? @"男" : model.gender == GenderTypeWoman ? @"女":@"未知";
                    [self reloadTableViewWithSection:section row:row object:str];
                }
                else{
                    [self reloadTableViewWithSection:section row:row object:dic.allValues.firstObject];
                }
            });
        }
        else{
            [MBProgressHUD showErrorMessage:@"修改失败"];
        }
    } fail:^(NSError * error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (void) reloadTableViewWithSection:(NSUInteger) section row:(NSUInteger) row object:(id) object{
    NSMutableArray *array = titleInfoArray[section];
    [array replaceObjectAtIndex:row withObject:object];
    [titleInfoArray replaceObjectAtIndex:section withObject:array];
    [myTableView reloadData];
//    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:section];
//    NSArray *indexArray=[NSArray arrayWithObject:indexPath];
//    [myTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
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
