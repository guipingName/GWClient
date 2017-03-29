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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
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
    model = [Utils aDecoder];
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
        [Utils GET:ApiTypeGetFile params:params succeed:^(id response) {
            if ([response[@"success"] boolValue]) {
                UIImage *image = [response[@"result"][@"images"] firstObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        headImage = image;
                    }
                    [Utils savePhotoWithImage:image imageName:model.headImgUrl];
                });
            }
        } fail:^(NSError * error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    }
    nickNameStr = model.nickName;
    sexStr = model.sex == 1 ? @"男" : model.sex == 2 ? @"女":@"未知";
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
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USERINFOCELL forIndexPath:indexPath];
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
        ModifyHeadIconViewController *headVC = [[ModifyHeadIconViewController alloc] init];
        headVC.image = titleInfoArray[indexPath.section][indexPath.row];
        headVC.imageBlock = ^(UIImage *image){
            NSLog(@"huoqu xintouxiang ");
            [self reloadTableViewWithSection:0 row:0 object:image];
        };
        [self.navigationController pushViewController:headVC animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        // 修改昵称
        ModifyNickNameViewController *nickNameVC = [[ModifyNickNameViewController alloc] init];
        nickNameVC.nickName = titleInfoArray[indexPath.section][indexPath.row];
        nickNameVC.nameStrBlock = ^(NSString *nickName){
            model.nickName = nickName;
            [Utils aCoder:model];
            [self reloadTableViewWithSection:0 row:1 object:nickName];
        };
        [self.navigationController pushViewController:nickNameVC animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        // 修改性别
        ModifySexViewController *sexVC = [[ModifySexViewController alloc] init];
        sexVC.sexStr = titleInfoArray[indexPath.section][indexPath.row];
        sexVC.sexStrBlock = ^(NSString *sexStra){
            if ([sexStra isEqualToString:@"男"]) {
                model.sex = 1;
            }
            else if ([sexStra isEqualToString:@"女"]){
                model.sex = 2;
            }
            [Utils aCoder:model];
            [self reloadTableViewWithSection:1 row:0 object:sexStra];
        };
        [self.navigationController pushViewController:sexVC animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 2) {
        // 修改个性签名
        ModifySignatureViewController *signVC = [[ModifySignatureViewController alloc] init];
        signVC.signatureStr = titleInfoArray[indexPath.section][indexPath.row];
        signVC.signStrBlock = ^(NSString *signStr){
            model.signature = signStr;
            [Utils aCoder:model];
            [self reloadTableViewWithSection:1 row:2 object:signStr];
        };
        [self.navigationController pushViewController:signVC animated:YES];
    }
    else{
        // Todo:
    }
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
