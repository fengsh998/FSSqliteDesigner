//
//  FSSqliteParse.h
//  FSSqliteDemo
//
//  Created by fengsh on 16/1/7.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSSqliteApi.h"


NSString *FSDatabaseNameKey = @"DatabaseName";
NSString *FSDatabaseUpdateSqls = @"UpdateSqls";

@interface FSSqliteParse : NSObject<FSSqliteProtocol>

@end

@interface FSSqliteParseImpl : FSSqliteParse


@end
