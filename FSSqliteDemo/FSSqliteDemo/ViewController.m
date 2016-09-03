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
    
//    NSString *p = [[NSBundle mainBundle]pathForResource:@"demodb.sqlitemodeld/db1" ofType:@"sqlitemodel"];
//    NSString *p2 = [[NSBundle mainBundle]pathForResource:@"db2.sqlitemodeld/db2" ofType:@"sqlitemodel"];
    
    FSSqliteEngine *fg = [[FSSqliteEngine alloc]init];
    id<FSSqliteProtocol> obj = [fg defalutSqliteParse];
    
    
   // NSString *tes = [[NSBundle mainBundle]pathForResource:@"demodb.sqlitemodeld/demodb" ofType:@"sqlitemodel"];
//    NSString *p = [[NSBundle mainBundle]pathForResource:@"demodb" ofType:@"sqlitemodeld"];
//    NSString *p2 = [[NSBundle mainBundle]pathForResource:@"demodb2" ofType:@"sqlitemodeld"];
//    
//    NSData *pd = [obj loadFileMainVersionDBFromSqlitemodeld:p];
//    NSData *pd2 = [obj loadFileMainVersionDBFromSqlitemodeld:p2];
    
    NSString *qw = [[NSBundle mainBundle]pathForResource:@"qw" ofType:@"sqlitemodeld"];
    
    NSData *qwd = [obj loadFileMainVersionDBFromSqlitemodeld:qw];
    
    [obj makeDBSqlForDescriptionModel:qwd];
    
//    NSArray *arr = [obj compareSqliteModel:pd andNewSqliteModel:pd2];
//    NSLog(@"%@",arr);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
