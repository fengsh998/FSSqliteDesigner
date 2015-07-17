//
//  FSDesignerViewController+column.m
//  FSSqliteDesigner
//
//  Created by fengsh on 16/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController+column.h"

#define   COLUMN1       @"fieldname"
#define   COLUMN1CELL   @"namecellview"
#define   COLUMN2       @"fieldtype"
#define   COLUMN2CELL   @"typecellview"
#define   COLUMN3       @"fieldlength"
#define   COLUMN3CELL   @"lengthcellview"
#define   COLUMN4       @"constraint"
#define   COLUMN4CELL   @"constainscellview"
#define   COLUMN5       @"defaultvalue"
#define   COLUMN5CELL   @"defaultcellview"


@implementation FSDesignerViewController(column)

- (IBAction)btnAddColumnClicked:(id)sender
{
    FSNode *node = [self getSelectItemInList];
    if (node.type == nodeTabel)
    {
        [((FSTable*)node)addColumn:@"fieldname"];
    }
}

- (IBAction)btnRemoveColumnClicked:(id)sender
{
    FSNode *node = [self getSelectItemInList];
    if (node.type == nodeColumn)
    {
        if (node.parentNode)
        {
            [node.parentNode removeChildrenNode:node];
        }
    }
}

#pragma mark - 获取当前操作的表
- (FSTable *)getCurrentEditorTable
{
    FSNode *node = [self getSelectItemInList];
    if ([node isKindOfClass:[FSTable class]]) {
        return (FSTable *)node;
    }
    return nil;
}

#pragma mark - 获取字段类型选项
//TEXT,REAL,INTEGER,BLOB,VARCHAR,FLOAT,DOUBLE,DATE,TIME,BOOLEAN,TIMESTAMP,BINARY
- (void)getFieldTypeList:(NSPopUpButton *)popbtn
{
    [popbtn removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    NSMenuItem *i = [[NSMenuItem alloc]initWithTitle:@"INTEGER" action:@selector(popItemClicked:) keyEquivalent:@""];
    [i setTarget:self];
    [ms addItem:i];

    NSMenuItem *text = [[NSMenuItem alloc]initWithTitle:@"TEXT" action:@selector(popItemClicked:) keyEquivalent:@""];
    [text setTarget:self];
    [ms addItem:text];
    
    NSMenuItem *real = [[NSMenuItem alloc]initWithTitle:@"REAL" action:@selector(popItemClicked:) keyEquivalent:@""];
    [real setTarget:self];
    [ms addItem:real];
    
    NSMenuItem *var = [[NSMenuItem alloc]initWithTitle:@"VARCHAR" action:@selector(popItemClicked:) keyEquivalent:@""];
    [var setTarget:self];
    [ms addItem:var];
    
    NSMenuItem *ft = [[NSMenuItem alloc]initWithTitle:@"FLOAT" action:@selector(popItemClicked:) keyEquivalent:@""];
    [ft setTarget:self];
    [ms addItem:ft];
    
    NSMenuItem *db = [[NSMenuItem alloc]initWithTitle:@"DOUBLE" action:@selector(popItemClicked:) keyEquivalent:@""];
    [db setTarget:self];
    [ms addItem:db];
    
    NSMenuItem *dt = [[NSMenuItem alloc]initWithTitle:@"DATE" action:@selector(popItemClicked:) keyEquivalent:@""];
    [dt setTarget:self];
    [ms addItem:dt];
    
    NSMenuItem *t = [[NSMenuItem alloc]initWithTitle:@"TIME" action:@selector(popItemClicked:) keyEquivalent:@""];
    [t setTarget:self];
    [ms addItem:t];
    
    NSMenuItem *b = [[NSMenuItem alloc]initWithTitle:@"BOOLEAN" action:@selector(popItemClicked:) keyEquivalent:@""];
    [b setTarget:self];
    [ms addItem:b];
    
    NSMenuItem *ts = [[NSMenuItem alloc]initWithTitle:@"TIMESTAMP" action:@selector(popItemClicked:) keyEquivalent:@""];
    [ts setTarget:self];
    [ms addItem:ts];
    
    NSMenuItem *by = [[NSMenuItem alloc]initWithTitle:@"BINARY" action:@selector(popItemClicked:) keyEquivalent:@""];
    [by setTarget:self];
    [ms addItem:by];
    
    NSMenuItem *blb = [[NSMenuItem alloc]initWithTitle:@"BLOB" action:@selector(popItemClicked:) keyEquivalent:@""];
    [blb setTarget:self];
    [ms addItem:blb];
    
    popbtn.menu = ms;
}

- (void)popItemClicked:(NSMenuItem*)item
{
    //根据选中的项来判断是否要设置size (在sqlite中不需要size)
    [self.fieldlistview enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * __nonnull rowView, NSInteger row) {
        NSTableCellView *cv = [self.fieldlistview viewAtColumn:1 row:row makeIfNecessary:NO];
        
        NSPopUpButton *popup = cv.subviews[0];
        NSInteger found = [popup.menu indexOfItem:item];
        if (found != -1)
        {
            NSTableCellView *cv = [self.fieldlistview viewAtColumn:2 row:row makeIfNecessary:NO];
            NSComboBox *bx = cv.subviews[0];
            bx.enabled = NO;//!bx.enabled;
        }
    }];
}

#pragma mark - 获取初设长度
- (NSArray *)getDefaultFieldLength
{
    NSMutableArray *ls = [NSMutableArray array];
    
    [ls addObject:@"1"];
    [ls addObject:@"5"];
    [ls addObject:@"10"];
    [ls addObject:@"50"];
    [ls addObject:@"100"];

    return ls;
}

#pragma mark - tableView delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 10;//[self getCurrentEditorTable].childcounts;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    //FSColumn *columns =
    NSTableCellView *v = nil;
    if ([tableColumn.identifier isEqualToString:COLUMN1]) {
        v = [tableView makeViewWithIdentifier:COLUMN1CELL owner:self];
        v.textField.stringValue = @"ffff";
        [v.textField setEditable:YES];
        [v.textField setSelectable:YES];
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN2]) {
        v = [tableView makeViewWithIdentifier:COLUMN2CELL owner:self];
        NSPopUpButton *popup = v.subviews[0];
        [self getFieldTypeList:popup];
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN3]) {
        v = [tableView makeViewWithIdentifier:COLUMN3CELL owner:self];
        NSComboBox *bx = v.subviews[0];
        bx.enabled = NO; //全部禁选sqlite未用到
        [bx removeAllItems];
        [bx addItemsWithObjectValues:[self getDefaultFieldLength]];
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN4]) {
        v = [tableView makeViewWithIdentifier:COLUMN4CELL owner:self];
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN5]) {
        v = [tableView makeViewWithIdentifier:COLUMN5CELL owner:self];
        v.textField.stringValue = @"";
        [v.textField setEditable:YES];
        [v.textField setSelectable:YES];
    }
    
    return v;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 22;
}

@end
