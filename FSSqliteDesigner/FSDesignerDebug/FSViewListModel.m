//
//  FSViewListModel.m
//  FSSqliteDesigner
//
//  Created by fengsh on 8/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSViewListModel.h"

@implementation FSViewListModel


- (BOOL)hasParent
{
    return (self.v && self.v.superview);
}

- (BOOL)hasChildren
{
    return (self.v && self.v.subviews.count > 0);
}

- (NSString *)findparent:(NSView *)currentv
{
    NSMutableArray *items = [NSMutableArray array];
    
    NSView *parent = currentv;
    while (parent) {
        [items addObject:[NSString stringWithFormat:@"%@ : %p \n",parent.className,parent]];
        parent = parent.superview;
    }
    
    NSMutableString *s = [NSMutableString stringWithString:@""];
    for (NSInteger i = items.count ;i > 0 ;i--) {
        for (NSInteger j = items.count - i; j < items.count; j++) {
            [s stringByAppendingString:@"--"];
        }
        [s stringByAppendingString:[items objectAtIndex:i - 1]];
    }
    return s;
}

- (void)findchildren:(NSView *)currentv withLevel:(NSInteger)level withstring:(NSString *)outstring
{
    for (NSView *item in currentv.subviews)
    {
        for (NSInteger j = 0; j < level; j++) {
            [outstring stringByAppendingString:@"--"];
        }
        
        [outstring stringByAppendingString:[NSString stringWithFormat:@"%@ : %p \n",item.className,item]];

        if (item.subviews.count > 0) {
            [self findchildren:item withLevel:level + 1 withstring:outstring];
        }
    }
}

- (NSString *)parentTreeString
{
    if ([self hasParent]) {
        return [self findparent:self.v];
    }
    return nil;
}

- (NSString *)childrenTreeString
{
    if ([self hasChildren]) {
        NSMutableString *s = [NSMutableString stringWithString:@""];
        [self findchildren:self.v withLevel:0 withstring:s];
        return s;
    }

    return nil;
}

- (BOOL)isEqual:(FSViewListModel*)object
{
    return (self.v == object.v);
}

//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"%@ <%p> : level = %ld, subvs = %@ ",self.className,
//            self,(long)self.level,self.subvs];
//}

@end
