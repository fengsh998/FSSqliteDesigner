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
#import "FSIndexTableViewImpl.h"

@interface FSDesignerViewController : NSViewController
{
    @private
    NSDictionary                    *_sqlitekeywords;
    NSMutableString                 *_sqlitematchPattern;
    FSIndexTableViewImpl            *_indexTableviewDispatcher;
}
///sqlitemodeld包路径
@property (nonatomic, copy)             NSURL                   *packageUrl;
///sqlitemodel路径URL
@property (nonatomic, readonly)         NSURL                   *modelUrl;
///分区
@property (weak) IBOutlet               NSSplitView             *splitview;
///库(1)，表(2)，(视图，触发器，索引显示区 3)
@property (weak) IBOutlet               FSOutlineView           *dblistview;
///右边分区多页
@property (weak) IBOutlet               NSTabView               *tabview;
///添加菜单
@property (weak) IBOutlet               NSButton                *btnAdd;
///移除菜单
@property (weak) IBOutlet               NSButton                *btnRemove;
///添加字段
@property (weak) IBOutlet               NSButton                *btnAddColumn;
///移除字段
@property (weak) IBOutlet               NSButton                *btnRemoveColumn;
///字段列表view
@property (weak) IBOutlet               NSTableView             *fieldlistview;
///库名
@property (weak) IBOutlet               NSTextField             *tfDBName;
///checkbox
@property (weak) IBOutlet               NSButton                *btnCheckDymic;
///备注
@property (unsafe_unretained) IBOutlet  NSTextView              *tvMark;
///显示表创建语句
@property (unsafe_unretained) IBOutlet  NSTextView              *tvCreateSql;
///是否对某个字段开启名键
@property (weak) IBOutlet               NSButton                *chkForeignKey;
///列出外键对应的关联表
@property (weak) IBOutlet               NSPopUpButton           *popTargetTables;
///目标列
@property (weak) IBOutlet               NSPopUpButton           *popTargetColumns;
///属性选择
@property (weak) IBOutlet               NSPopUpButton           *popOptions;
///触发事件1
@property (weak) IBOutlet               NSPopUpButton           *popActionForDelete;
///触发事件2
@property (weak) IBOutlet               NSPopUpButton           *popActionForUpdate;
///表对应的字段，外键，语句tabcontrol
@property (weak) IBOutlet               NSTabView               *fieldTabview;

@property (nonatomic,strong)            FSDesignFileObject      *designer;
///sqlite关键词，保留字(key,color)
@property (nonatomic,strong)            NSDictionary            *sqlitekeywords;
///匹配模板
@property (nonatomic,strong)            NSMutableString         *sqlitematchPattern;

//*******************************索引模块属性对象************************************//
///解决代码块过多将索引的tableview 代理转换
@property (nonatomic,strong)            FSIndexTableViewImpl    *indexTableviewDispatcher;
///索引名
@property (weak) IBOutlet               NSTextField             *tfIndexName;
///需要建索引的表
@property (weak) IBOutlet               NSPopUpButton           *popIndexTable;
///是否建唯一索引
@property (weak) IBOutlet               NSButton                *checkIndexUnique;
///索引字段显示
@property (weak) IBOutlet               NSTableView             *indexTableview;
///保存按钮
@property (weak) IBOutlet               NSButton                *btnIndexEditSave;
///索引sql显示
@property (unsafe_unretained) IBOutlet  NSTextView              *tvIndexSql;
//*******************************视图模块属性对象************************************//
///视图名
@property (weak) IBOutlet               NSTextField             *tfViewName;
///视图显示的sql
@property (unsafe_unretained) IBOutlet  NSTextView              *tvViewSql;
//*******************************触发器模块属性对象************************************//
///触发器名
@property (weak) IBOutlet               NSTextField             *tfTriggerName;
///触发事件
@property (weak) IBOutlet               NSPopUpButton           *popTrggerEvent;
///触发发生的表
@property (weak) IBOutlet               NSPopUpButton           *popTriggerTable;
///触发动作
@property (weak) IBOutlet               NSPopUpButton           *popTriggerAction;
///触发引起的字段显示
@property (weak) IBOutlet               NSTableView             *triggerTableview;
///触发器编辑区
@property (unsafe_unretained) IBOutlet  NSTextView              *tvTriggerSqlEdit;
///触发器sql显示
@property (unsafe_unretained) IBOutlet  NSTextView              *tvTriggerSql;

///加载sqlitemodel的路径
- (void)setModelUrl:(NSURL *)modelUrl;
///获取选中项
- (FSNode *)getSelectItemInList;
// /获取当前选中结点的根结点(database)
- (FSNode *)getRootItemOfNode:(FSNode *)selectedNode;
///设置某个结点为选中状态
- (void)toDoSelectedTreeNode:(FSNode *)node;
///当outline 获取焦点时变色
- (void)setFocus:(NSView *)v;
///弹窗提示
- (void)alterCheckMessage:(NSString *)msg reSetFocus:(NSView *)v;

@end
