//
//  FSIndexTableViewImpl.h
//  FSSqliteDesigner
//
//  Created by fengsh on 29/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface FSIndexTableViewImpl : NSObject<NSTableViewDataSource,NSTableViewDelegate>

@property (nonatomic,strong) NSDictionary                  *dataSource;


@end
