//
//  CalculateManager.h
//  03-链式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculateManager : NSObject

@property (nonatomic, assign) int result;

//- (instancetype)add:(int)value;

- (CalculateManager *(^)(int))add;

@end
