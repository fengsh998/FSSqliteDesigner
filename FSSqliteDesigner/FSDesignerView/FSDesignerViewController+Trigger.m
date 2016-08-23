//
//  FSDesignerViewController+Trigger.m
//  FSSqliteDesigner
//
//  Created by fengsh on 31/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController+Trigger.h"

@implementation FSDesignerViewController(Trigger)

- (FSTrigger *)getCurrentEditorTrigger
{
    FSNode *node = [self getSelectItemInList];
    
    if ([node isKindOfClass:[FSTrigger class]]) {
        return (FSTrigger *)node;
    }
    
    return nil;
}

- (void)loadTriggerView:(FSTrigger *)trigger withTables:(NSArray *)tables
{
    self.triggerTableviewDispatcher.dataSource = nil;
    [self.triggerTableview reloadData];
    
    self.tfTriggerName.stringValue = trigger.triggerName;
    //加载表
    [self toLoadTabelsForTrigger:tables];
    
    if (!trigger.events) {
        trigger.events = @"INSERT";
    }
    //加载event
    [self toLoadEventsAndSelected:trigger.events];
    
    if (!trigger.actions) {
        trigger.actions = @"BEFORE";
    }
    //加载action
    [self toLoadActionsAndSelected:trigger.actions];
    
    [self.popTriggerTable selectItemWithTitle:trigger.tableName];

    if (trigger.tableName) {
        NSMenuItem *item = [self.popTriggerTable itemWithTitle:trigger.tableName];
        if (item) {
            [self popTriggerTableClicked:item];
        }
    }
    //加载语句
    self.tvTriggerSqlEdit.string = trigger.sqls ? trigger.sqls : @"";
    
    [self todoRefreshSqlOutput];
    
}

- (void)popTriggerTableClicked:(NSMenuItem *)item
{
    FSTable *tb = item.representedObject;
    
    [self getCurrentEditorTrigger].tableName = tb.tableName;
    
    if ([self.popTriggerTable.title isEqualToString:@"UPDATE OF"])
    {
        if (tb) {
            NSArray *columns = [tb allColumns];
            FSTrigger *trigger = [self getCurrentEditorTrigger];
            NSArray *currentselectcolums = trigger.columns;
            if (columns) {
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"columns":columns}];
                if (currentselectcolums) {
                    [dictionary setObject:currentselectcolums forKey:@"selected"];
                }
                
                [self todoLoadTriggerColumns:dictionary];
            }
        }
    }
    
    [self todoRefreshSqlOutput];
}

- (void)todoLoadTriggerColumns:(NSDictionary *)dictionary
{
    self.triggerTableviewDispatcher.dataSource = dictionary;
    
    [self.triggerTableview reloadData];
}

- (void)toLoadEventsAndSelected:(NSString *)event
{
    [self.popTrggerEvent removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (NSString *e in [FSTrigger supportTriggerEvents]) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:e action:@selector(popTriggerEventClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        [ms addItem:tmp];
    }
    
    self.popTrggerEvent.menu = ms;
    
    if (event) {
        [self.popTrggerEvent selectItemWithTitle:event];
    }
}

- (void)toLoadActionsAndSelected:(NSString *)action
{
    [self.popTriggerAction removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (NSString *e in [FSTrigger supportTriggerActions]) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:e action:@selector(popTriggerActionClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        [ms addItem:tmp];
    }
    
    self.popTriggerAction.menu = ms;
    
    if (action) {
        [self.popTriggerAction selectItemWithTitle:action];
    }
}

- (void)toLoadTabelsForTrigger:(NSArray *)tables
{
    [self.popTriggerTable removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (FSTable *tb in tables) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:tb.tableName action:@selector(popTriggerTableClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        tmp.representedObject = tb;
        [ms addItem:tmp];
    }
    
    self.popTriggerTable.menu = ms;
}

- (void)popTriggerEventClicked:(NSMenuItem *)item
{
    NSString *title = item.title;
    NSString *tabname = self.popTriggerTable.title;
    FSTrigger *trigger = [self getCurrentEditorTrigger];
    trigger.events = title;
    
    if ([title isEqualToString:@"UPDATE OF"] && tabname.length > 0)
    {
        
        FSNode *db = [self getRootItemOfNode:trigger];
        
        if ([db isKindOfClass:[FSDatabse class]] && trigger && tabname.length > 0)
        {
            FSTable *tb = [((FSDatabse *)db) tableOfName:tabname];
            NSArray *columns = [tb allColumns];
            FSTrigger *trigger = [self getCurrentEditorTrigger];
            NSArray *currentselectcolums = trigger.columns;
            if (columns) {
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"columns":columns}];
                if (currentselectcolums) {
                    [dictionary setObject:currentselectcolums forKey:@"selected"];
                }
                
                [self todoLoadTriggerColumns:dictionary];
            }
        }
    }
    else
    {
        self.triggerTableviewDispatcher.dataSource = nil;
        [self.triggerTableview reloadData];
    }
    
    [self todoRefreshSqlOutput];
}

- (void)onTriggerNameChange:(NSTextField *)textfield
{
    BOOL exsist = [[self getCurrentEditorTrigger] exsistNodeNameInNeighbour:textfield.stringValue];
    
    if (exsist)
    {
        textfield.stringValue = [self getCurrentEditorTrigger].triggerName;
        [self alterCheckMessage:@"存在同名触发器" reSetFocus:textfield];
        return;
    }
    
    [self getCurrentEditorTrigger].triggerName = textfield.stringValue;
    
    FSNode *node = [self getSelectItemInList];
    [self.dblistview reloadItem:node.parentNode reloadChildren:YES];
    [self toDoSelectedTreeNode:node];
    
    [self todoRefreshSqlOutput];
}

- (void)popTriggerActionClicked:(NSMenuItem *)item
{
    NSString *action = item.title;
    [self getCurrentEditorTrigger].actions = action;
    
    [self todoRefreshSqlOutput];
}

- (void)saveTriggerSettings
{
    
}

- (void)todoRefreshSqlOutput
{
    NSString *s = [[self getCurrentEditorTrigger]makeSqlKeyValue];
    self.tvTriggerSql.string = s ? s : @"";
}

- (void)textDidChange:(NSNotification *)notification
{
    id obj = notification.object;
    if ([obj isKindOfClass:[NSTextView class]] && obj == self.tvTriggerSqlEdit)
    {
        NSTextView *tv = obj;
        
        FSTrigger *tg = [self getCurrentEditorTrigger];
        tg.sqls = tv.string;
        
        [self todoRefreshSqlOutput];
    }
}

- (void)FSTrigger:(FSTriggerTableViewImpl *)impl SelectColumns:(id)column
{
    FSColumn *c = column;
    
    NSArray *cs =[self getCurrentEditorTrigger].columns;
    
    NSMutableArray *ma = [NSMutableArray array];
    
    if (cs) {
        [ma addObjectsFromArray:cs];
    }
    [ma addObject:c.fieldName];
    
    [self getCurrentEditorTrigger].columns = ma;
    
    [self todoRefreshSqlOutput];
}

@end
