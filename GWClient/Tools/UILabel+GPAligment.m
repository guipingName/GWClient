//
//  UILabel+GPAligment.m
//  Objective_test
//
//  Created by guiping on 17/2/28.
//  Copyright © 2017年 guiping. All rights reserved.
//

#import "UILabel+GPAligment.h"
#import <CoreText/CoreText.h>

@implementation UILabel (GPAligment)

-(void) setAlignmentLeftAndRight{
    CGSize textSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size;
    CGFloat margin = (self.frame.size.width - textSize.width) / (self.text.length -1);
    NSNumber *number = [NSNumber numberWithFloat:margin];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributeString addAttribute:(id)kCTKernAttributeName value:number range:NSMakeRange(0, self.text.length - 1)];
    self.attributedText = attributeString;
}

@end
