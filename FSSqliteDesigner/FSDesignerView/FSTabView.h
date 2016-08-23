//
//  FSTabView.h
//  FSSqliteDesigner
//
//  Created by fengsh on 26/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//
/**
 *  因NSTabView鼠标点击时不触发选择代理。所以派生子类来实现
 *  //经发现，原来是delegate设错了对象。导置不触发
 */

#import <Cocoa/Cocoa.h>

@interface FSTabView : NSTabView

@end
