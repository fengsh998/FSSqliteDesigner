//
//  FSDesignerViewController.h
//  FSSqliteDesigner
//
//  Created by fengsh on 9/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSDesignFileObject.h"
#import "FSOutlineView.h"
#import "FSTabView.h"

@interface FSDesignerViewController : NSViewController
///sqlitemodeld包路径
@property (nonatomic, copy)             NSURL               *packageUrl;
///sqlitemodel路径URL
@property (nonatomic, readonly)         NSURL               *modelUrl;
///分区
@property (weak) IBOutlet               NSSplitView         *splitview;
///库(1)，表(2)，(视图，触发器，索引显示区 3)
@property (weak) IBOutlet               FSOutlineView       *dblistview;
///右边分区多页
@property (weak) IBOutlet               NSTabView           *tabview;
///添加菜单
@property (weak) IBOutlet               NSButton            *btnAdd;
///移除菜单
@property (weak) IBOutlet               NSButton            *btnRemove;
///添加字段
@property (weak) IBOutlet               NSButton            *btnAddColumn;
///移除字段
@property (weak) IBOutlet               NSButton            *btnRemoveColumn;
///字段列表view
@property (weak) IBOutlet               NSTableView         *fieldlistview;
///库名
@property (weak) IBOutlet               NSTextField         *tfDBName;
///checkbox
@property (weak) IBOutlet               NSButton            *btnCheckDymic;
///备注
@property (unsafe_unretained) IBOutlet  NSTextView          *tvMark;
///显示表创建语句
@property (unsafe_unretained) IBOutlet  NSTextView          *tvCreateSql;
///是否对某个字段开启名键
@property (weak) IBOutlet               NSButton            *chkForeignKey;
///列出外键对应的关联表
@property (weak) IBOutlet               NSPopUpButton       *popTargetTables;
///目标列
@property (weak) IBOutlet               NSPopUpButton       *popTargetColumns;
///属性选择
@property (weak) IBOutlet               NSPopUpButton       *popOptions;
///触发事件1
@property (weak) IBOutlet               NSPopUpButton       *popActionForDelete;
///触发事件2
@property (weak) IBOutlet               NSPopUpButton       *popActionForUpdate;
///表对应的字段，外键，语句tabcontrol
@property (weak) IBOutlet               NSTabView           *fieldTabview;

@property (nonatomic,strong)            FSDesignFileObject  *designer;

///加载sqlitemodel的路径
- (void)setModelUrl:(NSURL *)modelUrl;
///获取选中项
- (FSNode *)getSelectItemInList;
///设置某个结点为选中状态
- (void)toDoSelectedTreeNode:(FSNode *)node;
///当outline 获取焦点时变色
- (void)setFocus:(NSView *)v;

@end
