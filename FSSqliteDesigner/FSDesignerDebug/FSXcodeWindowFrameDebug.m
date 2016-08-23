//
//  FSXcodeWindowFrameDebug.m
//  FSSqliteDesigner
//
//  Created by fengsh on 7/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSXcodeWindowFrameDebug.h"
#import "FSViewListModel.h"

@interface FSXcodeWindowFrameDebug ()<NSOutlineViewDelegate,NSOutlineViewDataSource>
{
    FSViewListModel                 *prevousModel;
}
@property (nonatomic, strong) NSMutableArray                        *viewlists;
@end

@implementation FSXcodeWindowFrameDebug

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.viewlists = [NSMutableArray array];
    
    [self createViewTree];
    
    self.treeview.delegate = self;
    self.treeview.dataSource = self;

}

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

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSOutlineView *ov = notification.object;
    
    if (prevousModel) {
        [self disableColor:prevousModel];
    }
    
    prevousModel = [ov itemAtRow:[ov selectedRow]];
    
    [self enableColor:prevousModel];
}


- (void)disableColor:(FSViewListModel *)item
{
    item.v.wantsLayer = NO;
    item.v.layer.borderWidth = 0.0f;
    item.v.layer.borderColor = [NSColor clearColor].CGColor;
}

- (void)enableColor:(FSViewListModel *)item
{
    item.v.wantsLayer = YES;
    item.v.layer.borderWidth = 2.0f;
    item.v.layer.borderColor = [NSColor redColor].CGColor;
}

- (void)addView:(NSView *)v currentlevel:(NSInteger)level toList:(NSMutableArray *)list
{
    FSViewListModel *m = [[FSViewListModel alloc]init];
    m.v = v;
    m.level = level;
    m.subvs = v.subviews.count > 0 ? [NSMutableArray array] : nil;
    [list addObject:m];
    
    for (NSView *subview in v.subviews) {
        
        if (subview.subviews.count > 0) {
            [self addView:subview currentlevel:level + 1 toList:m.subvs];
        }
        else
        {
            FSViewListModel *sm = [[FSViewListModel alloc]init];
            sm.v = subview;
            sm.level = level + 1;
            [m.subvs addObject:sm];
        }
    }
}

- (void)createViewTree
{
    [self.viewlists removeAllObjects];
    
    [self addView:((NSView*)self.xcwindow.contentView).superview currentlevel:0 toList:self.viewlists];
    
    [self addView:self.xcwindow.contentView currentlevel:0 toList:self.viewlists];
    
}
- (IBAction)onBtnClean:(id)sender
{
    
}

- (IBAction)onBtnRefresh:(id)sender
{
    [self createViewTree];
    
    [self.treeview reloadData];
}

@end
