//
//  FSTriggerTableViewImpl.h
//  FSSqliteDesigner
//
//  Created by fengsh on 31/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class FSTriggerTableViewImpl;

@protocol FSTriggerPageDelegate <NSObject>

@optional
- (void)FSTrigger:(FSTriggerTableViewImpl *)impl SelectColumns:(id)column;

@end

@interface FSTriggerTableViewImpl : NSObject<NSTableViewDataSource,NSTableViewDelegate>
@property (nonatomic,strong) NSDictionary                  *dataSource;
@property (nonatomic,weak) id<FSTriggerPageDelegate>       delegate;
@end
