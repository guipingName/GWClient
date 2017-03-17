//
//  BaseViewController.m
//  warmwind
//
//  Created by guiping on 17/2/21.
//  Copyright © 2017年 galaxyWind. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController (){
    UIImageView *navigationImageView;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = THEME_COLOR;
    
    //[self addNavigationItemImageName:@"bimar关于" target:self action:@selector(back:) isLeft:YES];
    navigationImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    navigationImageView.hidden = YES;
}

-(UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

-(void)addNavigationItemImageName:(NSString *) imageName target:(id)target action:(SEL)selector isLeft:(BOOL)isLeft{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (isLeft) {
        btn.frame = CGRectMake(0, 0, 44, 44);
    }
    else{
        btn.frame = CGRectMake(0, 0, 44, 44);
    }
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchDown];
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    //[btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [view addSubview:btn];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:view];
    if (isLeft) {
        self.navigationItem.leftBarButtonItem = item;
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    }
    else{
        self.navigationItem.rightBarButtonItem = item;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
}


- (void) back:(UIButton *) sender{
    [self.navigationController popViewControllerAnimated:YES];
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
