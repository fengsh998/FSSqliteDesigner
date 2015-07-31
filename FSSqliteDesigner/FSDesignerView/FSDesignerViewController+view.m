//
//  FSDesignerViewController+view.m
//  FSSqliteDesigner
//
//  Created by fengsh on 30/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerViewController+view.h"
#import "FSUtils.h"

@implementation FSDesignerViewController(view)

//获取当前选中的索引
- (FSView *)getCurrentEditorView
{
    FSNode *node = [self getSelectItemInList];
    
    if ([node isKindOfClass:[FSView class]]) {
        return (FSView *)node;
    }
    
    return nil;
}

- (void)onViewNameChange:(NSTextField *)textfield
{
    BOOL exsist = [[self getCurrentEditorView] exsistNodeNameInNeighbour:textfield.stringValue];
    
    if (exsist)
    {
        textfield.stringValue = [self getCurrentEditorView].viewName;
        [self alterCheckMessage:@"存在同名视图" reSetFocus:textfield];
        return;
    }
    
    [self getCurrentEditorView].viewName = textfield.stringValue;

}

- (void)loadView:(FSView *)view
{
    self.tfViewName.stringValue = view.viewName;
    
    self.tvViewSql.string = [view makeSqlKeyValue] ? [view makeSqlKeyValue] : @"";
}

- (IBAction)onViewSqlSaveClicked:(id)sender
{
    if (self.tvViewSql.string.length > 0)
    {
        [self getCurrentEditorView].sqls = self.tvViewSql.string;
        
        NSString *exesql = [[self getCurrentEditorView]deleteNotesForSqls:[[self getCurrentEditorView] makeSqlKeyValue]];
        
        NSLog(@"======== %@",exesql);
    }
}

@end
