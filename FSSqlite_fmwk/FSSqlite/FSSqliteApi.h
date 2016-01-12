//
//  FSSqliteApi.h
//  FSSqlite
//
//  Created by fengsh on 16/1/7.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#ifndef FSSqliteApi_h
#define FSSqliteApi_h

#import <UIKit/UIKit.h>

extern NSString *FSDatabaseNameKey;
extern NSString *FSDatabaseUpdateSqls;

typedef NS_ENUM(NSInteger,ElementType) {
    elementTypeNone                     ,
    elementTypeDB                       ,//库
    elementTypeTable                    ,//表
    elementTypeView                     ,//视图
    elementTypeIndex                    ,//索引
    elementTypeTrigger
};

typedef void(^ParseElements)(id obj,NSString *deeppath,ElementType type,BOOL *stop);

@protocol FSSqliteProtocol <NSObject>

@optional
//通过文件获取到NSData
+ (NSData *)loadFileFromSqliteModel:(NSString *)filepath;

/**
 *  比较两个sqlitemodel
 *
 *  @param modeldata
 *  @param newmodeldata
 *
 *  @return 返回以newmodel为标准，从modeldata更新到newmodeldata的sql脚本
 */
- (NSArray<NSDictionary *> *)compareSqliteModel:(NSData *)modeldata andNewSqliteModel:(NSData *)newmodeldata;

- (NSArray<NSDictionary *> *)compareSqliteModel:(NSData *)modeldata andNewSqliteModel:(NSData *)newmodeldata withDBName:(NSString *)dbname;
/**
 *  解释model
 *
 *  @param filepath
 *  @param block
 */
- (void)parseSqliteModel:(NSString *)filepath withBlock:(ParseElements)block;

- (void)parseSqliteModelOfData:(NSData *)data withBlock:(ParseElements)block;

@end

@interface FSSqliteEngine : NSObject
- (id<FSSqliteProtocol>)defalutSqliteParse;
@end

#endif /* FSSqliteApi_h */
