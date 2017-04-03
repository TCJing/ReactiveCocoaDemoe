//
//  ViewController.m
//  02-Masonry框架分析
//
//  Created by xiaomage on 15/10/25.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "ViewController.h"

#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
        1.使用约束布局步骤
            * 先添加控件,在设置约束
     */
    
    // 创建红色view
    UIView *redView = [[UIView alloc] init];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    // 设置约束,一定要先把view添加上去,才能设置约束
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 链式编程思想特点:方法返回值必须要方法调用者
        // block:把需要操作的值当做block参数,block也需要返回值,就是方法调用者
       // 设置约束
        // 给make添加left,top约束,调用equalTo给这两个约束赋值
        make.left.top.equalTo(@10);
        make.right.bottom.equalTo(@-10);
        
    }];
    
    /*
        mas_makeConstraints执行流程:
        1.创建约束制造者MASConstraintMaker,绑定控件,生成了一个保存所有约束的数组
        2.执行mas_makeConstraints传入进行的block   
        3.让约束制造者安装约束
            *   1.清空之前的所有约束
            *   2.遍历约束数组,一个一个安装
     */
    
   

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
