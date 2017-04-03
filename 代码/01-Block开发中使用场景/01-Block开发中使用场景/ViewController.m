//
//  ViewController.m
//  01-Block开发中使用场景
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "ViewController.h"

#import "Person.h"

@interface ViewController ()

@property (nonatomic, strong) Person *p;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // block开发中使用场景
    
    // 1.把block保存到对象中,恰当时机的时候才去调用
    
    // 2.把block当做方法的参数使用,外界不调用,都是方法内部去调用,Block实现交给外界决定.
    
    // 3.把block当做方法的返回值,目的就是为了代替方法.,block交给内部实现,外界不需要知道Block怎么实现,只管调用
    
}

- (void)block3
{
    Person *p = [[Person alloc] init];
    
    [p run:2];
    
    p.run(2);
    void(^run)() = p.run;
    run();
    
    
    
}

- (void)block2
{
    Person *p = [[Person alloc] init];
    
    
    void(^block)() = ^{
        NSLog(@"吃东西");
    };
    
    [p eat:block];
    
    // 传入block给参数的Block赋值
    [p eat:^{
        NSLog(@"吃东西");
    }];
}

- (void)block1
{
    Person *p = [[Person alloc] init];
    
    void(^block)() = ^() {
        NSLog(@"执行对象中block");
    };
    
    p.operation = ^(){
        
        NSLog(@"执行对象中block");
    };
    
    p.operation = block;
    
    _p = p;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _p.operation();
}

- (void)block
{
    // block声明,定义
    
    void(^block)() = ^() {
        // 保存什么样的代码
        
        NSLog(@"执行block");
        
    };
    
    // block作用:帮你保存一份代码,等到恰当时机的时候才去调用
    
    // 调用block
    block();

}

@end
