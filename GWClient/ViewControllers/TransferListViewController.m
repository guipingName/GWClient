//
//  TransferListViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TransferListViewController.h"
#import "GPButton.h"

@interface TransferListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIButton *circleBtn;
    UIButton *squareBtn;
    UITableView *myTableView;
    NSMutableArray *dataArray;
    NSMutableArray *uploadArray;
    NSMutableArray *downloadArray;
}

@end

@implementation TransferListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"传输列表";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(doLogin)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self createViews];
    
    dataArray = [NSMutableArray array];
    uploadArray = [NSMutableArray array];
    downloadArray = [NSMutableArray array];
    for (int i=0; i<10; i++) {
        NSString *str = [NSString stringWithFormat:@"新人上传wenjian第%d篇.doc",i];
        [uploadArray addObject:str];
    }
    
    for (int i=0; i<10; i++) {
        NSString *str = [NSString stringWithFormat:@"下载文件第%d篇.doc",i];
        [downloadArray addObject:str];
    }
    dataArray = uploadArray;
    [myTableView reloadData];
}


- (void) createViews{
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, KSCREEN_WIDTH, 31)];
    btnBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:btnBackView];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, btnBackView.bounds.size.height -1, btnBackView.bounds.size.width, 1.2)];
    lineView.backgroundColor = [UIColor grayColor];
    [btnBackView addSubview:lineView];
    
    circleBtn = [self createButton:@"上传列表"];
    circleBtn.selected = YES;
    [circleBtn setFrame:CGRectMake(btnBackView.bounds.size.width / 4 - 80 / 2, 0, 80, 30)];
    [circleBtn addTarget:self action:@selector(selectedClipType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:circleBtn];
    
    squareBtn = [self createButton:@"下载列表"];
    [squareBtn setFrame:CGRectMake((btnBackView.bounds.size.width + 80) /2, 0, 80, 30)];
    [squareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [squareBtn addTarget:self action:@selector(selectedClipType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:squareBtn];
    
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBackView.frame), KSCREEN_WIDTH, KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame))];
    [self.view addSubview:myTableView];
    myTableView.rowHeight = 50;
    myTableView.delegate = self;
    myTableView.dataSource = self;
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
    cell.textLabel.text = dataArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *str = dataArray[indexPath.row];
        [dataArray removeObject:str];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


- (UIButton *) createButton:(NSString *) title{
    UIButton *button = [GPButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setImage:[UIImage imageNamed:@"bimar背景"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    return button;
}

-(void) selectedClipType:(UIButton *) sender{
    [sender setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    sender.selected = YES;
    if([sender.titleLabel.text isEqualToString:@"上传列表"]){
        squareBtn.selected = NO;
        [squareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        dataArray = uploadArray;
        NSLog(@"uploadArray.count: %lu %lu", (unsigned long)uploadArray.count, (unsigned long)dataArray.count);
        [myTableView reloadData];
    }
    else{
        dataArray = downloadArray;
        [myTableView reloadData];
        circleBtn.selected = NO;
        NSLog(@"downloadArray.count: %lu %lu", (unsigned long)downloadArray.count, (unsigned long)dataArray.count);
        [circleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}


- (void) doLogin{
    NSLog(@"222");
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
