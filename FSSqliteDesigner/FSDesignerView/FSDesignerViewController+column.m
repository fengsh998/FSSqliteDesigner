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
    FSTable *tables = [self getCurrentEditorTable];
    if (tables)
    {
        NSInteger tbcount = tables.allColumns.count;
        NSString *column = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
        
        [tables addColumn:[NSString stringWithFormat:@"fieldname%@",column]];
        
        [self.fieldlistview reloadData];
        
        [self.dblistview reloadItem:tables reloadChildren:NO];
    }
}

- (IBAction)btnRemoveColumnClicked:(id)sender
{
    NSInteger idx = [self fieldSelectedIndex];
    
    if (idx != -1)
    {
        FSTable *tables = [self getCurrentEditorTable];
        [tables removeColumnOfIndex:idx];
        
        [self.fieldlistview reloadData];
        
        [self.dblistview reloadItem:tables reloadChildren:YES];
    }
}

#pragma mark - 获取当前操作的表
- (FSTable *)getCurrentEditorTable
{
    FSNode *node = [self getSelectItemInList];
    if ([node isKindOfClass:[FSTable class]]) {
        return (FSTable *)node;
    }
    else if ([node isKindOfClass:[FSColumn class]])
    {
        return (FSTable *)node.parentNode;
    }
    return nil;
}

- (NSInteger)fieldSelectedIndex
{
    return self.fieldlistview.selectedRow;
}

#pragma mark - 获取字段类型选项

- (void)getFieldTypeList:(NSPopUpButton *)popbtn forTypes:(NSArray *)types
{
    [popbtn removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (NSString *ftype in types) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:ftype action:@selector(popItemClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        [ms addItem:tmp];
    }
    
    popbtn.menu = ms;
}

#pragma mark - 选择类型
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
            
            FSColumn *c = [[self getCurrentEditorTable]columnAtIndex:row];
            c.fieldtype = [c covertToType:item.title];
        }
    }];
}

#pragma mark - 选择长度
- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *cbx = notification.object;
    
    [self.fieldlistview enumerateAvailableRowViewsUsingBlock:^(__kindof NSTableRowView * __nonnull rowView, NSInteger row) {
        NSTableCellView *cv = [self.fieldlistview viewAtColumn:2 row:row makeIfNecessary:NO];
        
        NSComboBox *vcbx = cv.subviews[0];

        if (vcbx == cbx)
        {
            FSColumn *c = [[self getCurrentEditorTable]columnAtIndex:row];
            
            id value = [cbx itemObjectValueAtIndex:cbx.indexOfSelectedItem];
            c.typeLength = [value integerValue];
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
    return [self getCurrentEditorTable].childcounts;
}

- (nullable NSView *)tableView:(NSTableView *)tableView
            viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:row];
    NSTableCellView *v = nil;
    if ([tableColumn.identifier isEqualToString:COLUMN1]) {
        v = [tableView makeViewWithIdentifier:COLUMN1CELL owner:self];
        v.textField.stringValue = columns.fieldName;
        v.textField.action = @selector(onEditColumnName:);
        v.textField.delegate = self;
        v.textField.tag = row;
        [v.textField setEditable:YES];
        [v.textField setSelectable:YES];
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN2]) {
        v = [tableView makeViewWithIdentifier:COLUMN2CELL owner:self];
        NSPopUpButton *popup = v.subviews[0];
        
        [self getFieldTypeList:popup forTypes:columns.supportFieldTypes];
        
        NSInteger sidx = 0;

        if (columns.fieldtype != ftUnknow)
        {
            sidx = columns.fieldtype;
        }
        [popup selectItemAtIndex:sidx];
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN3]) {
        v = [tableView makeViewWithIdentifier:COLUMN3CELL owner:self];
        NSComboBox *bx = v.subviews[0];
        bx.delegate = self;
        bx.enabled = NO; //全部禁选sqlite未用到
        [bx removeAllItems];
        [bx addItemsWithObjectValues:[self getDefaultFieldLength]];
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN4]) {
        v = [tableView makeViewWithIdentifier:COLUMN4CELL owner:self];
        
        for (NSButton *checkitem in v.subviews) {
            checkitem.tag = row;
            checkitem.target = self;
            if ([checkitem.title isEqualToString:@"P"])
            {
                checkitem.action = @selector(onPermaryCheck:);
                BOOL ok = (columns.constraint & fcPrimarykey);
                [checkitem setState:ok];
            }
            else if ([checkitem.title isEqualToString:@"A"])
            {
                checkitem.action = @selector(onAutoIncreamCheck:);
                BOOL ok = (columns.constraint & fcAutoIncreament);
                [checkitem setState:ok];
            }
            else if ([checkitem.title isEqualToString:@"N"])
            {
                checkitem.action = @selector(onNotNullCheck:);
                BOOL ok = (columns.constraint & fcNotNull);
                [checkitem setState:ok];
            }
            else if ([checkitem.title isEqualToString:@"U"])
            {
                checkitem.action = @selector(onUniqueCheck:);
                BOOL ok = (columns.constraint & fcUnique);
                [checkitem setState:ok];
            }
        }
    }
    else if ([tableColumn.identifier isEqualToString:COLUMN5]) {
        v = [tableView makeViewWithIdentifier:COLUMN5CELL owner:self];
        v.textField.stringValue = columns.defaultvalue?columns.defaultvalue:@"";
        v.textField.action = @selector(onEditColumnDefault:);
        v.textField.delegate = self;
        v.textField.tag = row;
        [v.textField setEditable:YES];
        [v.textField setSelectable:YES];
    }
    
    return v;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 22;
}

#pragma mark - 选中字段行
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView * tbv = notification.object;
    
    if (tbv)
    {
        NSInteger selectedrow = tbv.selectedRow;
        if (selectedrow != -1)
        {
            [self.tvMark setEditable:YES];
            FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:selectedrow];
            
            self.tvMark.string = columns.mark ? columns.mark : @"";
        }
    }
}

///修改字段名(要有回车才触发)
- (void)onEditColumnName:(NSTextField *)textfield
{
    NSInteger row = textfield.tag;
    FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:row];
    columns.fieldName = textfield.stringValue;
    
    [self.dblistview reloadItem:[self getCurrentEditorTable]];
}

///修改默认值
- (void)onEditColumnDefault:(NSTextField *)textfield
{
    NSInteger row = textfield.tag;
    FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:row];
    columns.defaultvalue = textfield.stringValue;
}

///修改主键选择
- (IBAction)onPermaryCheck:(NSButton *)sender
{
    BOOL ok = sender.state;
    NSInteger row = sender.tag;
    FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:row];
    if (ok) {
        columns.constraint = columns.constraint | fcPrimarykey;
    }
    else
    {
        columns.constraint = columns.constraint ^ fcPrimarykey;
    }
}

// /修改自增选择
- (IBAction)onAutoIncreamCheck:(NSButton *)sender
{
    BOOL ok = sender.state;
    NSInteger row = sender.tag;
    FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:row];

    if (ok) {
        columns.constraint = columns.constraint | fcAutoIncreament;
    }
    else
    {
        columns.constraint = columns.constraint ^ fcAutoIncreament;
    }
}

///修改非空选择
- (IBAction)onNotNullCheck:(NSButton *)sender
{
    BOOL ok = sender.state;
    NSInteger row = sender.tag;
    FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:row];
    if (ok) {
        columns.constraint = columns.constraint | fcNotNull;
    }
    else
    {
        columns.constraint = columns.constraint ^ fcNotNull;
    }
}

///修改唯一选择
- (IBAction)onUniqueCheck:(NSButton *)sender
{
    BOOL ok = sender.state;
    NSInteger row = sender.tag;
    FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:row];
    if (ok) {
        columns.constraint = columns.constraint | fcUnique;
    }
    else
    {
        columns.constraint = columns.constraint ^ fcUnique;
    }
}

- (void)textDidChange:(NSNotification *)notification
{
    NSTextView *tv = notification.object;
    
    if (tv == self.tvMark) {
        NSInteger idxrow = self.fieldlistview.selectedRow;
        if (idxrow != -1 && idxrow < [self getCurrentEditorTable].allColumns.count) {
            FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:idxrow];
            columns.mark = tv.string;
        }
    }
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    NSTextView *tv = notification.object;
    
    if (tv == self.tvMark) {
        NSInteger idxrow = self.fieldlistview.selectedRow;
        if (idxrow != -1 && idxrow < [self getCurrentEditorTable].allColumns.count) {
            FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:idxrow];
            columns.mark = tv.string;
        }
    }
}

@end
