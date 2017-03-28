//
//  TransferListViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/17.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "TransferListViewController.h"
#import "UpDownBtn.h"

@interface TransferListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIButton *btnUpload;
    UIButton *btnDownload;
    UITableView *myTableView;
    NSMutableArray *dataArray;
    NSMutableArray *uploadArray;
    NSMutableArray *downloadArray;
    BOOL isEditing;
    UIButton *btnRightItem;
    UIView *btnBgView;
    UIView *emptyUpView;
    UIView *emptyDownView;
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
    
    // 右边项
     btnRightItem = [UIButton buttonWithType:UIButtonTypeCustom];
     btnRightItem.frame = CGRectMake(0, 0, 50, 30);
     [btnRightItem addTarget:self action:@selector(dobtnRightItem:) forControlEvents:UIControlEventTouchDown];
     btnRightItem.titleLabel.font = [UIFont systemFontOfSize:17];
     [btnRightItem setTitle:@"编辑" forState:UIControlStateNormal];
     [btnRightItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [btnRightItem setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRightItem];
    
    
    
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
    
    btnUpload = [self createButton:@"上传列表"];
    btnUpload.selected = YES;
    [btnUpload setFrame:CGRectMake(btnBackView.bounds.size.width / 4 - 80 / 2, 0, 80, 30)];
    [btnUpload addTarget:self action:@selector(selectedListType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:btnUpload];
    
    btnDownload = [self createButton:@"下载列表"];
    [btnDownload setFrame:CGRectMake((btnBackView.bounds.size.width + 80) /2, 0, 80, 30)];
    [btnDownload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnDownload addTarget:self action:@selector(selectedListType:) forControlEvents:UIControlEventTouchUpInside];
    [btnBackView addSubview:btnDownload];
    
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnBackView.frame), KSCREEN_WIDTH, KSCREEN_HEIGHT - CGRectGetMaxY(btnBackView.frame) - 49)];
    [self.view addSubview:myTableView];
    myTableView.rowHeight = 50;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.allowsMultipleSelectionDuringEditing = YES;
    
    
    btnBgView = [[UIView alloc] initWithFrame:CGRectMake(0, KSCREEN_HEIGHT - 49 - 50, KSCREEN_WIDTH, 49)];
    btnBgView.hidden = YES;
    btnBgView.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.5);
    [self.view addSubview:btnBgView];
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnBgView.bounds.size.width, btnBgView.bounds.size.height)];
    tempView.backgroundColor = UICOLOR_RGBA(0, 0, 0, 0.5);
    //[btnBgView addSubview:tempView];
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.frame = CGRectMake(tempView.bounds.size.width / 3, 10, tempView.bounds.size.width / 3, 29);
    btnDelete.layer.cornerRadius = 5;
    btnDelete.layer.masksToBounds = YES;
    [btnDelete addTarget:self action:@selector(deleteItems:) forControlEvents:UIControlEventTouchDown];
    btnDelete.backgroundColor = THEME_COLOR;
    btnDelete.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDelete setTitle:@"删除选中" forState:UIControlStateNormal];
    [btnBgView addSubview:btnDelete];
    
    
    emptyUpView = [[UIView alloc] initWithFrame:myTableView.frame];
    [self.view addSubview:emptyUpView];
    UIImageView *upImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [emptyUpView addSubview:upImv];
    upImv.center = emptyUpView.center;
    upImv.image = [UIImage imageNamed:@"upload"];
    UILabel *lbUp = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(upImv.frame), emptyUpView.bounds.size.width, 30)];
    lbUp.textAlignment = NSTextAlignmentCenter;
    lbUp.text = @"你还没有传输记录哦~";
    emptyUpView.hidden = YES;
    [emptyUpView addSubview:lbUp];
    
    emptyDownView = [[UIView alloc] initWithFrame:myTableView.frame];
    [self.view addSubview:emptyDownView];
    UIImageView *downImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [emptyDownView addSubview:downImv];
    downImv.center = emptyUpView.center;
    downImv.image = [UIImage imageNamed:@"download"];
    UILabel *lbDown = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(downImv.frame), emptyUpView.bounds.size.width, 30)];
    lbDown.textAlignment = NSTextAlignmentCenter;
    lbDown.text = @"你还没有传输记录哦~";
    [emptyDownView addSubview:lbDown];
    emptyDownView.hidden = YES;
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
    UIButton *button = [UpDownBtn buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setImage:[UIImage imageNamed:@"bimar背景"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    return button;
}

-(void) selectedListType:(UIButton *) sender{
    [sender setTitleColor:UICOLOR_RGBA(250, 126, 20, 1.0) forState:UIControlStateNormal];
    [self normalState];
    sender.selected = YES;
    if([sender.titleLabel.text isEqualToString:@"上传列表"]){
        btnDownload.selected = NO;
        [btnDownload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        dataArray = uploadArray;
        NSLog(@"uploadArray.count: %lu %lu", (unsigned long)uploadArray.count, (unsigned long)dataArray.count);
        [myTableView reloadData];
    }
    else{
        dataArray = downloadArray;
        [myTableView reloadData];
        btnUpload.selected = NO;
        NSLog(@"downloadArray.count: %lu %lu", (unsigned long)downloadArray.count, (unsigned long)dataArray.count);
        [btnUpload setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}


- (void) dobtnRightItem:(UIButton *) sender{
    if (isEditing) {
        [self normalState];
    }
    else{
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        isEditing = YES;
        btnBgView.hidden = NO;
        [myTableView setEditing:YES animated:YES];
    }
}
- (void) deleteItems:(UIButton *) sender{
    NSArray *indexPaths = myTableView.indexPathsForSelectedRows;
    indexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    for (NSIndexPath *indexPath in indexPaths) {
        //NSString *str = dataArray[indexPath.row];
        [dataArray removeObjectAtIndex:indexPath.row];
    }
    [myTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self normalState];
}

- (void) normalState{
    btnBgView.hidden = YES;
    [btnRightItem setTitle:@"编辑" forState:UIControlStateNormal];
    isEditing = NO;
    [myTableView setEditing:NO animated:NO];
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
