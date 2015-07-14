//
//  FSDesignerViewController.m
//  FSSqliteDesigner
//
//  Created by fengsh on 9/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController.h"

@interface FSDesignerViewController ()<NSSplitViewDelegate,NSOutlineViewDataSource,
NSOutlineViewDelegate,NSTextFieldDelegate>
{
    NSURL                   *_modelUrl;
    NSMutableArray                              *_dbs;
}

@property (nonatomic, strong)               NSMenu                      *popMenu;
@end

@implementation FSDesignerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.splitview.delegate = self;
    _dbs = [[NSMutableArray alloc]init];

    self.dblistview.delegate = self;
    self.dblistview.dataSource = self;
    
    
    NSBundle *bd = [NSBundle bundleForClass:self.class];
    NSImage *imgadd = [bd imageForResource:@"add"];
    [self.btnAdd setImage:imgadd];
    NSImage *imgremove = [bd imageForResource:@"remove"];
    [self.btnRemove setImage:imgremove];
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
        return [_dbs count];//無item內容為第一層，所以顯示第一層的Staff數量
    }
    return ((FSNode*)item).childcounts;//非第一層時會將目前這層的物件傳入，此時我們列出這層下的Staff數量
}
//顯示index陣列值中的內容
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return [_dbs objectAtIndex:index];//無item內容為第一層，所以顯示第一層的內容
    }
    return [((FSNode*)item).childrens objectAtIndex:index];//非第一層時會將目前這層的物件傳入，此時我們列出這層下是否有還有
}
//返回YES代表下層還有物件要列出
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (!item) {
        return NO;//無item內容時代表已經無下層物件
    }
    return ((FSNode*)item).childcounts > 0;//非第一層時會將目前這層的物件傳入，此時我們列出這層下還有Staff時會將isBoss=YES
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return YES;
}


/* NOTE: this method is optional for the View Based OutlineView.
 */
//- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
//
//    return ((FSNode*)item).nodename;
//}

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
    result.textField.delegate = self;
    result.textField.allowsEditingTextAttributes = YES;
    result.textField.stringValue = node.nodename;
    return result;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
//    NSTextField *textField = [obj object];
//    NSString *newTitle = [textField stringValue];
//    
//    NSUInteger row = [self.sidebarOutlineView rowForView:textField];
//    
//    MyItem *myItem = [self.sidebarOutlineView itemAtRow:row];
//    myItem.name = newTitle;
}

//选中
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    
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
            return @"common";
            break;
        case nodeView:
            return @"view";
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
    NSString *v = _dbs.count>0?[NSString stringWithFormat:@"%ld",(long)_dbs.count]:@"";
    NSString *tbn = [NSString stringWithFormat:@"dbname%@",v];
    FSDatabse *ts = [[FSDatabse alloc]initWithDatabaseName:tbn];
    [_dbs addObject:ts];
    
    [self.dblistview reloadData];
}

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
    
}

- (void)toDoAddView:(NSMenuItem *)item
{
    
}

- (void)toDoAddTrigger:(NSMenuItem *)item
{
    
}

@end
