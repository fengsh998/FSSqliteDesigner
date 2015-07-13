//
//  FSDesignerViewController.h
//  FSSqliteDesigner
//
//  Created by fengsh on 9/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSDesignFileObject.h"

@interface FSDesignerViewController : NSViewController
///sqlitemodeld包路径
@property (nonatomic, copy)             NSURL               *packageUrl;
///sqlitemodel路径URL
@property (nonatomic, readonly)         NSURL               *modelUrl;
///分区
@property (weak) IBOutlet               NSSplitView         *splitview;
///库(1)，表(2)，(视图，触发器，索引显示区 3)
@property (weak) IBOutlet               NSOutlineView       *dblistview;
///右边分区多页
@property (weak) IBOutlet               NSTabView           *tabview;
///添加菜单
@property (weak) IBOutlet               NSButton            *btnAdd;
///移除菜单
@property (weak) IBOutlet               NSButton            *btnRemove;

- (void)setModelUrl:(NSURL *)modelUrl;

@end
