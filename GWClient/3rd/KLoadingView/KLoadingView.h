//
//  LoadingView.h
//  测试1
//
//  Created by dzk on 16/6/13.
//  Copyright © 2016年 dzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLoadingView : UIView


@property(nonatomic,strong)UIImageView*imageView;
@property(nonatomic,strong)UILabel*titleLabel;

@property(nonatomic,copy) NSString *title;

+ (instancetype)shareDZK;

/**
 *  加载指示器显示
 */
- (instancetype)showKLoadingViewto:(UIView *)view animated:(BOOL)animated;

/**
 *  移除加载指示器
 */
- (void)hideKLoadingViewForView:(UIView *)view animated:(BOOL)animated;


@end
