//
//  NewsViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsTableViewCell.h"
#import "NewDetailViewController.h"
#import "UpDownBtn.h"
#import "NewsModel.h"

typedef NS_ENUM(NSInteger, BimarOperateButton) {
    BimarOperateButtonTime,                         // 定时设置
    BimarOperateButtonOnOff,                        // 开关
    BimarOperateButtonIncreaseTemperature,          // 增加温度
    BimarOperateButtonWind,                         // 风速控制
    BimarOperateButtonMAX
};

@interface NewsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *dataArray;
    UITableView *newTableView;
    MBProgressHUD *hud;
}

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"最新资讯";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, 31)];
    btnBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:btnBackView];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, btnBackView.bounds.size.height -1, btnBackView.bounds.size.width, 1.2)];
    lineView.backgroundColor = [UIColor grayColor];
    [btnBackView addSubview:lineView];
    NSArray *btnNames = @[@"头条",@"新闻", @"体育", @"NBA"];
    for (int i=0; i<BimarOperateButtonMAX; i++) {
        UIButton *button = [self createButton:btnNames[i]];
        if (i == 0) {
            button.selected = YES;
        }
        button.tag = BTN_NEW_TAG + i;
        [button setFrame:CGRectMake(KSCREEN_WIDTH * i / btnNames.count, 0, KSCREEN_WIDTH / btnNames.count, 30)];
        [button addTarget:self action:@selector(btnTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnBackView addSubview:button];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    newTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBackView.frame), KSCREEN_WIDTH, KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49)];
    [self.view addSubview:newTableView];
    newTableView.backgroundColor = [UIColor clearColor];
    newTableView.delegate = self;
    newTableView.dataSource = self;
    newTableView.rowHeight = 100;
    newTableView.tableFooterView = [[UIView alloc] init];
    [newTableView registerClass:[NewsTableViewCell class] forCellReuseIdentifier:@"NewsTableViewCell"];
    
    [self getNews:btnNames.firstObject];
}

#pragma mark --------------- UITableViewDelegate ----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsTableViewCell" forIndexPath:indexPath];
    cell.model = dataArray[indexPath.row];
    return cell;
}


- (void) btnTypeClicked:(UIButton *) sender{
    for (int i=BTN_NEW_TAG; i<BTN_NEW_TAG + BimarOperateButtonMAX; i++) {
        UIButton *button = [self.view viewWithTag:i];
        button.selected = NO;
    }
    sender.selected = YES;
    NSString *btnTitle = sender.titleLabel.text;
    [self getNews:btnTitle];
}

- (void) getNews:(NSString *) keyWord{
    [MBProgressHUD showActivityMessageInView:@"加载中..."];
    NSDictionary *params = @{@"channel":keyWord,
                             @"start":@(1),
                             @"num":@(10)
                             };
    [Request GET:ApiTypeGetNewsList params:params succeed:^(id response) {
//        NSData *tempData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
//        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
//        NSLog(@"新闻头条--返回的Json串:\n%@", tempStr);
        [MBProgressHUD hideHUD];
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([response[@"success"] boolValue]) {
                NSDictionary *dic = response[@"result"];
                NSArray *array = dic[@"list"];
                if (array.count > 0) {
                    if (!dataArray) {
                        dataArray = [NSMutableArray array];
                    }
                    else{
                        [dataArray removeAllObjects];
                    }
                }
                for (NSDictionary *aa in array) {
                    NewsModel *model = [NewsModel yy_modelWithDictionary:aa];
                    [dataArray addObject:model];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [newTableView reloadData];
                });
            }
            else{
                NSLog(@"新闻列表获取失败");
            }
        }
        else{
            [MBProgressHUD showErrorMessage:GET_ERROR];
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        [MBProgressHUD hideHUD];
        if (error.code == CONNECTION_REFUSED) {
            [MBProgressHUD showErrorMessage:CONNECTION_REFUSED_STR];
        }
    }];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsModel *model = dataArray[indexPath.row];
    NewDetailViewController *detailVC = [[NewDetailViewController alloc] init];
    detailVC.model = model;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UIButton *) createButton:(NSString *) title{
    UIButton *button = [UpDownBtn buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setImage:[UIImage imageNamed:@"bimar背景"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    return button;
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
