//
//  Person.h
//  01-Block开发中使用场景
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>

// name:类型的别名
typedef void(^BlockName)();

@interface Person : NSObject

// block:ARC使用strong,非ARC使用copy
// block类型:void(^)()
@property (nonatomic, strong) void(^operation)();

// 参数类型:block类型
- (void)eat:(void(^)())block;

- (void)run:(int)metre;

- (void(^)(int))run;

//- (void)eat:(BlockName)block;

@end
