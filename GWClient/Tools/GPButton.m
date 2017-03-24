//
//  GPButton.m
//  GWClient
//
//  Created by guiping on 2017/3/23.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "GPButton.h"

@implementation GPButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, contentRect.size.height - 2, contentRect.size.width, 2);
}


-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.height-2);
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
@end
