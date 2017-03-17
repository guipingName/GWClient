//
//  BaseViewController.h
//  warmwind
//
//  Created by guiping on 17/2/21.
//  Copyright © 2017年 galaxyWind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

/**
 *  设置导航项
 *
 *  @param imageName  图片名称
 *  @param target  目标对象
 *  @param selector  选择器
 *  @param isLeft  是否是左边项
 *
 */
- (void) addNavigationItemImageName:(NSString *) imageName target:(id)target action:(SEL)selector isLeft:(BOOL)isLeft;

/**
 *  leftItem点击事件
 *
 */
- (void) back:(UIButton *) sender;
@end
