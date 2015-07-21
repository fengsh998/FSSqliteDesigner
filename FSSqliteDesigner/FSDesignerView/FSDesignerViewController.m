//
//  FSDesignerViewController.m
//  FSSqliteDesigner
//
//  Created by fengsh on 9/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface FSDesignerViewController ()<NSSplitViewDelegate,NSOutlineViewDataSource,
NSOutlineViewDelegate,NSTextFieldDelegate,NSTableViewDelegate,NSTableViewDataSource,
NSTextViewDelegate>
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

    self.designer = [[FSDesignFileObject alloc]init];

    self.dblistview.delegate = self;
    self.dblistview.dataSource = self;
    
    self.fieldlistview.delegate = self;
    self.fieldlistview.dataSource = self;
    
    self.tvMark.delegate = self;

    //默不显示
    [self.tabview selectTabViewItemWithIdentifier:@"id_none"];
    
    
    [self setButtonStyle];
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
    _modelUrl = [modelUrl copy];
    
    if (_modelUrl) {
        [self loadModelFilepath:_modelUrl];
    }
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
        else if ([selectitem isKindOfClass:[FSTableCategory class]])
        {
            [self enableItemAtIndex:1];
        }
        else if ([selectitem isKindOfClass:[FSIndexCategory class]])
        {
            [self enableItemAtIndex:2];
        }
        else if ([selectitem isKindOfClass:[FSViewCategory class]])
        {
            [self enableItemAtIndex:3];
        }
        else if ([selectitem isKindOfClass:[FSTriggerCategory class]])
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


- (void)loadModelFilepath:(NSURL *)modelUrl
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:modelUrl];
    
    NSLog(@"打开文件 = %@",dic);
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
        }
            break;
        case nodeTabel:
        {
            ///删除表
        }
            break;
        case nodeView:
        {
            ///删除视图
        }
            break;
        case nodeIndex:
        {
            ///删除索引
        }
            break;
        case nodeTigger:
        {
            ///删除触发器
        }
            break;
            
        default:
            break;
    }
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
    result.textField.delegate = self;
    result.textField.action = @selector(onEditTreeName:);
    [result.textField setSelectable:edit];
    return result;
}

//使用了view base后
/*
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField *textField = [obj object];
    NSString *newTitle = [textField stringValue];

    NSUInteger row = [self.dblistview rowForView:textField];

    FSNode *item = [self.dblistview itemAtRow:row];
    
    item.nodename = newTitle;
    if (item.type == nodeDatabase) {
        self.tfDBName.stringValue = [NSString stringWithFormat:@"库名:%@",item.nodename];
    }
}
*/

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField * tf = obj.object;
    SuppressPerformSelectorLeakWarning([tf.delegate performSelector:tf.action withObject:tf]);
}

///修改树结点
- (void)onEditTreeName:(NSTextField *)textfield
{
    NSString *newTitle = [textfield stringValue];
    
    NSUInteger row = [self.dblistview rowForView:textfield];
    
    FSNode *item = [self.dblistview itemAtRow:row];
    
    item.nodename = newTitle;
    if (item.type == nodeDatabase) {
        self.tfDBName.stringValue = [NSString stringWithFormat:@"库名:%@",item.nodename];
    }
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
        }
            break;
        case nodeColumn:
        {
            tid = @"id_column";
            [self.tvMark setEditable:YES];
            [self.fieldlistview reloadData];
            
            NSInteger idx = [nd.parentNode indexOfNode:nd];
            [self.fieldlistview selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
        }
            break;
        case nodeIndex:
        {
            tid = @"id_index";
        }
            break;
        case nodeView:
        {
            tid = @"id_view";
        }
            break;
        case nodeTigger:
        {
            tid = @"id_trigger";
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
    NSString *v = self.designer.databases.count>0?[NSString stringWithFormat:@"%ld",(long)self.designer.databases.count]:@"";
    
    NSString *tbn = [NSString stringWithFormat:@"dbname%@",v];
    
    [self.designer addDatabaseWithName:tbn];
    
    [self.dblistview reloadData];
}

#pragma mark - 获取选中的项
- (FSNode *)getSelectItemInList
{
    return [self.dblistview itemAtRow:[self.dblistview selectedRow]];
}

//创建表的时候把视图，索引，触发器的固定属性加上
- (void)toDoAddTable:(NSMenuItem *)item
{
    id selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            NSInteger tbcount = ((FSDatabse *)selectitem).tables.count;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";

            [((FSDatabse *)selectitem)addTable:[NSString stringWithFormat:@"tablename%@",v]];
        }
        else if ([selectitem isKindOfClass:[FSTableCategory class]])
        {
            NSInteger tbcount = ((FSTableCategory *)selectitem).childcounts;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
            FSTable *newtable = [[FSTable alloc]initWithTableName:[NSString stringWithFormat:@"tablename%@",v]];
            [((FSTableCategory *)selectitem) addChildrenNode:newtable];
        }
        
        [self.dblistview reloadData];
    }
}

- (void)toDoAddIndex:(NSMenuItem *)item
{
    id selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            NSInteger tbcount = ((FSDatabse *)selectitem).indexObjects.count;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
            
            [((FSDatabse *)selectitem)addIndex:[NSString stringWithFormat:@"index%@",v]];
        }
        else if ([selectitem isKindOfClass:[FSIndexCategory class]])
        {
            NSInteger tbcount = ((FSIndexCategory *)selectitem).childcounts;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
            
            FSIndex *newIndex = [[FSIndex alloc]initWithIndexName:[NSString stringWithFormat:@"index%@",v]];
            [((FSIndexCategory *)selectitem) addChildrenNode:newIndex];
        }
        
        [self.dblistview reloadData];
    }
}

- (void)toDoAddView:(NSMenuItem *)item
{
    id selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            NSInteger tbcount = ((FSDatabse *)selectitem).views.count;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
            
            [((FSDatabse *)selectitem)addView:[NSString stringWithFormat:@"view%@",v]];
        }
        else if ([selectitem isKindOfClass:[FSViewCategory class]])
        {
            NSInteger tbcount = ((FSViewCategory *)selectitem).childcounts;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
            
            FSView *newIndex = [[FSView alloc]initWithViewName:[NSString stringWithFormat:@"view%@",v]];
            [((FSViewCategory *)selectitem) addChildrenNode:newIndex];
        }
        
        [self.dblistview reloadData];
    }
}

- (void)toDoAddTrigger:(NSMenuItem *)item
{
    id selectitem = [self getSelectItemInList];
    if (selectitem)
    {
        if ([selectitem isKindOfClass:[FSDatabse class]])
        {
            NSInteger tbcount = ((FSDatabse *)selectitem).triggers.count;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
            
            [((FSDatabse *)selectitem)addTrigger:[NSString stringWithFormat:@"trigger%@",v]];
        }
        else if ([selectitem isKindOfClass:[FSTriggerCategory class]])
        {
            NSInteger tbcount = ((FSTriggerCategory *)selectitem).childcounts;
            NSString *v = tbcount > 0 ? [NSString stringWithFormat:@"%ld",(long)tbcount] : @"";
            
            FSTrigger *newIndex = [[FSTrigger alloc]initWithTriggerName:[NSString stringWithFormat:@"trigger%@",v]];
            [((FSTriggerCategory *)selectitem) addChildrenNode:newIndex];
        }
        
        [self.dblistview reloadData];
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

@end
