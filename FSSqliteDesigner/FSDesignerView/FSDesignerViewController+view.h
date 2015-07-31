//
//  FSDesignerViewController+view.h
//  FSSqliteDesigner
//
//  Created by fengsh on 30/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//
//               视图管理页

#import <Foundation/Foundation.h>
#import "FSDesignerViewController.h"

@interface FSDesignerViewController(view)

- (void)onViewNameChange:(NSTextField *)textfield;

- (void)loadView:(FSView *)view;
@end
