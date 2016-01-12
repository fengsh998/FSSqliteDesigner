//
//  ViewController.m
//  FSSqliteDemo
//
//  Created by fengsh on 16/1/6.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import "ViewController.h"
#import <FSSqlite/FSSqlite.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"NSSSS ==== %@",NSTemporaryDirectory());
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *p = [[NSBundle mainBundle]pathForResource:@"db1.sqlitemodeld/db1" ofType:@"sqlitemodel"];
    NSString *p2 = [[NSBundle mainBundle]pathForResource:@"db2.sqlitemodeld/db2" ofType:@"sqlitemodel"];
    
    FSSqliteEngine *fg = [[FSSqliteEngine alloc]init];
    id<FSSqliteProtocol> obj = [fg defalutSqliteParse];
    NSData *pd = [NSData dataWithContentsOfFile:p];
    NSData *pd2 = [NSData dataWithContentsOfFile:p2];
    NSArray *arr = [obj compareSqliteModel:pd andNewSqliteModel:pd2];
    NSLog(@"%@",arr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
