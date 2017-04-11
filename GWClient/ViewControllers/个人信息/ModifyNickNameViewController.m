//
//  ModifyViewController.m
//  GWClient
//
//  Created by guiping on 2017/3/20.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "ModifyNickNameViewController.h"
#import <CoreLocation/CoreLocation.h>

#define LOCATION_ERROR  @"定位失败"

@interface ModifyNickNameViewController ()<UITextFieldDelegate, CLLocationManagerDelegate>
{
    UITextField *tfNickname;
    UILabel *lbLocation;
    UIActivityIndicatorView *juhua;
    UIImageView *imageView;
}
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ModifyNickNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = _titleStr;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    
    tfNickname = [self createTextField];
    [self.view addSubview:tfNickname];
    tfNickname.delegate = self;
    tfNickname.text = _nickName;
    
    if (_isLocation) {
        tfNickname.placeholder = @"请设置您所在的城市";
        tfNickname.frame = CGRectMake(10, 150, KSCREEN_WIDTH - 20, 40);
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, KSCREEN_WIDTH, 25)];
        lb.font = [UIFont systemFontOfSize:15];
        lb.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:lb];
        lb.text = @"定位到您的位置:";
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, KSCREEN_WIDTH - 20, 46)];
        [self.view addSubview:bgView];
        bgView.backgroundColor = [UIColor lightGrayColor];
        bgView.layer.cornerRadius = 5;
        
        
        
        juhua = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(5, 8, 30, 30)];
        juhua.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [bgView addSubview:juhua];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 30, 30)];
        imageView.hidden = YES;
        imageView.image = [UIImage imageNamed:@"location"];
        [bgView addSubview:imageView];
        
        lbLocation = [[UILabel alloc] initWithFrame:CGRectMake(45, 8, 200, 30)];
        lbLocation.font = [UIFont systemFontOfSize:18];
        lbLocation.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:lbLocation];
        lbLocation.text = @"定位中...";
        
        
        lbLocation.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
        [lbLocation addGestureRecognizer:tap];
        [self requestLocation];
    }
    else{
        tfNickname.frame = CGRectMake(10, 80, KSCREEN_WIDTH - 20, 40);
        tfNickname.placeholder = @"设置昵称";
    }
}


-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 5;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void) requestLocation{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else if (status == kCLAuthorizationStatusDenied){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"定位服务已关闭,请在设置中开启定位服务" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *new = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:new];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        [self.locationManager startUpdatingLocation];
        [juhua startAnimating];
    }
}


#pragma mark - CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"不允许");
    }
    else{
        [manager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    if (locations.count > 0) {
        [juhua stopAnimating];
        imageView.hidden = NO;
        CLLocation *location = [locations lastObject];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
            if (array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                NSString *cityName = placemark.locality;
                if (!cityName) {
                    cityName = placemark.administrativeArea;
                }
                lbLocation.text = [NSString stringWithFormat:@"%@%@", cityName, placemark.subLocality];
            }
            else if (error == nil && [array count] == 0) {
                NSLog(@"No results were returned.");
                lbLocation.text = LOCATION_ERROR;
            }
            else if (error != nil) {
                NSLog(@"An error occurred = %@", error);
                lbLocation.text = LOCATION_ERROR;
            }
        }];
        [manager stopUpdatingLocation];
    }
}



- (void) doTap:(UITapGestureRecognizer *) sender{
    if ([lbLocation.text isEqualToString:LOCATION_ERROR] || [lbLocation.text isEqualToString:@"定位中..."]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (_nameStrBlock) {
        _nameStrBlock(lbLocation.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) done{
    if (_nameStrBlock) {
        _nameStrBlock(tfNickname.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --------------- UITextFieldDelegate ----------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField becomeFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([tfNickname becomeFirstResponder]) {
        [tfNickname resignFirstResponder];
    }
}

- (UITextField *) createTextField{
    UITextField *tf = [[UITextField alloc] init];
    tf.layer.borderColor = UICOLOR_RGBA(204, 204, 204, 1.0).CGColor;
    tf.layer.borderWidth= 1.0f;
    tf.layer.cornerRadius = 5.0f;
    tf.returnKeyType = UIReturnKeyDone;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    [tf setValue:UICOLOR_RGBA(128, 128, 128, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
    return tf;
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
