//
//  FSTriggerTableViewImpl.m
//  FSSqliteDesigner
//
//  Created by fengsh on 31/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSTriggerTableViewImpl.h"
#import "FSDesignFileObject.h"

@implementation FSTriggerTableViewImpl

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSArray *columns = self.dataSource[@"columns"];
    return columns.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView
            viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray *columns = self.dataSource[@"columns"];
    NSArray *selects = self.dataSource[@"selected"];
    FSColumn *column = [columns objectAtIndex:row];
    
    NSTableCellView *v = nil;
    if ([tableColumn.identifier isEqualToString:@"trigger_1"]) {
        v = [tableView makeViewWithIdentifier:@"check" owner:self];
        NSButton *chk = v.subviews[0];
        chk.tag = row;
        chk.target = self;
        chk.action = @selector(onCheckClicked:);
        [chk setState:0];
        if (selects) {
            [chk setState:[selects containsObject:[NSString stringWithFormat:@"\"%@\"",column.fieldName]]];
        }
    }
    else if ([tableColumn.identifier isEqualToString:@"trigger_2"])
    {
        v = [tableView makeViewWithIdentifier:@"title" owner:self];
        v.textField.stringValue = column.fieldName;
    }
    
    return v;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 22;
}

- (void)onCheckClicked:(NSButton *)check
{
    NSArray *columns = self.dataSource[@"columns"];
    FSColumn *column = [columns objectAtIndex:check.tag];
    
    if ([self.delegate respondsToSelector:@selector(FSTrigger:SelectColumns:)])
    {
        [self.delegate FSTrigger:self SelectColumns:column];
    }
}

@end
