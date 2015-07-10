//
//  FSXcodeWindowFrameDebug.h
//  FSSqliteDesigner
//
//  Created by fengsh on 7/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSXcodeWindowFrameDebug : NSWindowController

@property (weak) NSWindow                                   *xcwindow;
@property (weak) IBOutlet NSTabView                         *tabview;
@property (weak) IBOutlet NSOutlineView                     *treeview;

@property (weak) IBOutlet NSToolbar                         *toolbar;
@property (weak) IBOutlet NSTextField                       *selectedcolor;

@property (unsafe_unretained) IBOutlet NSTextView *treeviewLog;

@property (nonatomic, strong) NSMutableArray                *datasource;

@end
