//
//  FSDesignerViewController+Trigger.h
//  FSSqliteDesigner
//
//  Created by fengsh on 31/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDesignerViewController.h"

@interface FSDesignerViewController(Trigger)<FSTriggerPageDelegate>

- (void)loadTriggerView:(FSTrigger *)trigger withTables:(NSArray *)tables;

- (void)popTriggerTableClicked:(NSMenuItem *)item;

- (void)onTriggerNameChange:(NSTextField *)textfield;

- (void)saveTriggerSettings;
@end
