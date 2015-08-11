//
//  FSDesignerViewController.m
//  FSSqliteDesigner
//
//  Created by fengsh on 9/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController.h"
#import "FSDesignerViewController+column.h"
#import "FSDesignerViewController+index.h"
#import "FSDesignerViewController+view.h"
#import "FSDesignerViewController+Trigger.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface FSDesignerViewController ()<NSSplitViewDelegate,NSOutlineViewDataSource,
NSOutlineViewDelegate,NSTextFieldDelegate,NSTableViewDelegate,NSTableViewDataSource,
NSTextViewDelegate,NSTabViewDelegate,NSTextDelegate>
{
    NSURL                               *_modelUrl;
}

@property (nonatomic, strong)               NSMenu                      *popMenu;
@end

@implementation FSDesignerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.splitview.delegate = self;

    //self.designer = [[FSDesignFileObject alloc]init];

    self.dblistview.delegate = self;
    self.dblistview.dataSource = self;
    
    self.fieldlistview.delegate = self;
    self.fieldlistview.dataSource = self;
    
    self.tvMark.delegate = self;

    [self setTextViewStyle:self.tvCreateSql];

    //默不显示
    [self.fieldTabview setDelegate:self];
    [self.tabview selectTabViewItemWithIdentifier:@"id_none"];
    
    // 索引模块
    self.indexTableviewDispatcher = [[FSIndexTableViewImpl alloc]init];
    self.indexTableview.delegate = self.indexTableviewDispatcher;
    self.indexTableview.dataSource = self.indexTableviewDispatcher;
    
    self.tfIndexName.target = self;
    self.tfIndexName.action = @selector(onIndexNameChange:);
    
    [self setTextViewStyle:self.tvIndexSql];
    
    // 视图模块
    self.tfViewName.target = self;
    self.tfViewName.action = @selector(onViewNameChange:);
    
    [self setTextViewStyle:self.tvViewSql];
    
    //触发器
    self.triggerTableviewDispatcher     = [[FSTriggerTableViewImpl alloc]init];
    self.triggerTableviewDispatcher.delegate = self;
    self.triggerTableview.delegate      = self.triggerTableviewDispatcher;
    self.triggerTableview.dataSource    = self.triggerTableviewDispatcher;
    
    self.tfTriggerName.target = self;
    self.tfTriggerName.action = @selector(onTriggerNameChange:);

    [self setTextViewStyle:self.tvTriggerSqlEdit];
    
    [self setTextViewStyle:self.tvTriggerSql];

    [self setButtonStyle];
    
    [self clean];
    
    [self setDefaultOptions];
    [self setDefaultActionForDelete];
    [self setDefaultActionForUpdate];
}

- (void)clean
{
    [self.popTargetTables removeAllItems];
    [self.popTargetColumns removeAllItems];
    [self.popOptions removeAllItems];
    [self.popActionForDelete removeAllItems];
    [self.popActionForUpdate removeAllItems];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (NSURL *)modelUrl
{
    return _modelUrl;
}

- (void)setModelUrl:(NSURL *)modelUrl
{
    if ([[_modelUrl absoluteString]isEqualToString:[modelUrl absoluteString]])
        return;
        
    _modelUrl = [modelUrl copy];
    
    if (_modelUrl) {
        [self loadModelFilepath:_modelUrl];
    }
}

#pragma mark - 设置textview样式
- (void)setTextViewStyle:(NSTextView *)tv
{
    tv.delegate = self;
    tv.automaticQuoteSubstitutionEnabled = NO;
    tv.automaticDashSubstitutionEnabled = NO;
    //不开启自动替换
    tv.automaticTextReplacementEnabled = NO;
    
    tv.enabledTextCheckingTypes = NSTextCheckingTypeOrthography |NSTextCheckingTypeRegularExpression ;//| NSTextCheckingTypeQuote;
}

#pragma mark - 设置按钮样式
- (void)setButtonStyle
{
    NSBundle *bd = [NSBundle bundleForClass:self.class];
    NSImage *imgadd = [bd imageForResource:@"add"];
    [self.btnAdd setImage:imgadd];
    [self.btnAddColumn setImage:[imgadd copy]];
    NSImage *imgremove = [bd imageForResource:@"remove"];
    [self.btnRemove setImage:imgremove];
    [self.btnRemoveColumn setImage:[imgremove copy]];
}

#pragma mark - 设置弹出菜单
- (NSMenu *)popMenu
{
    if (!_popMenu)
    {
        NSMenu *mContextualMenu = [[NSMenu alloc] initWithTitle:@"Menu Title"];
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"添加数据库" action:@selector(toDoAddDatabase:) keyEquivalent:@""];
        menuItem.target = self;
        [mContextualMenu addItem:menuItem];
        
        menuItem = [[NSMenuItem alloc] initWithTitle:@"添加表" action:nil keyEquivalent:@""];
        menuItem.target = self;
        [mContextualMenu addItem:menuItem];
        menuItem = [[NSMenuItem alloc] initWithTitle:@"添加索引" action:nil keyEquivalent:@""];
        [mContextualMenu addItem:menuItem];
        menuItem = [[NSMenuItem alloc] initWithTitle:@"添加视图" action:nil keyEquivalent:@""];
        [mContextualMenu addItem:menuItem];
        menuItem = [[NSMenuItem alloc] initWithTitle:@"添加触发器" action:nil keyEquivalent:@""];
        [mContextualMenu addItem:menuItem];
        
        _popMenu = mContextualMenu;
    }
    
    return _popMenu;
}

- (void)disableAllItem
{
    for (NSInteger i = 1; i < self.popMenu.itemArray.count ; i++) {
        NSMenuItem * item = [self.popMenu itemAtIndex:i];
        [item setAction:nil];
    }
}

- (void)enableItemAtIndex:(NSInteger)index
{
    switch (index) {
        case 1: //enable table
        {
            NSMenuItem * item = [self.popMenu itemAtIndex:1];
            if (!item.action) {
                [item setAction: @selector(toDoAddTable:)];
            }
        }
            break;
        case 2:
        {
            NSMenuItem * item = [self.popMenu itemAtIndex:2];
            if (!item.action) {
                [item setAction: @selector(toDoAddIndex:)];
            }
        }
            break;
        case 3:
        {
            NSMenuItem * item = [self.popMenu itemAtIndex:3];
            if (!item.action) {
                [item setAction: @selector(toDoAddView:)];
            }
        }
            break;
        case 4:
        {
            NSMenuItem * item = [self.popMenu itemAtIndex:4];
            if (!item.action) {
                [item setAction: @selector(toDoAddTrigger:)];
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 根据选中项来启用菜单
- (void)checkMenuState
{
    FSNode *selectitem = [self getSelectItemInList];
    if (selectitem) {
        if (selectitem.type == nodeDatabase)
        {
            [self enableItemAtIndex:1];
            [self enableItemAtIndex:2];
            [self enableItemAtIndex:3];
            [self enableItemAtIndex:4];
        }
        else if ([selectitem isKindOfClass:[FSTableCategory class]] || selectitem.type == nodeTabel)
        {
            [self enableItemAtIndex:1];
        }
        else if ([selectitem isKindOfClass:[FSIndexCategory class]] || selectitem.type == nodeIndex)
        {
            [self enableItemAtIndex:2];
        }
        else if ([selectitem isKindOfClass:[FSViewCategory class]] || selectitem.type == nodeView )
        {
            [self enableItemAtIndex:3];
        }
        else if ([selectitem isKindOfClass:[FSTriggerCategory class]] || selectitem.type == nodeTigger)
        {
            [self enableItemAtIndex:4];
        }
    }
}

- (NSImage *)getIconWithName:(NSString *)name
{
    NSBundle *bd = [NSBundle bundleForClass:self.class];
    NSImage *img = [bd imageForResource:name];
    return img;
}

#pragma mark - 加载数据
- (void)loadModelFilepath:(NSURL *)modelUrl
{
    NSString *path = [modelUrl path];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSError *err = nil;
        self.designer = [FSDesignFileObject loadFromFile:modelUrl error:&err];
        if (err) {
            NSLog(@"sqlite model file data error. open failed.");
            [self alterCheckMessage:@"sqlitemodel数据异常，请检查是否人为修改。" reSetFocus:nil];
            return;
        }
        [self.dblistview reloadData];
        
        [self setFocus:self.dblistview];
    }
}

- (IBAction)btnAddClicked:(id)sender
{
    [self disableAllItem];
    [self checkMenuState];
    
    NSPoint location = CGPointMake(20, 60);
    NSMenu *contextmenu = [self popMenu];
    [contextmenu popUpMenuPositioningItem:nil atLocation:location inView:self.view];
}

- (IBAction)btnRemoveClicked:(id)sender
{
    FSNode *node = [self getSelectItemInList];
    
    switch (node.type) {
        case nodeDatabase:
        {
            ///删除库做二次确认
            [self.designer removeDatabaseOfObject:(FSDatabse *)node];
        }
            break;
        case nodeTabel:
        {
            ///删除表
            FSTableCategory *tbp = (id)node.parentNode;
            [tbp removeChildrenNode:node];
        }
            break;
        case nodeView:
        {
            ///删除视图
            FSViewCategory *vp = (id)node.parentNode;
            [vp removeChildrenNode:node];
        }
            break;
        case nodeIndex:
        {
            ///删除索引
            FSIndexCategory *ip = (id)node.parentNode;
            [ip removeChildrenNode:node];
        }
            break;
        case nodeTigger:
        {
            ///删除触发器
            FSTriggerCategory *tgp = (id)node.parentNode;
            [tgp removeChildrenNode:node];
        }
            break;
            
        default:
            return;
            break;
    }
    
    [self.dblistview reloadData];
    [self.tabview selectTabViewItemWithIdentifier:@"id_none"];
}

#pragma mark - splitedelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == 0) {
        return 200;
    }
    
    return 0;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == 0) {
        return 300;
    }
    
    return 1000;
}

#pragma mark - outline 代理
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item) {
        return self.designer.databases.count;
    }
    return ((FSNode*)item).childcounts;
}

//显示index结点中的內容
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return [self.designer.databases objectAtIndex:index];//无item內容為第一层，所以显示第一层的內容
    }
    return [((FSNode*)item).childrens objectAtIndex:index];//非第一层时会将目前的内容结点加载
}

//返回YES代表下层还有孩子要列出
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (!item) {
        return NO;//无item內容时代表无孩子
    }
    return ((FSNode*)item).childcounts > 0;
}

//双击修改 (但可惜的view base 不支持该方法)
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
    FSNode *editnode = item;
    if (editnode.type != nodeNone) {
        editnode.nodename = object;
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView *result = [outlineView makeViewWithIdentifier:@"listcell"
                                                            owner:self];
    FSNode *node = item;
    NSString *iconname = [self iconnameWithNode:node];
    
    NSImage *img =[self getIconWithName:iconname];
    
    [[result imageView] setImage:img];
    result.textField.stringValue = node.nodename;
    BOOL edit = [self isCanEditText:node];
    [result.textField setEditable:edit];
    ((FSTextField*)result.textField).drawBackgroundWhenFocus = YES;
    result.textField.delegate = self;
    result.textField.action = @selector(onEditTreeName:);
    [result.textField setSelectable:edit];
    return result;
}

//使用了view base后
///注意，所有NSTextField结束修改时都会触发
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField * tf = obj.object;
    tf.drawsBackground = NO;
    SuppressPerformSelectorLeakWarning([tf.delegate performSelector:tf.action withObject:tf]);
}

///修改树结点
- (void)onEditTreeName:(NSTextField *)textfield
{
    NSString *newTitle = [textfield stringValue];
    
    NSUInteger row = [self.dblistview rowForView:textfield];
    
    FSNode *item = [self.dblistview itemAtRow:row];
    
    BOOL exsistsamename = NO;
    NSString *hint = @"";
    
    switch (item.type) {
        case nodeDatabase:
        {
            exsistsamename = [self.designer exsistDatabaseOfName:newTitle butNotInclude:(id)item];
            hint = @"已存在相同名称的数据库";
        }
            break;
        case nodeTabel:
        {
            exsistsamename = [item exsistNodeNameInNeighbour:newTitle];
            hint = @"已存在相同名称的表名";
        }
            break;
        case nodeIndex:
        {
            exsistsamename = [item exsistNodeNameInNeighbour:newTitle];
            hint = @"已存在相同名称的索引名";
        }
            break;
        case nodeView:
        {
            exsistsamename = [item exsistNodeNameInNeighbour:newTitle];
            hint = @"已存在相同名称的视图名";
        }
            break;
        case nodeTigger:
        {
            exsistsamename = [item exsistNodeNameInNeighbour:newTitle];
            hint = @"已存在相同名称的触发器名";
        }
            break;
            
        default:
            break;
    }
    
    if (exsistsamename && hint.length > 0) {
        //如有需要则弹窗提示
        [self alterCheckMessage:hint reSetFocus:textfield];
        return;
    }
    
    item.nodename = newTitle;
    if (item.type == nodeDatabase) {
        self.tfDBName.stringValue = [NSString stringWithFormat:@"库名:%@",item.nodename];
    }
}

- (void)alterCheckMessage:(NSString *)msg reSetFocus:(NSView *)v
{

    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:msg];
    
    [alert setAlertStyle:NSInformationalAlertStyle];
//    NSImage *icon = [NSImage imageNamed:@"icon.png"];
//    [alert setIcon:icon];
    [alert layout];
    
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (v) {
            [self setFocus:v];
        }
    }];
}

#pragma mark - 选中
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    FSNode *nd = [self getSelectItemInList];
    NSString *tid = @"id_none";
    switch (nd.type) {
        case nodeDatabase:
        {
            tid = @"id_database";
            self.tfDBName.stringValue = [NSString stringWithFormat:@"库名:%@",nd.nodename];
            
            BOOL ischeck = ((FSDatabse *)nd).dynamic;
            [self.btnCheckDymic setState:ischeck?NSOnState:NSOffState];
        }
            break;
        case nodeTabel:
        {
            tid = @"id_column";
            [self.tvMark setEditable:NO];
            [self.fieldlistview reloadData];
            [self.fieldTabview selectTabViewItemAtIndex:0];
        }
            break;
        case nodeColumn:
        {
            tid = @"id_column";
            [self.tvMark setEditable:YES];
            [self.fieldlistview reloadData];
            
            NSInteger idx = [nd.parentNode indexOfNode:nd];
            [self.fieldlistview selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
            
            [self.fieldTabview selectTabViewItemAtIndex:0];
        }
            break;
        case nodeIndex:
        {
            tid = @"id_index";
            
            FSNode *root = [self getRootItemOfNode:nd];
            
            if (root.type == nodeDatabase) {
                FSDatabse *db = (id)root;
                [self loadIndex:(id)nd withIndexTargetTables:[db tables]];
            }
        }
            break;
        case nodeView:
        {
            tid = @"id_view";
            [self loadView:(id)nd];
        }
            break;
        case nodeTigger:
        {
            tid = @"id_trigger";
            FSNode *root = [self getRootItemOfNode:nd];
            
            if (root.type == nodeDatabase) {
                FSDatabse *db = (id)root;
                [self loadTriggerView:(id)nd withTables:[db tables]];
            }
        }
            break;
            
        default:
            break;
    }
    
    [self.tabview selectTabViewItemWithIdentifier:tid];
}

- (BOOL)isCanEditText:(FSNode *)item
{
    if ([item isKindOfClass:[FSTableCategory class]] ||
    [item isKindOfClass:[FSIndexCategory class]] ||
    [item isKindOfClass:[FSViewCategory class]] ||
    [item isKindOfClass:[FSTriggerCategory class]]||
    item.type == nodeColumn)
    {
        return NO;
    }
    return YES;
}

- (NSString *)iconnameWithNode:(FSNode *)node
{
    switch (node.type) {
        case nodeDatabase:
            return @"dblist";
            break;
        case nodeTabel:
            return @"table";
            break;
        case nodeIndex:
            return @"trigger"; //使用与触发器一样的图标
            break;
        case nodeView:
            return @"view";
            break;
        case nodeColumn:
            return @"column";
            break;
        case nodeTigger:
            return @"trigger";
            break;
            
        default:
            if ([node isKindOfClass:[FSTableCategory class]]) {
                return @"tables";
            }
            else if ([node isKindOfClass:[FSViewCategory class]])
            {
                return @"views";
            }
            break;
    }
    return @"common";
}

#pragma mark - 菜单处理
- (void)toDoAddDatabase:(NSMenuItem *)item
{
    FSNode *node = [self getSelectItemInList];
    
    BOOL useInsert = NO;
    NSInteger idx = -1;
    if (node.type == nodeDatabase) {
        idx = [self.designer indexOfDatabaseObject:(FSDatabse *)node];
        if (idx >=0 && idx < self.designer.databases.count - 1) {
            useInsert = YES;
        }
    }

    NSString *v = self.designer.databases.count > 0?[NSString stringWithFormat:@"%ld",(long)self.designer.databases.count]:@"";
    
    NSString *tbn = [NSString stringWithFormat:@"dbname%@",v];
    
    if ([self.designer exsistDatabaseOfName:tbn])
    {
        tbn = [NSString stringWithFormat:@"%@_1",v];
    }
    
    FSDatabse *db = nil;
    if (useInsert && (idx != -1)) {
        db = [self.designer insertDatabaseWithName:tbn atIndex:idx];
    }
    else
    {
        db = [self.designer addDatabaseWithName:tbn];
    }
    
    [self.dblistview reloadData];
    
    [self toDoSelectedTreeNode:db];
    
    [self setFocus:self.dblistview];
}

#pragma mark - 获取选中的项
- (FSNode *)getSelectItemInList
{
    return [self.dblistview itemAtRow:[self.dblistview selectedRow]];
}

- (FSNode *)getRootItemOfNode:(FSNode *)selectedNode
{
    FSNode *parent = selectedNode;
    
    while (parent.parentNode) {
        parent = parent.parentNode;
    }
    
    return parent;
}

#pragma mark - 选中Tree中某个结点
- (void)toDoSelectedTreeNode:(FSNode *)node
{
    if (!node) {
        return;
    }
    NSInteger idx = [self.dblistview rowForItem:node];
    
    // -1 表示未展开
    if (idx != -1) {
        [self.dblistview selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
    }
}

- (void)setFocus:(NSView *)v
{
    [self.view.window makeFirstResponder:v];
}

#pragma mark - 添加表
//创建表的时候把视图，索引，触发器的固定属性加上
- (void)toDoAddTable:(NSMenuItem *)item
{
    FSNode *selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSTable class]]) {
            selectitem = selectitem.parentNode;
        }
        
        FSTableCategory *selected = (id)selectitem;
        FSTable *newtable = nil;
        FSDatabse *db = nil;
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            db = (FSDatabse *)selectitem;
            
            NSString *name = [db makeUniqueTableName];
            
            newtable = [db addTable:name];
            selected = db.childrens[0];
        }
        else if ([selectitem isKindOfClass:[FSTableCategory class]])
        {
            NSString *name = [((FSTableCategory *)selectitem) makeUniqueTableName];
            newtable = [[FSTable alloc]initWithTableName:name];
            [((FSTableCategory *)selectitem) addChildrenNode:newtable];
        }
        
        [self.dblistview reloadData];
        
        if (db) {
            [self.dblistview expandItem:db];
        }
        
        [self.dblistview expandItem:selected];
        
        [self toDoSelectedTreeNode:newtable];
    }
}

#pragma mark - 添加索引
- (void)toDoAddIndex:(NSMenuItem *)item
{
    FSNode *selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSIndex class]]) {
            selectitem = selectitem.parentNode;
        }
        
        FSIndexCategory *selected = (id)selectitem;
        FSIndex *newIndex = nil;
        FSDatabse *db = nil;
        
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            db = (FSDatabse *)selectitem;
            NSString *name = [db makeUniqueIndexName];
            newIndex = [db addIndex:name];
            selected = db.childrens[1];
        }
        else if ([selectitem isKindOfClass:[FSIndexCategory class]])
        {
            NSString *name = [((FSIndexCategory *)selectitem) makeUniqueIndexName];
            newIndex = [[FSIndex alloc]initWithIndexName:name];
            [((FSIndexCategory *)selectitem) addChildrenNode:newIndex];
        }
        
        [self.dblistview reloadData];
        
        if (db) {
            [self.dblistview expandItem:db];
        }
        
        [self.dblistview expandItem:selected];
        
        [self toDoSelectedTreeNode:newIndex];
    }
}

#pragma mark - 添加视图
- (void)toDoAddView:(NSMenuItem *)item
{
    FSNode *selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSView class]]) {
            selectitem = selectitem.parentNode;
        }
        
        FSViewCategory *selected = (id)selectitem;
        FSView *newView = nil;
        FSDatabse *db = nil;
        
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            db = (FSDatabse *)selectitem;
            NSString *name = [db makeUniqueViewName];
            newView = [db addView:name];
            selected = db.childrens[2];
        }
        else if ([selectitem isKindOfClass:[FSViewCategory class]])
        {
            NSString *name = [((FSViewCategory *)selectitem) makeUniqueViewName];
            newView = [[FSView alloc]initWithViewName:name];
            [((FSViewCategory *)selectitem) addChildrenNode:newView];
        }
        
        [self.dblistview reloadData];
        
        if (db) {
            [self.dblistview expandItem:db];
        }
        
        [self.dblistview expandItem:selected];
        
        [self toDoSelectedTreeNode:newView];
    }
}

#pragma mark - 添加触发器
- (void)toDoAddTrigger:(NSMenuItem *)item
{
    FSNode *selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSTrigger class]]) {
            selectitem = selectitem.parentNode;
        }
        
        FSViewCategory *selected = (id)selectitem;
        FSTrigger *newTrigger = nil;
        FSDatabse *db = nil;
        
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            db = (FSDatabse *)selectitem;
            NSString *name = [db makeUniqueTriggerName];
            newTrigger = [((FSDatabse *)selectitem)addTrigger:name];
            selected = db.childrens[3];
        }
        else if ([selectitem isKindOfClass:[FSTriggerCategory class]])
        {
            NSString *name = [((FSTriggerCategory *)selectitem) makeUniqueTriggerName];
            newTrigger = [[FSTrigger alloc]initWithTriggerName:name];
            [((FSTriggerCategory *)selectitem) addChildrenNode:newTrigger];
        }
        
        [self.dblistview reloadData];
        
        if (db) {
            [self.dblistview expandItem:db];
        }
        
        [self.dblistview expandItem:selected];
        
        [self toDoSelectedTreeNode:newTrigger];
    }
}

- (IBAction)onCheckDymicClicked:(NSButton *)sender
{
    id selectitem = [self getSelectItemInList];
    if ([selectitem isKindOfClass:[FSDatabse class]]) {
        FSDatabse *sdb = (FSDatabse *)selectitem;
        sdb.dynamic = sender.state;
    }
}

- (IBAction)onMakeEntityForTables:(id)sender
{
    
}

- (IBAction)onExportsSql:(id)sender
{
    
}

- (void)todoSaveSetValue
{
    [self saveTableSettings];
    [self saveIndexSettings];
    [self saveViewSettings];
    [self saveTriggerSettings];
}

@end
