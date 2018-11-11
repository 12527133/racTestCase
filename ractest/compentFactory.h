//
//  compentFactory.h
//  ractest
//
//  Created by bao on 2018/11/4.
//  Copyright © 2018年 bao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface compentFactory : NSObject

+ (UIButton *)button:(NSString *)title frame:(CGRect)frame parent:(UIView *)parent;

@end

NS_ASSUME_NONNULL_END
