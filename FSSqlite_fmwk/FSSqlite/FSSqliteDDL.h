//
//  FSSqliteDDL.h
//  FSSqlite
//
//  Created by fengsh on 16/1/11.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#ifndef FSSqliteDDL_h
#define FSSqliteDDL_h

/*****************************DDL 语句****************************/
///创建表(参1表名,参2表的所有字段及类型)
#define CREATE_TABLE_FMT_SQL            (@"CREATE TABLE IF NOT EXISTS %@ (%@)")
///创建视图
#define CREATE_VIEW_FMT_SQL             (@"CREATE VIEW IF NOT EXISTS \"%@\" AS \"%@\"")
///创建索引 (第一个参数是否唯一索引)
#define CREATE_INDEX_FMT_SQL            (@"CREATE %@ INDEX IF NOT EXISTS %@ ON %@ (%@)")
///修改表
#define ALTER_TABLE_ADD_COLUMN_SQL      (@"ALTER TABLE \"%@\" ADD COLUMN \"%@\"")
///导数据(参1为目标表名,参2为目标表名中的字段名,参3为需要导的字段,参4导出表)
#define EXPORT_DATA_DEST_TABLE          (@"INSERT INTO %@(%@) SELECT %@ FROM %@")

///重健索引
#define REBUILDINDEX                    (@"REINDEX")
///重建当前主数据库中X表的所有索引。
#define REBUILDINDEX_IN_TABLENAME       (@"REINDEX %@")
///重建当前主数据库中名称为X的索引。
#define REBUILDINDEX_IN_INDEXNAME       (@"REINDEX %@")

///缓存数据清理(sqlite命令，针对当频繁有增，删，改数据操作后产生的开销进行清理)
#define CLEAN_CACHE_DATA                (@"VACUUM");

/*重命名表名
 影响到该表依赖的触发器，视图，必须重建
 对索引无影响
 */
#define RENAME_TABLENAME_SQL            (@"ALTER TABLE \"%@\" RENAME TO \"%@\"")

#define DROP_TYPE_SQL(X)                (@"DROP "#X" IF EXISTS %@")
///删除表
#define DROP_TABLE_SQL                  (DROP_TYPE_SQL(TABLE))
///删除视图
#define DROP_VIEW_SQL                   (DROP_TYPE_SQL(VIEW))
///删除触发器
#define DROP_TRIGGER_SQL                (DROP_TYPE_SQL(TRIGGER))
///删除索引
#define DROP_INDEX_SQL                  (DROP_TYPE_SQL(INDEX))

//不能直接用语句来修改sqlite_master表中的数据。只可以查
#define SELECT_ALL_TYPE_SQL(x)          (@"SELECT * FROM sqlite_master WHERE type = '"#x"'")
#define SELECT_ALL_VIEWS_SQL            (SELECT_ALL_TYPE_SQL(view))
#define SELECT_ALL_TRIGGERS_SQL         (SELECT_ALL_TYPE_SQL(trigger))
#define SELECT_ALL_TABLE_SQL            (SELECT_ALL_TYPE_SQL(table))

//重置所有表的自增序号从1开始
#define RESET_SEQUENCE(tablename)       (@"DELETE FROM sqlite_sequence WHERE name = '"#tablename"'")
//要是想重置所有表
#define RESET_SEQUENCE_ALL              (@"DELETE FROM sqlite_sequence")

//任意的x成NSString
#define MSG_STR(x) @"" #x

#endif /* FSSqliteDDL_h */
