//
//  FSDesignerView.m
//  FSSqliteDesigner
//
//  Created by fengsh on 7/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSDesignerView.h"

@implementation FSDesignerView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.autoresizesSubviews = YES;
        self.contentView = [[NSView alloc]initWithFrame:self.bounds];
        self.contentView.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        
        self.contentView.wantsLayer = YES;
        self.contentView.layer.borderColor = kCGColorBlack;
        self.contentView.layer.borderWidth = 1.0f;
        
        [self addSubview:self.contentView];
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect: dirtyRect];
    [[NSColor controlHighlightColor] set];
    NSRectFill(dirtyRect);
}

@end
