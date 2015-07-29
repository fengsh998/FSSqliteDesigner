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
    ftInteger     = 0,
    ftDouble,
    ftFloat,
    ftReal,
    ftBool,
    ftDate,
    ftDatetime,
    ftTimestamp,
    ftString,
    ftText,
    ftVarchar,
    ftBlob,
    ftBinary,
    ftUnknow
}FSFieldType;

typedef enum
{
    fcNone                    = 1,
    fcPrimarykey              = 1 << 1,
    fcAutoIncreament          = 1 << 2,
    fcNotNull                 = 1 << 3,
    fcUnique                  = 1 << 4,
    fcDefaultValue            = 1 << 5
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

@protocol FSNodeExtendProtocol <NSObject>

@optional
///生成唯一结点名
- (NSString *)uniqueName:(NSString *)name;

@end

@interface FSNode : NSObject<FSNodeExtendProtocol>
{
    @private
    __weak FSNode           *_parentNode;
    NSMutableArray          *_childrens;
    NSString                *_nodename;
}

@property (nonatomic , assign) NodeType                 type;
@property (nonatomic , strong) NSString                 *nodename;
@property (nonatomic , assign) NSInteger                childcounts;
@property (nonatomic , assign , readonly) BOOL          hasChildren;
@property (nonatomic , assign , readonly) BOOL          hasParent;
@property (nonatomic , readonly) FSNode                 *parentNode;
///是否允许子结点中有重名(default NO)
@property (nonatomic , assign) BOOL                     allowRename;
@property (nonatomic , readonly) NSArray                *childrens;
///结点信息(上下文)
@property (nonatomic , strong) id                       userinfo;

///添加结点
- (void)addChildrenNode:(FSNode *)children;
///插入结点 注:当没有孩子时index不能为0
- (void)insertChildrenNode:(FSNode *)children atIndex:(NSInteger)index;
///替换结点
- (void)replaceChildrenNode:(FSNode *)children atIndex:(NSInteger)index;
///孩子结点交换
- (BOOL)transferChildrenA:(FSNode *)childrenA toChildrenB:(FSNode *)childrenB;
- (BOOL)transferChildrenAAtIndex:(NSInteger)indexA toChildrenBAtIndex:(NSInteger)indexB;
///移除结点
- (void)removeChildrenNode:(FSNode *)children;
- (void)removeAllChildren;
- (void)removeChildrenNodeAtIndex:(NSInteger)index;
- (void)removeChildrenNodeOfName:(NSString *)nodename;
///查找结点
- (FSNode *)findNodeAtIndex:(NSInteger)index;
- (NSInteger)indexOfNode:(FSNode *)node;
///只在当前结点的一级子结点进行查找
- (NSArray *)findNodeFromChildrenOfName:(NSString *)name;
///返回一个数组元素为NSIndexpath,存放找到的项索引
- (NSArray *)findNodeIndexsFromChildrenOfName:(NSString *)name;
///所有孩子中是否存在name
- (BOOL)exsistNodeName:(NSString *)name;
///自身的兄弟结点中是否存在了name
- (BOOL)exsistNodeNameInNeighbour:(NSString *)name;
///有兄弟
- (BOOL)hasNeighbour;
///上一兄弟 如果为nil说明自己是老大
- (FSNode *)perviousNeighbour;
///下一兄弟 如果为nil说明自己是最小
- (FSNode *)nextNeighbour;
///徐自己外所有兄弟(元素为FSNode)
- (NSArray *)allNeighbours;

- (void)setNodename:(NSString *)name;
- (NSString *)nodename;

@end

/*************************************类目*************************************/
@interface FSTableCategory : FSNode
- (NSString *)makeUniqueTableName;
@end

@interface FSIndexCategory : FSNode
- (NSString *)makeUniqueIndexName;
@end

@interface FSViewCategory : FSNode
- (NSString *)makeUniqueViewName;
@end

@interface FSTriggerCategory : FSNode
- (NSString *)makeUniqueTriggerName;
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
///是否唯一索引
@property (nonatomic,assign) BOOL                                           unique;
@property (nonatomic, setter=setNodename:,getter=nodename) NSString         *indexName;
///建立的索引表名
@property (nonatomic,copy)   NSString                                       *indexTableName;
///索引字段名
@property (nonatomic,copy)   NSArray                                        *indexFieldNames;
///指定一的升序字段(可选)
@property (nonatomic,strong) NSArray                                        *ascFields;
///指定一的降序字段(可选)
@property (nonatomic,strong) NSArray                                        *descFields;
///索引sqls
@property (nonatomic,strong) NSString                                       *indexsqls;

- (instancetype)initWithIndexName:(NSString *)indexname;

- (NSString *)makeSqlKeyValue;
@end

///外键
@interface FSForeignKey : NSObject
///目标表
@property (nonatomic, strong)   NSString                            *targetTable;
///目标列
@property (nonatomic, strong)   NSString                            *targetColumn;
///选中选项(default = -1)
@property (nonatomic, assign)   NSInteger                           selectIndexOfOptions;
///选中删除action(default = -1)
@property (nonatomic, assign)   NSInteger                           selectIndexOfDeleteAction;
///选中更新action(default = -1)
@property (nonatomic, assign)   NSInteger                           selectIndexOfUpdateAction;
///支持的选项
+ (NSArray *)supportOptions;
///支持的删除触发事件
+ (NSArray *)supportActionForDelete;
///支持的更新触发事件
+ (NSArray *)supportActionForUpdate;

- (NSString *)makeSqlKeyValue;
@end

///字段
@interface FSColumn : FSNode
{
    @private
    FSForeignKey        *_foreignKey;
}
///约束默认值
@property (nonatomic, copy) NSString                                *defaultvalue;
///约束P,A,U,N
@property (nonatomic, assign) FSFieldConstraint                     constraint;
///类型长度
@property (nonatomic, assign) NSInteger                             typeLength;
///字段类型
@property (nonatomic, assign) FSFieldType                           fieldtype;
///字段备注
@property (nonatomic, copy) NSString                                *mark;
///提供当前支持的字段类型
@property (nonatomic, readonly) NSArray                             *supportFieldTypes;
///有外键(默认default)
@property (nonatomic, assign) BOOL                                  enableForeignkey;
///外键数据
@property (nonatomic, readonly) FSForeignKey                        *foreignKey;

@property (nonatomic, setter=setNodename:,getter=nodename) NSString *fieldName;

+ (FSColumn *)column:(NSString *)filedName;
+ (FSColumn *)column:(NSString *)filedName ofType:(FSFieldType)fieldtype withTypeLength:(NSInteger)length;
+ (NSString *)covertFieldConstraint:(FSFieldConstraint)constraint;

- (instancetype)initWithName:(NSString *)filedName;

- (NSString *)covertToString:(FSFieldType)fieldtype;
- (FSFieldType)covertToType:(NSString *)fieldstring;

- (NSString *)makeSqlKeyValue;

@end

///表
@interface FSTable : FSNode
@property (nonatomic, setter=setNodename:,getter=nodename) NSString *tableName;
///记录表的语句
@property (nonatomic, strong) NSString                          *createsqls;

- (instancetype)initWithTableName:(NSString *)name;
- (NSString *)makeUniqueColumnName;
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

- (NSString *)makeSqlKeyValue;
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

// /几个快捷方式，获取事先定义好的唯一名称
- (NSString *)makeUniqueTableName;
- (NSString *)makeUniqueIndexName;
- (NSString *)makeUniqueViewName;
- (NSString *)makeUniqueTriggerName;

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

- (NSString *)makeUniqueDatabaseName;
- (void)addDatabase:(FSDatabse *)database;
- (void)insertDatabase:(FSDatabse *)database atIndex:(NSInteger)index;
- (FSDatabse *)insertDatabaseWithName:(NSString *)name atIndex:(NSInteger)index;
- (FSDatabse *)addDatabaseWithName:(NSString *)name;
- (FSDatabse *)databaseOfIndex:(NSInteger)index;
- (NSInteger)indexOfDatabaseObject:(FSDatabse *)database;

- (BOOL)exsistDatabaseOfName:(NSString *)name;
- (BOOL)exsistDatabaseOfName:(NSString *)name butNotInclude:(FSDatabse *)db;

- (void)removeDatabaseAtIndex:(NSInteger)index;
- (void)removeDatabaseOfObject:(FSDatabse *)database;
- (void)removeAllDatabase;

- (void)loadFromFile:(NSURL *)filepath;
- (void)saveToFile:(NSURL *)filepath;

///导出为sqlite语句脚本

@end
