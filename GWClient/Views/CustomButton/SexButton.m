//
//  SexButton.m
//  GWClient
//
//  Created by guiping on 2017/3/27.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "SexButton.h"

@implementation SexButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(contentRect.size.width - 40, (contentRect.size.height - 30) / 2, 30, 30);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(10, 0, contentRect.size.width - 40, contentRect.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
