//
//  FSDesignerViewController+index.h
//  FSSqliteDesigner
//
//  Created by fengsh on 29/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDesignerViewController.h"


@interface FSDesignerViewController(index)

- (void)onIndexNameChange:(NSTextField *)textfield;

- (void)loadIndex:(FSIndex *)index withIndexTargetTables:(NSArray *)tables;
@end
