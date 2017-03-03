//
//  ViewController.h
//  FSSqliteDesignerTools
//
//  Created by fengsh on 16/9/23.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FKDragDropView.h"

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *lbpath;
@property (weak) IBOutlet FKDragDropView *container;


@end

