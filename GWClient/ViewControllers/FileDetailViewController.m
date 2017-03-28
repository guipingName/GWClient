//
//  FileDetailViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/24.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "FileDetailViewController.h"
#import "FileCollectionViewCell.h"

@interface FileDetailViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *myCollectionView;
    NSMutableArray *dataArray;
    BOOL isEditing;
}

@end

@implementation FileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createButton];
    [self createCollectionView];
}

- (void) createButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 30);
    [button addTarget:self action:@selector(onEditAction:) forControlEvents:UIControlEventTouchDown];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.2 alpha:1] forState:0];
    [button setTitle:@"编辑" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void) onEditAction:(UIButton *) sender{
    // 判断是否处于编辑状态
    if (isEditing) {
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        isEditing = NO;
    }
    else{
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        isEditing = YES;
    }
    // 刷新UICollectionView
    [myCollectionView reloadData];
}

- (void) createCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_WIDTH, KSCREEN_HEIGHT - 64 - 49) collectionViewLayout:layout];
    
    myCollectionView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:myCollectionView];
    // 单元格的大小
    layout.itemSize = CGSizeMake(KSCREEN_WIDTH / 4, KSCREEN_WIDTH * 2 / 7);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(20, KSCREEN_WIDTH / 18, 10, KSCREEN_WIDTH / 18);
    
    myCollectionView.dataSource = self;
    myCollectionView.delegate = self;
    
    [myCollectionView registerClass:[FileCollectionViewCell class] forCellWithReuseIdentifier:@"FileCollectionViewCell"];
    [self loadData];
}

- (void) loadData{
    if (!dataArray) {
        dataArray = [NSMutableArray array];
    }
    for (int i=0; i<15; i++) {
        NSString *str = [NSString stringWithFormat:@"第 %d 行",i];
        [dataArray addObject:str];
    }
    [myCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileCollectionViewCell" forIndexPath:indexPath];
    
    cell.fileName = dataArray[indexPath.row];
    if (isEditing) {
        cell.deleteButton.hidden = NO;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction animations:^{
            cell.transform = CGAffineTransformMakeRotation(0.05);
        } completion:nil];
    }
    else{
        cell.deleteButton.hidden = YES;
    }
    cell.transform = CGAffineTransformIdentity;
    [cell.deleteButton addTarget:self action:@selector(onDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void) onDeleteAction:(UIButton *) sender{
    FileCollectionViewCell *cell = (FileCollectionViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [myCollectionView indexPathForCell:cell];
    NSString *model = dataArray[indexPath.row];
    [dataArray removeObject:model];
    [myCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [myCollectionView reloadData];
    });

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isEditing) {
//        FoodModel *model = dataArray[indexPath.row];
//        DetailViewController *detailVC = [[DetailViewController alloc] init];
//        detailVC.hidesBottomBarWhenPushed = YES;
//        detailVC.model = model;
//        [self.navigationController pushViewController:detailVC animated:YES];
    }
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
