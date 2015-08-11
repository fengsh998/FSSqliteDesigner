//
//  FSTextField.m
//  FSSqliteDesigner
//
//  Created by fengsh on 11/8/15.
//  Copyright (c) 2015年 fengsh. All rights reserved.
//

#import "FSTextField.h"

@implementation FSTextField

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (BOOL) becomeFirstResponder
{
    if (self.drawBackgroundWhenFocus)
    {
        self.drawsBackground = YES;
    }
    return YES;
}

- (BOOL) resignFirstResponder
{
    if (self.drawBackgroundWhenFocus)
    {
        self.drawsBackground = NO;
    }
    return YES;
}

@end
