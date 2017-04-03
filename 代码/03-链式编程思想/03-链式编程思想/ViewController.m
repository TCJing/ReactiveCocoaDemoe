//
//  ViewController.m
//  03-链式编程思想
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "ViewController.h"

#import "NSObject+Calculate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   int reslut = [NSObject xmg_makeCalculate:^(CalculateManager *mgr) {
        // 在这个里面存放计算代码
        // 5 + 5
//        mgr.add(5).add(5).multy(5).sub(10);
        
//        [[mgr add:5] add:5];
        // 5 + 6 + 7 = 18

        mgr.add(5).add(6).add(7);
        
        // 用block替代方法
        // 把怎么计算的代码封装到block
        
    }];
    
    NSLog(@"%d",reslut);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
