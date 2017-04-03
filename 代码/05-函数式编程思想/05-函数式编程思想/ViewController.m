//
//  ViewController.m
//  05-函数式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "ViewController.h"

#import "CalculateManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CalculateManager *mgr = [[CalculateManager alloc] init];
    
   int result = [[mgr calculate:^(int result){
       // 存放所有的计算代码
        result += 5;
        result *= 5;
        return result;
    }] result];
    NSLog(@"%d",result);
}
@end
