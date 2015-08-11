//
//  FSTextField.h
//  FSSqliteDesigner
//
//  Created by fengsh on 11/8/15.
//  Copyright (c) 2015年 fengsh. All rights reserved.
//
//  处理获取焦点时响进行某些特殊设置

#import <Cocoa/Cocoa.h>

@interface FSTextField : NSTextField
/**
  YES:当获取焦点时drawBackGround属性为YES,失去焦点时drawBackGround属性为NO
  NO:不启用
 */
@property (nonatomic,assign) BOOL               drawBackgroundWhenFocus;
@end
