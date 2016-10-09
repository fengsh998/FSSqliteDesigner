//
//  FSExplorer.h
//  FSSqliteDesignerTools
//
//  Created by fengsh on 16/9/23.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSExplorer : NSWindowController
@property (nonatomic, copy)     NSURL               *pathURL;
@property (weak) IBOutlet       NSTextField         *tfSaveName;
@property (nonatomic, assign)   BOOL                isCreate;
@property (weak) IBOutlet       NSTextField         *lbName;
@end
