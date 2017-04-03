//
//  CalculateManager.m
//  05-函数式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "CalculateManager.h"

@implementation CalculateManager
- (instancetype)calculate:(int (^)(int))calculateBlock
{
    _result =  calculateBlock(_result);
    return self;
}
@end
