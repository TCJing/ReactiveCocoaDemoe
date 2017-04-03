//
//  Person.m
//  01-Block开发中使用场景
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "Person.h"

@implementation Person
- (void)eat:(void (^)())block
{
    /**
    block = ^{
        NSLog(@"吃东西");
    };
     */
    block();
}

- (void)run:(int)metre
{
    NSLog(@"%d",metre);
}

- (void (^)(int))run
{
    return ^(int meter){
      
        NSLog(@"跑了%d米",meter);
    };
}
@end
