//
//  FSTabView.m
//  FSSqliteDesigner
//
//  Created by fengsh on 26/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSTabView.h"

@implementation FSTabView

- (void)mouseDown:(nonnull NSEvent *)theEvent
{
    NSPoint localPoint = [self convertPoint:theEvent.locationInWindow
                                   fromView:nil];

    NSTabViewItem *selecteditem = [self tabViewItemAtPoint:localPoint];
    if (selecteditem)
    {
        BOOL should = YES;
        if ([self.delegate respondsToSelector:@selector(tabView:shouldSelectTabViewItem:)])
        {
            should = [self.delegate tabView:self shouldSelectTabViewItem:selecteditem];
        }
        
        if (should) {
            
            if ([self.delegate respondsToSelector:@selector(tabView:willSelectTabViewItem:)])
            {
                [self.delegate tabView:self willSelectTabViewItem:selecteditem];
            }
            
            if ([self.delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)])
            {
                [self.delegate tabView:self didSelectTabViewItem:selecteditem];
            }
            
            //只有should为Yes才响应，否则拦截
            [super mouseDown:theEvent];
        }
    }
}

@end
