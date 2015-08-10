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
        NSString *uniquename = [tables makeUniqueColumnName];
        FSColumn *last = [tables addColumn:uniquename];
        
        [self.fieldlistview reloadData];
        
        [self.dblistview reloadItem:tables reloadChildren:YES];
        [self.dblistview expandItem:tables];
        
        [self toDoSelectedTreeNode:last];
    }
}

- (IBAction)btnRemoveColumnClicked:(id)sender
{
    NSInteger idx = [self fieldSelectedIndex];
    
    if (idx != -1)
    {
        FSTable *tables = [self getCurrentEditorTable];
        
        if (!tables) { //失去焦点时就不能删除
            return;
        }
        
        [tables removeColumnOfIndex:idx];
        
        [self.dblistview reloadItem:tables reloadChildren:YES];
        [self.dblistview expandItem:tables];
        
        FSColumn *column = nil;
        NSInteger validIndex = -1;
        if (tables.allColumns.count > 0)
        {
            if (idx - 1 >= 0) {
                validIndex = idx - 1;
                column = [tables columnAtIndex:validIndex];
            }
            else if (idx < tables.allColumns.count)
            {
                validIndex = idx;
                column = [tables columnAtIndex:validIndex];
            }
            
            [self toDoSelectedTreeNode:column];
        }
        else
        {
            [self toDoSelectedTreeNode:tables];
        }
        
        [self.fieldlistview reloadData];
        if (validIndex != -1)
        {
            [self.fieldlistview selectRowIndexes:[NSIndexSet indexSetWithIndex:validIndex] byExtendingSelection:NO];
        }
    }
}

- (void)setDefaultOptions
{
    NSArray *list = [FSForeignKey supportOptions];
    
    [self.popOptions removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (NSString *ftype in list) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:ftype action:@selector(popOptionsClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        [ms addItem:tmp];
    }
    
    self.popOptions.menu = ms;
}

- (void)setDefaultActionForDelete
{
    NSArray *list = [FSForeignKey supportActionForDelete];
    
    [self.popActionForDelete removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (NSString *ftype in list) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:ftype action:@selector(popDeleteClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        [ms addItem:tmp];
    }
    
    self.popActionForDelete.menu = ms;
}

- (void)setDefaultActionForUpdate
{
    NSArray *list = [FSForeignKey supportActionForUpdate];
    
    [self.popActionForUpdate removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (NSString *ftype in list) {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:ftype action:@selector(popUpdateClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        [ms addItem:tmp];
    }
    
    self.popActionForUpdate.menu = ms;
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

#pragma mark - 设置外键属性页

- (void)enableForeignKeypage:(BOOL)flag
{
    self.chkForeignKey.enabled      = flag;
    
    BOOL ok = self.chkForeignKey.state;
    
    self.popTargetTables.enabled    = (flag && ok);
    self.popTargetColumns.enabled   = (flag && ok);
    self.popOptions.enabled         = (flag && ok);
    self.popActionForDelete.enabled = (flag && ok);
    self.popActionForUpdate.enabled = (flag && ok);
}

- (void)toDoSetForeignKeyTabBySelectedColumn:(FSColumn *)column
{
    [self enableForeignKeypage:NO];
    BOOL check = column.enableForeignkey;
    [self.chkForeignKey setState:check];
    if (column)
    {
        [self enableForeignKeypage:YES];
    }
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

#pragma mark - 获取当前列对应的数据库有所有表
- (NSArray *)getTablesByColumn:(FSColumn *)column
{
    FSNode *tablecategory = column.parentNode.parentNode;
    if (tablecategory) {
        return [tablecategory childrens];
    }
    return nil;
}

- (void)fillPopTargetTables:(NSArray *)tables
{
    [self.popTargetTables removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (FSNode *tb in tables)
    {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:tb.nodename action:@selector(popTargetTableClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        tmp.representedObject = tb;
        [ms addItem:tmp];
    }
    
    self.popTargetTables.menu = ms;
}

- (void)todoFillColumns:(NSArray *)columns
{
    [self.popTargetColumns removeAllItems];
    
    NSMenu * ms = [[NSMenu alloc]initWithTitle:@""];
    
    for (FSNode *cls in columns)
    {
        NSMenuItem *tmp = [[NSMenuItem alloc]initWithTitle:cls.nodename action:@selector(popTargetColumnClicked:)
                                             keyEquivalent:@""];
        [tmp setTarget:self];
        [ms addItem:tmp];
    }
    
    self.popTargetColumns.menu = ms;
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

#pragma mark - tabView 代理

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    if (![tabViewItem.identifier isEqualToString:@"2"]) {
        return YES;
    }

    NSInteger idxrow = [self fieldSelectedIndex];
    return (idxrow != -1);
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    if ([tabViewItem.identifier isEqualToString:@"2"])
    {
        [self toDoSetForeignKeyTabBySelectedColumn:nil];
        
        NSInteger idxrow = [self fieldSelectedIndex];
        if (idxrow != -1 && idxrow < [self getCurrentEditorTable].allColumns.count) {
            FSColumn *columns = [[self getCurrentEditorTable].allColumns objectAtIndex:idxrow];
            [self toDoSetForeignKeyTabBySelectedColumn:columns];
            
            NSArray *tbs = [self getTablesByColumn:columns];
            if (tbs) {
                [self fillPopTargetTables:tbs];
            }
        }
    }
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    
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
            FSColumn *column = [[self getCurrentEditorTable].allColumns objectAtIndex:selectedrow];
            
            self.tvMark.string = column.mark ? column.mark : @"";
            
            [self toDoSelectedTreeNode:column];
        }
    }
}

///修改字段名(要有回车才触发)
- (void)onEditColumnName:(NSTextField *)textfield
{
    NSInteger row = textfield.tag;
    FSColumn *column = [[self getCurrentEditorTable].allColumns objectAtIndex:row];
    column.fieldName = textfield.stringValue;
    
    [self.dblistview reloadItem:[self getCurrentEditorTable] reloadChildren:YES];
    [self toDoSelectedTreeNode:column];
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

- (void)popTargetTableClicked:(NSMenuItem *)item
{
    FSTable *tb = item.representedObject;
    if (tb && [tb isKindOfClass:[FSTable class]])
    {
        [self todoFillColumns:tb.allColumns];
    }
}

- (void)popOptionsClicked:(NSMenuItem *)item
{
    
}

- (void)popDeleteClicked:(NSMenuItem *)item
{
    
}

- (void)popUpdateClicked:(NSMenuItem *)item
{
    
}

- (void)popTargetColumnClicked:(NSMenuItem *)item
{
    
}

- (IBAction)onCheckForeignKey:(NSButton *)sender
{
    [self enableForeignKeypage:YES];
}

#pragma mark - 保存表设置页的数据
- (void)saveTableSettings
{
    
}

#pragma mark - 外键保存
- (IBAction)onSaveForeignkey:(id)sender
{
    FSTable *currenttab = [self getCurrentEditorTable];
    if (currenttab) {
        //只针对选中的字段进行处理外键
        NSInteger idxrow = [self fieldSelectedIndex];
        if (idxrow != -1 && idxrow < currenttab.allColumns.count) {
            FSColumn *column = [currenttab.allColumns objectAtIndex:idxrow];
            column.enableForeignkey = self.chkForeignKey.state;
            column.foreignKey.targetTable  = self.popTargetTables.titleOfSelectedItem;
            column.foreignKey.targetColumn = self.popTargetColumns.titleOfSelectedItem;
            column.foreignKey.selectIndexOfOptions = self.popOptions.indexOfSelectedItem;
            column.foreignKey.selectIndexOfDeleteAction = self.popActionForDelete.indexOfSelectedItem;
            column.foreignKey.selectIndexOfUpdateAction = self.popActionForUpdate.indexOfSelectedItem;
        }
        
        self.tvCreateSql.string = [[self getCurrentEditorTable] makeSqlKeyValue];
        [self.fieldTabview selectTabViewItemAtIndex:2];
    }
}

#pragma mark - 高亮处理
- (NSDictionary *)keywords
{
    NSBundle *bd = [NSBundle bundleForClass:self.class];
    NSString *path = [bd pathForResource:@"keywords" ofType:@"plist"];
    
    NSDictionary *ws = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    for (NSDictionary *item in [ws allValues]) {
        NSColor* color = [NSColor colorWithDeviceRed:[[item objectForKey:@"color-red"] floatValue] green:[[item objectForKey:@"color-green"] floatValue] blue:[[item objectForKey:@"color-blue"] floatValue] alpha:1.0];
        NSScanner* scanner = [NSScanner scannerWithString:[item objectForKey:@"keywords"]];
        while (![scanner isAtEnd]) {
            NSString* keyword;
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:NULL];
            if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&keyword]) {
                [dic setObject:color forKey:keyword];
            }
        }
    }
    
    return dic;
}

- (NSDictionary *)sqlitekeywords
{
    if (!_sqlitekeywords) {
        _sqlitekeywords = [self keywords];
    }
    return _sqlitekeywords;
}

- (NSMutableString *)sqlitematchPattern
{
    if (!_sqlitematchPattern)
    {
        NSMutableString *pattern = [[NSMutableString alloc]init];
        
        NSArray *keys = [self.sqlitekeywords allKeys];
        for (NSString *key in keys) {
            [pattern appendFormat:@"\\b%@\\b|",key];
        }
        
        [pattern deleteCharactersInRange:NSMakeRange(pattern.length-1, 1)]; //删除最后的 |
        _sqlitematchPattern = pattern;
    }
    
    return _sqlitematchPattern;
}

// /是否匹配的是注释
- (BOOL)isMatchNotes:(NSString *)keyworks
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:NOTES_MATCH
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:nil];
    
    NSArray *array = [regex matchesInString:keyworks options:NSMatchingReportProgress range:NSMakeRange(0, keyworks.length)];
    
    return array.count > 0;
}

- (NSDictionary<NSString *, id> *)textView:(NSTextView *)view willCheckTextInRange:(NSRange)range options:(NSDictionary<NSString *, id> *)options types:(NSTextCheckingTypes *)checkingTypes
{
    if (!options) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (*checkingTypes & NSTextCheckingTypeRegularExpression)
        {
            [dic addEntriesFromDictionary:[self sqlitekeywords]];
        }
        
        if (*checkingTypes & NSTextCheckingTypeQuote)
        {
            NSColor* color = [NSColor colorWithDeviceRed:0.72f green:0.2f blue:0.63f alpha:1.0];
            [dic setObject:color forKey:@"double_quote"];
        }
        
        return dic;
    }

    return options;
}

- (NSArray<NSTextCheckingResult *> *)textView:(NSTextView *)view didCheckTextInRange:(NSRange)range types:(NSTextCheckingTypes)checkingTypes options:(NSDictionary<NSString *, id> *)options results:(NSArray<NSTextCheckingResult *> *)results orthography:(NSOrthography *)orthography wordCount:(NSInteger)wordCount
{
    @try {

        [view.textStorage beginEditing];
        [view.textStorage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, view.string.length)];
        
        if (checkingTypes & NSTextCheckingTypeRegularExpression)
        {
            
            //匹配关键词。
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.sqlitematchPattern
                                                                                   options:NSRegularExpressionCaseInsensitive|
                                          NSRegularExpressionUseUnixLineSeparators
                                                                                     error:nil];
            
            NSArray *array = [regex matchesInString:view.string options:NSMatchingReportProgress range:NSMakeRange(0, view.string.length)];
            
            for (NSTextCheckingResult *item in array)
            {
                NSString *keyws = [view.string substringWithRange:item.range];
                NSColor *cl = options[keyws];
                
                if (!cl) {
                    cl = [NSColor blueColor];
                }
                
                [view.textStorage addAttributes:@{NSForegroundColorAttributeName:cl} range:item.range];
            }
            
            //匹配引号
            NSRegularExpression *regexQuotes = [NSRegularExpression regularExpressionWithPattern:NOTES_QOUTES
                                                                                        options:NSRegularExpressionCaseInsensitive|
                                               NSRegularExpressionUseUnixLineSeparators
                                                                                          error:nil];
            
            array = [regexQuotes matchesInString:view.string options:NSMatchingReportProgress range:NSMakeRange(0, view.string.length)];
            
            for (NSInteger i = 0; i < array.count / 2; i++)
            {
                //成对引号出现
                NSTextCheckingResult *start = array[i*2];
                NSTextCheckingResult *end = array[i*2 + 1];
                
                if (start.range.location != NSNotFound && end.range.location != NSNotFound)
                {
                    NSRange srange = NSMakeRange(start.range.location, end.range.location + end.range.length - start.range.location);
                    
                    NSColor *cl = options[@"double_quote"];
                    if (!cl) {
                        cl = [NSColor colorWithDeviceRed:0.72f green:0.2f blue:0.63f alpha:1.0];
                    }
                    
                    [view.textStorage addAttributes:@{NSForegroundColorAttributeName:cl} range:srange];
                    
                }
            }
            
            //匹配注释
            NSRegularExpression *regexNotes = [NSRegularExpression regularExpressionWithPattern:NOTES_MATCH
                                                                                   options:NSRegularExpressionCaseInsensitive|
                                          NSRegularExpressionUseUnixLineSeparators
                                                                                     error:nil];

            array = [regexNotes matchesInString:view.string options:NSMatchingReportProgress range:NSMakeRange(0, view.string.length)];
 
            for (NSTextCheckingResult *item in array)
            {
                if (item.range.location != NSNotFound) {
                    
                    NSRange colorrange = item.range;
                    NSUInteger len = [view.string length];
                    
                    NSString *keyws = [view.string substringWithRange:colorrange];
                    
                    NSColor *cl = nil;//options[keyws];
                    
//                    if ([self isMatchNotes:keyws])
//                    { //匹配到注释
                    
                        NSString *lt = nil;
                        
                        if ([keyws isEqualToString:@"/*"]) {
                            lt = [view.string substringFromIndex:(item.range.location + item.range.length)];
                        }
                        
                        NSRange noterange = [lt rangeOfString:@"*/"];
                        if (noterange.location == NSNotFound && lt.length > 0) {
                            colorrange = NSMakeRange(item.range.location, len - item.range.location);
                        }
                        else if (lt.length > 0 && noterange.location != NSNotFound)
                        {
                            noterange = NSMakeRange(item.range.location + item.range.length + noterange.location, noterange.length);
                            if (item.range.location < noterange.location)
                            {
                                colorrange = NSMakeRange(item.range.location, noterange.location + noterange.length - item.range.location);
                            }
                            else
                            {
                                colorrange = NSMakeRange(NSNotFound, 0);
                            }
                        }
                        else
                        {
                            colorrange = item.range;//NSMakeRange(NSNotFound, 0);
                        }
                        
                        cl = [NSColor colorWithDeviceRed:0.0f green:0.51f blue:0.03f alpha:1.0];
//                    }
                    
                    if (colorrange.location != NSNotFound) {
                        [view.textStorage addAttributes:@{NSForegroundColorAttributeName:cl} range:colorrange];
                    }
                    
                }
            }

        }
        
        //暂不使用系统的，因为会把英文的"变为中文的，所以不用
        if (checkingTypes & NSTextCheckingTypeQuote)
        {
            if (results.count % 2 == 0) {
                //成对引号出现
                
                for (NSInteger i = 0; i < results.count / 2; i++)
                {
                    NSTextCheckingResult *start = results[i*2];
                    NSTextCheckingResult *end = results[i*2 + 1];
                    
                    if (start.range.location != NSNotFound && end.range.location != NSNotFound)
                    {
                        NSRange srange = NSMakeRange(start.range.location, end.range.location + end.range.length - start.range.location);
                        
                        NSColor *cl = options[@"double_quote"];
                        if (!cl) {
                            cl = [NSColor colorWithDeviceRed:0.72f green:0.2f blue:0.63f alpha:1.0];
                        }
                        
                        [view.textStorage addAttributes:@{NSForegroundColorAttributeName:cl} range:srange];
                        
                    }
                }
            }
            
        }
        
        [view.textStorage endEditing];

        return results;
    }
    @catch (NSException *exception) {
        return nil;
    }
}
@end
