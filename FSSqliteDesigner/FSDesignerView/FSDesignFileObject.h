//
//  FSDesignFileObject.h
//  FSSqliteDesigner
//
//  Created by fengsh on 11/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//
/*  库
        表
          表名1
             字段
        视图
          视图名1
        索引
          索引名1
        触发器
          触发器名1
*/
#import <Foundation/Foundation.h>

typedef enum
{
    ftInteger,
    ftDouble,
    ftFloat,
    ftReal,
    ftBool,
    ftDate,
    ftDatetime,
    ftTimestamp,
    ftString,
    ftText,
    ftBlob,
    ftBinary
}FSFieldType;

typedef enum
{
    scNone                    = 1,
    scPrimarykey              = 1 << 1,
    scAutoIncreament          = 1 << 2,
    scNotNull                 = 1 << 3,
    scUnique                  = 1 << 4,
    scDefaultValue            = 1 << 5
}FSFieldConstraint;

typedef enum
{
    nodeNone                  = 0,
    nodeDatabase              = 1,                 //库
    nodeTabel                 = 1 << 1,            //表
    nodeIndex                 = 1 << 2,            //索引
    nodeView                  = 1 << 3,            //视图
    nodeTigger                = 1 << 4,            //触发器
    nodeColumn                = 1 << 5
} NodeType;

@interface FSNode : NSObject
{
    @private
    __weak FSNode           *_parentNode;
    NSMutableArray          *_childrens;
}

@property (nonatomic , assign) NodeType                 type;
@property (nonatomic , strong) NSString                 *nodename;
@property (nonatomic , assign) NSInteger                childcounts;
@property (nonatomic , assign , readonly) BOOL          hasChildren;
@property (nonatomic , assign , readonly) BOOL          hasParent;
@property (nonatomic , readonly) FSNode                 *parentNode;
//是否允许子结点中有重名(default NO)
@property (nonatomic , assign) BOOL                     allowRename;
@property (nonatomic , readonly) NSArray                *childrens;
///结点信息(上下文)
@property (nonatomic , strong) id                       userinfo;

- (void)addChildrenNode:(FSNode *)children;
- (void)removeChildrenNode:(FSNode *)children;
- (void)removeAllChildren;
- (void)removeChildrenNodeAtIndex:(NSInteger)index;
- (void)removeChildrenNodeOfName:(NSString *)nodename;
- (FSNode *)findNodeAtIndex:(NSInteger)index;
- (NSInteger)indexOfNode:(FSNode *)node;
//只在当前结点的一级子结点进行查找
- (NSArray *)findNodeFromChildrenOfName:(NSString *)name;
//返回一个数组元素为NSIndexpath,存放找到的项索引
- (NSArray *)findNodeIndexsFromChildrenOfName:(NSString *)name;
- (BOOL)exsistNodeName:(NSString *)name;
@end

/*************************************类目*************************************/
@interface FSTableCategory : FSNode

@end

@interface FSIndexCategory : FSNode

@end

@interface FSViewCategory : FSNode

@end

@interface FSTriggerCategory : FSNode

@end

/************************************具体类************************************/

///触发器
@interface FSTrigger : FSNode
@property (nonatomic, setter=setNodename:,getter=nodename) NSString          *triggerName;
///触发器语句
@property (nonatomic, strong) NSString                                       *sqls;

- (instancetype)initWithTriggerName:(NSString *)triggerName;
@end

///视图
@interface FSView : FSNode
@property (nonatomic, setter=setNodename:,getter=nodename) NSString         *viewName;
///视图语句
@property (nonatomic, strong) NSString                                      *sqls;

- (instancetype)initWithViewName:(NSString *)viewname;
@end

///索引
@interface FSIndex : FSNode
- (instancetype)initWithIndexName:(NSString *)indexname;
@end

///字段
@interface FSColumn : FSNode
///约束默认值
@property (nonatomic, strong) NSString                              *defaultvalue;
@property (nonatomic, assign) FSFieldConstraint                     constraint;
///类型长度
@property (nonatomic, assign) NSInteger                             typeLength;
@property (nonatomic, assign) FSFieldType                           fieldtype;
///字段备注
@property (nonatomic, strong) NSString                              *mark;
@property (nonatomic, setter=setNodename:,getter=nodename) NSString *fieldName;

+ (FSColumn *)column:(NSString *)filedName;
+ (FSColumn *)column:(NSString *)filedName ofType:(FSFieldType)fieldtype withTypeLength:(NSInteger)length;

- (instancetype)initWithName:(NSString *)filedName;
@end

///表
@interface FSTable : FSNode
@property (nonatomic, setter=setNodename:,getter=nodename) NSString *tableName;
///记录表的语句
@property (nonatomic, strong) NSString                          *createsqls;
- (instancetype)initWithTableName:(NSString *)name;
/**
 *  添加一个字段
 *
 *  @param filedName 字段名
 *  @param fieldtype 字段类型
 *  @param length    字段长度
 */
- (FSColumn *)addColumn:(NSString *)filedName;
- (NSArray *)allColumns;
- (FSColumn *)findColumn:(NSString *)filedName;
- (FSColumn *)columnAtIndex:(NSInteger)index;
- (void)removeColumn:(FSColumn *)column;
- (void)removeColumnOfIndex:(NSInteger)index;
- (void)removeAllColumn;
@end



///库
@interface FSDatabse : FSNode
{
    @private
    FSTableCategory                 *tableKind;
    FSIndexCategory                 *indexKind;
    FSViewCategory                  *viewKind;
    FSTriggerCategory               *triggerKind;
}
///延迟动态加载标识
@property (nonatomic , assign) BOOL                         dynamic;
@property (nonatomic , strong) NSString                     *minVersion;
@property (nonatomic , strong) NSString                     *maxVersion;
@property (nonatomic , strong) NSString                     *version;
@property (nonatomic, setter=setNodename:,getter=nodename) NSString *dbName;

- (instancetype)initWithDatabaseName:(NSString *)dbname;
///添加表
- (FSTable *)addTable:(NSString *)tablName;
///添加索引
- (FSIndex *)addIndex:(NSString *)indexName;
///添加视图
- (FSView *)addView:(NSString *)viewName;
///添加触发器
- (FSTrigger *)addTrigger:(NSString *)triggerName;

/**
 *  移除一个表
 *
 *  @param tablName 表名
 */
- (void)removeTableOfName:(NSString *)tablName;
/**
 *  移除所有表
 */
- (void)removeAllTable;
/**
 *  移除一个表
 *
 *  @param table 表对象
 */
- (void)removeTable:(FSTable *)table;
/**
 *  移除一个表
 *
 *  @param index 索引
 */
- (void)removeTableAtIndex:(NSInteger)index;
/**
 *  获取表的索引
 *
 *  @param tablName 表名
 *
 *  @return NSNotFound没有找到
 */
- (NSInteger)indexOfTableName:(NSString *)tableName;
/**
 *  获取表索引
 */
- (NSInteger)indexOfTable:(FSTable *)table;
/**
 *  当前所有表
 */
- (NSArray *)tables;
/**
 *  获取表
 */
- (FSTable *)tableOfName:(NSString *)tableName;
/**
 *  获取表
 */
- (FSTable *)tableAtIndex:(NSInteger)index;

// ******************************  索引  *******************************//
- (void)removeIndexOfName:(NSString *)indexName;
- (void)removeAllIndex;
- (void)removeIndex:(FSIndex *)indexObject;
- (void)removeIndexAtIndex:(NSInteger)index;
- (NSInteger)indexOfIndexName:(NSString *)indexName;
- (NSInteger)indexOfIndex:(FSIndex *)indexObject;
- (NSArray *)indexObjects;
- (FSIndex *)indexObjectOfName:(NSString *)indexName;
- (FSIndex *)indexOjbectAtIndex:(NSInteger)index;

// ******************************  视图  *******************************//

- (void)removeViewOfName:(NSString *)viewName;
- (void)removeAllView;
- (void)removeView:(FSView *)view;
- (void)removeViewAtIndex:(NSInteger)index;
- (NSInteger)indexOfViewName:(NSString *)viewName;
- (NSInteger)indexOfView:(FSView *)view;
- (NSArray *)views;
- (FSView *)viewOfName:(NSString *)viewName;
- (FSView *)viewAtIndex:(NSInteger)index;

// ******************************  触发器  *******************************//

- (void)removeTriggerOfName:(NSString *)triggerName;
- (void)removeAllTrigger;
- (void)removeTrigger:(FSTrigger *)trigger;
- (void)removeTriggerAtIndex:(NSInteger)index;
- (NSInteger)indexOfTriggerName:(NSString *)triggerName;
- (NSInteger)indexOfTriggers:(FSTrigger *)trigger;
- (NSArray *)triggers;
- (FSTrigger *)triggerOfName:(NSString *)triggerName;
- (FSTrigger *)triggerAtIndex:(NSInteger)index;

@end

@interface FSDesignFileObject : NSObject

@property (nonatomic,readonly) NSArray          *databases;

- (void)addDatabase:(FSDatabse *)database;
- (FSDatabse *)addDatabaseWithName:(NSString *)name;
- (FSDatabse *)databaseOfIndex:(NSInteger)index;
- (NSInteger)indexOfDatabaseObject:(FSDatabse *)database;

- (void)removeDatabaseAtIndex:(NSInteger)index;
- (void)removeDatabaseOfObject:(FSDatabse *)database;
- (void)removeAllDatabase;

- (void)loadFromFile:(NSURL *)filepath;
- (void)saveToFile:(NSURL *)filepath;

@end
