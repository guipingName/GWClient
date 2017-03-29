//
//  HintView.m
//  GWClient
//
//  Created by guiping on 2017/3/29.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "HintView.h"

@implementation HintView{
    UIImageView *imageView;
    UILabel *label;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)createHintViewWithTitle:(NSString *)title image:(UIImage *)image block:(void (^)())block{
    self.block = block;
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    }
    [self addSubview:imageView];
    imageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    imageView.image = image;
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), self.bounds.size.width, 30)];
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [self addSubview:label];
    self.hidden = YES;
}

- (void) doTap:(UITapGestureRecognizer *) sender{
    if (self.block) {
        self.block();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
