//
//  CalculateManager.m
//  03-链式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "CalculateManager.h"

@implementation CalculateManager

//- (instancetype)add:(int)value
//{
//    _result += value;
//    
//    return self;
//}

- (CalculateManager * (^)(int))add
{
    
    return ^(int value){
        _result += value;
        
        return self;
        
    };
    
}
@end
