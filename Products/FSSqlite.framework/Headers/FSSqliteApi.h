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

@protocol FSSqliteProtocol <NSObject>

/**
 *  通过.sqlitemodeld中的plist的currentModelName 来加载数据库结构
 *
 *  @param .sqlitemodeld 文件夹
 *
 *  @return 目前最新版本的数据结构
 */
- (NSData *)loadFileMainVersionDBFromSqlitemodeld:(NSString *)filepath;

/**
 *          生成数据结构脚本
 *
 */
- (NSDictionary *)makeDBSqlForDescriptionModel:(NSData *)modeldata;

@optional
/**
 *
 *  通过.sqlitemodel文件获取到NSData
 *
 *  @return 数据结构
 */
- (NSData *)loadFileFromSqliteModel:(NSString *)filepath;

/**
 *  比较两个sqlitemodel
 *
 *  @param modeldata
 *  @param newmodeldata
 *
 *  @return 返回以newmodel为标准，从modeldata更新到newmodeldata的sql脚本
 */
- (NSArray<NSDictionary *> *)compareSqliteModel:(NSData *)modeldata andNewSqliteModel:(NSData *)newmodeldata;

- (NSArray<NSString *> *)compareSqliteModel:(NSData *)modeldata andNewSqliteModel:(NSData *)newmodeldata withDBName:(NSString *)dbname;


@end


@interface FSSqliteEngine : NSObject

- (id<FSSqliteProtocol>)defalutSqliteParse;

@end

#endif /* FSSqliteApi_h */
