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

        NSBundle *bd = [NSBundle bundleForClass:self.class];
        self.designVC = [[FSDesignerViewController alloc]initWithNibName:@"FSDesignerViewController" bundle:bd];
        
        self.contentView = [[NSView alloc]initWithFrame:self.bounds];
        //self.contentView.autoresizesSubviews = YES;
        self.contentView.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        
//        self.contentView.wantsLayer = YES;
//        self.contentView.layer.borderColor = [NSColor blackColor].CGColor;
//        self.contentView.layer.borderWidth = 1.0f;
        
        self.designVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        //self.designVC.view.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;;
        [self addSubview:self.contentView];
        
        [self.contentView addSubview:self.designVC.view];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

//- (BOOL)isOpaque
//{
//    return YES;
//}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect: dirtyRect];
    [[NSColor controlHighlightColor] set];
    NSRectFill(dirtyRect);
}

@end
