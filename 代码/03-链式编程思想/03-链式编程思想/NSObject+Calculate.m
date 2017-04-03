//
//  NSObject+Calculate.m
//  03-链式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "NSObject+Calculate.h"
#import "CalculateManager.h"

@implementation NSObject (Calculate)
+ (int)xmg_makeCalculate:(void (^)(CalculateManager *))block
{
    // 创建计算管理者
    CalculateManager *mgr = [[CalculateManager alloc] init];
    
    // 执行计算
    block(mgr);
    
    return mgr.result;
}
@end
