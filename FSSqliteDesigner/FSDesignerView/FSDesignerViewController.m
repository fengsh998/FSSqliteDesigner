//
//  FSDesignerViewController.m
//  FSSqliteDesigner
//
//  Created by fengsh on 9/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController.h"

typedef enum
{
    stDatabase              = 1,                 //库
    stTabel                 = 1 << 1,            //表
    stIndex                 = 1 << 2,            //索引
    stView                  = 1 << 3,            //视图
    stTigger                = 1 << 4             //触发器
} SelectType;

@interface FSDesignerViewController ()<NSSplitViewDelegate,NSOutlineViewDataSource,NSOutlineViewDelegate>
{
    NSURL                   *_modelUrl;
}

@property (nonatomic, strong)               NSMenu                      *popMenu;
@end

@implementation FSDesignerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.splitview.delegate = self;
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
//        menuItem = [[NSMenuItem alloc] initWithTitle:@"添加索引" action:@selector(toDoAddIndex:) keyEquivalent:@""];
//        [mContextualMenu addItem:menuItem];
//        menuItem = [[NSMenuItem alloc] initWithTitle:@"添加视图" action:@selector(toDoAddTable:) keyEquivalent:@""];
//        [mContextualMenu addItem:menuItem];
//        menuItem = [[NSMenuItem alloc] initWithTitle:@"添加触发器" action:@selector(toDoAddTable:) keyEquivalent:@""];
//        [mContextualMenu addItem:menuItem];
        
        _popMenu = mContextualMenu;
    }
    
    return _popMenu;
}

- (void)updateMenuForSelectType:(SelectType)stype
{
    NSMenuItem * item = [self.popMenu itemAtIndex:1];
    
    if (stype == stDatabase) {
        [item setAction:nil];
    }
    else
    {
        [item setAction: @selector(toDoAddTable:)];
    }
}

- (void)loadModelFilepath:(NSURL *)modelUrl
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:modelUrl];
    
    NSLog(@"打开文件 = %@",dic);
}

- (IBAction)btnAddClicked:(id)sender
{
    NSPoint location = CGPointMake(20, 60);
    NSMenu *contextmenu = [self popMenu];

    [self updateMenuForSelectType:stTabel];
    
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
        return [self.viewlists count];//無item內容為第一層，所以顯示第一層的Staff數量
    }
    return ((FSViewListModel*)item).subvs.count;//非第一層時會將目前這層的物件傳入，此時我們列出這層下的Staff數量
}
//顯示index陣列值中的內容
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return [self.viewlists objectAtIndex:index];//無item內容為第一層，所以顯示第一層的內容
    }
    return [((FSViewListModel*)item).subvs objectAtIndex:index];//非第一層時會將目前這層的物件傳入，此時我們列出這層下是否有還有
}
//返回YES代表下層還有物件要列出
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (!item) {
        return NO;//無item內容時代表已經無下層物件
    }
    return ((FSViewListModel*)item).subvs.count > 0;//非第一層時會將目前這層的物件傳入，此時我們列出這層下還有Staff時會將isBoss=YES
}

/* NOTE: this method is optional for the View Based OutlineView.
 */
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    NSView *av = ((FSViewListModel*)item).v;
    return [NSString stringWithFormat:@"%@ <%p>",av.className,av];
}


#pragma mark - 菜单处理
- (void)toDoAddDatabase:(NSMenuItem *)item
{
    
}

//创建表的时候把视图，索引，触发器的固定属性加上
- (void)toDoAddTable:(NSMenuItem *)item
{
    
}

@end
