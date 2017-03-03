//
//  FKDragDropView.h
//
//  Created by fengsh on 16-2-25.
//  Copyright (c) 2016年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FKDragDropView;

@protocol DragDropViewDelegate <NSObject>
-(void)dragDropView:(FKDragDropView *)dropview FileList:(NSArray*)fileList;
@end

@interface FKDragDropView : NSView
@property (nonatomic,weak)  id<DragDropViewDelegate> delegate;

@end

