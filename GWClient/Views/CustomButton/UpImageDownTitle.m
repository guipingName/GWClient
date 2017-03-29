//
//  upImageDownTitle.m
//  GWClient
//
//  Created by guiping on 2017/3/28.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "UpImageDownTitle.h"

@implementation UpImageDownTitle

- (CGRect) imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake((self.bounds.size.width - 20) / 2, 5, 20, 20);
}


- (CGRect) titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 27, self.bounds.size.width, 20);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
