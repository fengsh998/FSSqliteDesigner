//
//  FSDesignerViewController+index.m
//  FSSqliteDesigner
//
//  Created by fengsh on 29/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController+index.h"

@implementation FSDesignerViewController(index)

//获取当前选中的索引
- (FSIndex *)getCurrentEditorIndex
{
    FSNode *node = [self getSelectItemInList];
    
    if ([node isKindOfClass:[FSIndex class]]) {
        return (FSIndex *)node;
    }
    
    return nil;
}


- (void)onIndexNameChange:(NSTextField *)textfield
{
    BOOL exsist = [[self getCurrentEditorIndex] exsistNodeNameInNeighbour:textfield.stringValue];
    
    if (exsist)
    {
        textfield.stringValue = [self getCurrentEditorIndex].indexName;
        [self alterCheckMessage:@"存在同名索引" reSetFocus:textfield];
        return;
    }
        
    
    [self getCurrentEditorIndex].indexName = textfield.stringValue;

    FSNode *node = [self getSelectItemInList];
    [self.dblistview reloadItem:node.parentNode reloadChildren:YES];
    [self toDoSelectedTreeNode:node];
}

- (void)toLoadTabels:(NSArray *)tables
{
    [self.popIndexTable removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (FSTable *tb in tables) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:tb.tableName action:@selector(popIndexTableClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        tmp.representedObject = tb;
        [ms addItem:tmp];
    }
    
    self.popIndexTable.menu = ms;
}

- (void)cleanIndexPage
{
    self.tvIndexSql.string = @"";
    self.indexTableviewDispatcher.dataSource = nil;
    [self.indexTableview reloadData];
}

- (void)loadIndex:(FSIndex *)index withIndexTargetTables:(NSArray *)tables
{
    [self cleanIndexPage];
    
    self.tfIndexName.stringValue = index.indexName;
    [self.checkIndexUnique setState:index.unique];
    
    [self toLoadTabels:tables];
    
    if (index.indexTableName.length > 0)
    {
        [self.popIndexTable selectItemWithTitle:index.indexTableName];
        NSMenuItem *item = [self.popIndexTable itemWithTitle:index.indexTableName];
        if (item) {
            [self popIndexTableClicked:item];
        }
    }
}

- (void)popIndexTableClicked:(NSMenuItem *)item
{
    FSIndex *index = [self getCurrentEditorIndex];
    if (index) {
        index.indexTableName = item.title;
        NSArray *currentselectcolums = index.indexFieldNames;
        FSTable *tb = item.representedObject;
        NSArray *columns = [tb allColumns];
        if (columns) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"columns":columns}];
            if (currentselectcolums) {
                [dictionary setObject:currentselectcolums forKey:@"selected"];
                
                NSString *sql = [index makeSqlKeyValue];
                
                self.tvIndexSql.string = sql ? sql : @"";
            }
            [self todoLoadColumns:dictionary];
        }
    }
}

- (void)todoLoadColumns:(NSDictionary *)dictionary
{
    self.indexTableviewDispatcher.dataSource = dictionary;
    
    [self.indexTableview reloadData];
}

- (IBAction)onBtnIndexSaveClicked:(id)sender
{
    NSDictionary *dic = self.indexTableviewDispatcher.dataSource;
    NSArray *columns = dic[@"columns"];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0 ;i < columns.count; i++)
    {
        NSTableCellView *v =[self.indexTableview viewAtColumn:0 row:i makeIfNecessary:NO];
        NSButton *chk = v.subviews[0];
        if (chk.state)
        {
            FSColumn *cls = columns[i];
            [array addObject:[NSString stringWithFormat:@"\"%@\"",cls.fieldName]];
        }
    }
    
    [self getCurrentEditorIndex].indexFieldNames = array;
    
    NSString *sql = [[self getCurrentEditorIndex]makeSqlKeyValue];
    
    [self.tvIndexSql setString:sql];
    
}

- (IBAction)onCheckIndexUnique:(NSButton *)sender
{
    [self getCurrentEditorIndex].unique = (BOOL)sender.state;
}

- (void)saveIndexSettings
{
    
}

@end
