//
//  HintView.h
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^GPBlock)();

@interface HintView : UIView

@property (nonatomic, copy) GPBlock block;

- (void)createHintViewWithTitle:(NSString *)title image:(UIImage *)image block:(void (^)())block;
@end
