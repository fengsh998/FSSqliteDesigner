//
//  dafdafd.m
//  FSSqliteDesigner
//
//  Created by fengsh on 14/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSOutlineView.h"

@implementation FSOutlineView

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    
//    // Drawing code here.
//}

/*
- (void)mouseDown:(nonnull NSEvent *)theEvent
{
    [super mouseDown:theEvent];

    // Only take effect for double clicks; remove to allow for single clicks
    if (theEvent.clickCount < 2) {
        return;
    }
    
    // Get the row on which the user clicked
    NSPoint localPoint = [self convertPoint:theEvent.locationInWindow
                                   fromView:nil];
    NSInteger row = [self rowAtPoint:localPoint];
    
    // If the user didn't click on a row, we're done
    if (row < 0) {
        return;
    }
    
    // Get the view clicked on
    NSTableCellView *view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
    
    // If the field can be edited, pop the editor into edit mode
    //好像只有在xib中修改behavior才可以
    if (view.textField.isEditable) {
        [[view window] makeFirstResponder:view.textField];
    }
    
    //方式二 (没有方式一简洁)
//        NSPoint selfPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
//        NSInteger row = [self rowAtPoint:selfPoint];
//        if (row>=0)
//        {
//            NSTableCellView *view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
//            [self mouseDownForTextFields:theEvent inView:view];
//        }
    
}

- (void)mouseDownForTextFields:(NSEvent *)theEvent inView:(NSView *)view
{
    // If shift or command are being held, we're selecting rows, so ignore
    if ((NSCommandKeyMask | NSShiftKeyMask) & [theEvent modifierFlags]) return;
    NSPoint selfPoint = [view convertPoint:theEvent.locationInWindow fromView:nil];
    for (NSView *subview in [view subviews])
        if ([subview isKindOfClass:[NSTextField class]])
            if (NSPointInRect(selfPoint, [subview frame]))
                [[self window] makeFirstResponder:subview];
}
 */

@end
