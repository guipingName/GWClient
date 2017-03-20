//
//  SettingViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *myTableView;
    NSArray *dataArray;
    NSArray *detailArray;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, KSCREEN_HEIGHT - 64)];
    [self.view addSubview:myTableView];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[myTableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:SETTINGCELL];
    //[myTableView registerClass:[SetLanguageTableViewCell class] forCellReuseIdentifier:LANGUAGECELL];
    myTableView.rowHeight =  50;
    
    dataArray = @[@"清理缓存"];
    detailArray = @[[NSString stringWithFormat:@"%.2fMB",[self filePath]]];
}

- (void) back{
    [self.navigationController popViewControllerAnimated:YES];
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
    cell.detailTextLabel.text = detailArray[indexPath.row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self clearFile];
    }
}

- ( void )clearFile{
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES ) firstObject];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    for ( NSString *p in files) {
        NSError *error = nil;
        NSString *path = [cachPath stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    }
    [self performSelectorOnMainThread:@selector(clearCachSuccess) withObject:nil waitUntilDone:YES];
}

- (void)clearCachSuccess{
    detailArray = @[[NSString stringWithFormat:@"%.2fMB",[self filePath]]];
    [myTableView reloadData];
}

- (float)filePath {
    NSString *cachPath = [ NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [self folderSizeAtPath:cachPath];
}

- (float)folderSizeAtPath:(NSString *) folderPath{
    NSFileManager *manager = [ NSFileManager defaultManager ];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator ];
    NSString *fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject ]) != nil){
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [ self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize / (1024.0 * 1024.0);
}

- (long long) fileSizeAtPath:( NSString *) filePath{
    NSFileManager * manager = [ NSFileManager defaultManager ];
    if ([manager fileExistsAtPath :filePath]){
        return [[manager attributesOfItemAtPath:filePath error: nil] fileSize];
    }
    return 0;
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
