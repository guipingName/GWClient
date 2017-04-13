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
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            [self addSubview:imageView];
        }
        
        imageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), self.bounds.size.width, 30)];
            [self addSubview:label];
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:14];
        self.hidden = YES;
    }
    return self;
}

- (void)createHintViewWithTitle:(NSString *)title image:(UIImage *)image block:(void (^)())block{
    self.block = block;
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.image = image;
        label.text = title;
    });
    
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
