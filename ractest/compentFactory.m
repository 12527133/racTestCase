//
//  compentFactory.m
//  ractest
//
//  Created by bao on 2018/11/4.
//  Copyright © 2018年 bao. All rights reserved.
//

#import "compentFactory.h"

@implementation compentFactory

+ (UIButton *)button:(NSString *)title frame:(CGRect)frame parent:(UIView *)parent {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = frame;
    button.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
    if (parent) {
        [parent addSubview:button];
    }
    return button;
}
@end
