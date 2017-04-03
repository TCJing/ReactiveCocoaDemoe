//
//  CalculateManager.h
//  05-函数式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//  专门处理运算

#import <Foundation/Foundation.h>


@interface CalculateManager : NSObject

@property (nonatomic, assign) int result;

// 计算
- (instancetype)calculate:(int(^)(int))calculateBlock;

@end
