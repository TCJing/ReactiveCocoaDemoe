//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "ViewController.h"

#import "GlobeHeader.h"

#import "RedView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet RedView *redView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   // 订阅信号
    [_redView.btnClickSignal subscribeNext:^(id x) {
       
        NSLog(@"%@",x);
    }];
    
    
    
}

  

- (void)RACSubject
{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    
    // 不同信号订阅的方式不一样
    // RACSubject处理订阅:仅仅是保存订阅者
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者一接收到数据:%@",x);
    }];
    
    // 3.发送数据
    [subject sendNext:@1];
    
    //    [subject subscribeNext:^(id x) {
    //        NSLog(@"订阅二接收到数据:%@",x);
    //    }];
    // 保存订阅者
    
   
    // 底层实现:遍历所有的订阅者,调用nextBlock
    
    // 执行流程:
    
    // RACSubject被订阅,仅仅是保存订阅者
    // RACSubject发送数据,遍历所有的订阅,调用他们的nextBlock
}

@end
