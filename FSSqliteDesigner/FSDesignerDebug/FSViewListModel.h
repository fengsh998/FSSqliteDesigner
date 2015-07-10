//
//  FSViewListModel.h
//  FSSqliteDesigner
//
//  Created by fengsh on 8/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FSViewListModel : NSObject
@property (nonatomic,assign) NSInteger              level;
@property (nonatomic,strong) NSView                 *v;
@property (nonatomic,strong) NSMutableArray         *subvs;

- (BOOL)hasParent;

- (BOOL)hasChildren;

- (NSString *)parentTreeString;

- (NSString *)childrenTreeString;

@end
