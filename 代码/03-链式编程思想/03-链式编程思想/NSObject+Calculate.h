//
//  NSObject+Calculate.h
//  03-链式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CalculateManager.h"

@interface NSObject (Calculate)

/*
    方法设计:自己框架,最好添加一个方法前缀
 */

// 把所有的计算代码放在这里
+ (int)xmg_makeCalculate:(void(^)(CalculateManager *))block;
@end
