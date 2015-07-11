//
//  FSDesignerView.h
//  FSSqliteDesigner
//
//  Created by fengsh on 7/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//   设置到最低部
// [navAndEditor addSubview:self.sqliteDesignView positioned:NSWindowBelow relativeTo:nil];

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FSDesignerView : NSVisualEffectView
@property (nonatomic, strong) NSView                            *contentView;
@end
