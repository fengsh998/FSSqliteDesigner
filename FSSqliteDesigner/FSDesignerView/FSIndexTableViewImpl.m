//
//  FSIndexTableViewImpl.m
//  FSSqliteDesigner
//
//  Created by fengsh on 29/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSIndexTableViewImpl.h"
#import "FSDesignFileObject.h"

@implementation FSIndexTableViewImpl


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
    if ([tableColumn.identifier isEqualToString:@"index_1"]) {
        v = [tableView makeViewWithIdentifier:@"check" owner:self];
        NSButton *chk = v.subviews[0];
        [chk setState:0];
        if (selects) {
            [chk setState:[selects containsObject:column.fieldName]];
        }
    }
    else if ([tableColumn.identifier isEqualToString:@"index_2"])
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


@end
