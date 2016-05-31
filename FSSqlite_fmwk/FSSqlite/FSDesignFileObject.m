//
//  FSDesignModel.m
//  FSSqliteDesigner
//
//  Created by fengsh on 11/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
/*
StaticDBList   中的库表示可以静态创建的,即一开创建就知道存放库的位置。
DynamicDBList  中的库表示延迟创建,即这里库可能是依懒某些条件才进行创建的库,比如登录后根据用户ID来产生存放路径的库

FieldType 键中的值只允许如下值(请严格遵守)
TEXT,REAL,INTEGER,BLOB,VARCHAR,FLOAT,DOUBLE,DATE,TIME,BOOLEAN,TIMESTAMP,BINARY

FieldConstraint 键中的值只允许如下值(请严格遵守),多个时以逗号隔开(注:如果是自增则必定为主键),如不需要约束则可以删除此键
PRIMARY KEY,AUTOINCREMENT ,NOT NULL,UNIQUE,DEFAULT 1

FieldIndexType 键中的值只允许如下值(请严格遵守)
UNIQUE 或去除此键值的定义，去除后将默认创建普通索引，而不是唯一索引

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>StaticDBList</key>
<array>
<dict>
<key>DBTriggers</key>
<array>
<string>触发器语句</string>
</array>
<key>DBViews</key>
<array>
<string>视图语句</string>
</array>
<key>DBIndexs</key>
<array>
<dict>
<key>ColumnDESC</key>
<string>可指定多个降序字段以逗号隔开(a,b)-可选字段</string>
<key>ColumnASC</key>
<string>可指定多个升序字段以逗号隔开(c,d,e)-可选字段</string>
<key>DBTableName</key>
<string>对指定的表 必填</string>
<key>FieldName</key>
<string>指定的字段进行创建索引与表中的字段名对应(多个字段以逗号隔开) 必填</string>
<key>FieldIndexType</key>
<string>唯一 -可选字段</string>
<key>FieldIndexName</key>
<string>索引名 必填</string>
</dict>
</array>
<key>DBTables</key>
<array>
<dict>
<key>DBFields</key>
<array>
<dict>
<key>FieldConstraint</key>
<string>(唯一，允许为空，主键，自增，默认，外键)</string>
<key>FieldType</key>
<string>字段类型</string>
<key>FieldName</key>
<string>字段名</string>
</dict>
<dict>
<key>FieldConstraint</key>
<string>(唯一，允许为空，主键，自增，默认，外键)</string>
<key>FieldType</key>
<string>字段类型</string>
<key>FieldName</key>
<string>字段名</string>
</dict>
</array>
<key>DBTableName</key>
<string>表名</string>
</dict>
</array>
<key>DBVersion</key>
<string>1.0</string>
<key>DBName</key>
<string>库名称</string>
</dict>
</array>
<key>DynamicDBList</key>
<array>
<dict>
<key>DBTables</key>
<array>
<dict>
<key>DBFields</key>
<array>
<dict>
<key>FieldConstraint</key>
<string>(唯一，允许为空，主键，自增，默认，外键)</string>
<key>FieldType</key>
<string>字段类型</string>
<key>FieldName</key>
<string>字段名</string>
</dict>
<dict>
<key>FieldConstraint</key>
<string>(唯一，允许为空，主键，自增，默认，外键)</string>
<key>FieldType</key>
<string>字段类型</string>
<key>FieldName</key>
<string>字段名</string>
</dict>
</array>
<key>DBTableName</key>
<string>表名</string>
</dict>
</array>
<key>DBVersion</key>
<string>1.0</string>
<key>DBName</key>
<string>库名称</string>
</dict>
</array>
</dict>
</plist>
*/

#import "FSDesignFileObject.h"
#import "FSUtils.h"
#import "FSSqliteDDL.h"

@interface FSDesignFileObject ()
{
    NSMutableArray          *_fsDatabases;
}
@end

#pragma mark - FSDesignFileObject
@implementation FSDesignFileObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fsDatabases = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_fsDatabases forKey:@"_fsDatabases"];
    
    NSData *dbsdata = [NSKeyedArchiver archivedDataWithRootObject:_fsDatabases];
    NSString *sdata = [dbsdata base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    if (sdata.length > 0) {
        sdata = [FSUtils md5:sdata];
        NSUInteger hs = [sdata hash];
        _modelVersion = [FSUtils ToHex:hs];
    }
    
    [aCoder encodeObject:_modelname forKey:@"_modelname"];
    [aCoder encodeObject:_modelVersion forKey:@"_modelversion"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _fsDatabases = [aDecoder decodeObjectForKey:@"_fsDatabases"];
        _modelname   = [aDecoder decodeObjectForKey:@"_modelname"];
        _modelVersion = [aDecoder decodeObjectForKey:@"_modelversion"];
    }
    return self;
}

- (NSArray *)databases
{
    return _fsDatabases;
}

- (NSString *)uniqueName:(NSString *)name
{
    if ([self exsistDatabaseOfName:name])
    {
        //fieldname length = 9
        NSString *nums = [name substringFromIndex:9];
        if (nums.length > 0) {
            NSInteger i = [nums integerValue];
            return [self uniqueName:[NSString stringWithFormat:@"Database%ld",(long)i+1]];
        }
        else
        {   //重置到从1开始
            return [self uniqueName:@"Database1"];
        }
    }
    
    return name;
}

- (NSString *)makeUniqueDatabaseName
{
    return [self uniqueName:@"Database"];
}

- (void)addDatabase:(FSDatabse *)database
{
    [_fsDatabases addObject:database];
}

- (void)insertDatabase:(FSDatabse *)database atIndex:(NSInteger)index
{
    [_fsDatabases insertObject:database atIndex:index];
}

- (FSDatabse *)insertDatabaseWithName:(NSString *)name atIndex:(NSInteger)index
{
    FSDatabse * db = [[FSDatabse alloc]initWithDatabaseName:name];
    [self insertDatabase:db atIndex:index];
    return db;
}

- (FSDatabse *)addDatabaseWithName:(NSString *)name
{
    FSDatabse * db = [[FSDatabse alloc]initWithDatabaseName:name];
    [self addDatabase:db];
    return db;
}

- (FSDatabse *)databaseOfIndex:(NSInteger)index
{
    return [_fsDatabases objectAtIndex:index];
}

- (FSDatabse *)databaseOfName:(NSString *)name
{
    FSDatabse *ret = nil;
    for (FSDatabse *db in _fsDatabases) {
        if ([db.dbName isEqualToString:name]) {
            ret = db;
            break;
        }
    }
    return ret;
}

- (NSInteger)indexOfDatabaseObject:(FSDatabse *)database
{
    return [_fsDatabases indexOfObject:database];
}

- (BOOL)exsistDatabaseOfName:(NSString *)name
{
    for (FSDatabse *db in _fsDatabases) {
        if ([db.dbName isEqualToString:name]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)exsistDatabaseOfName:(NSString *)name butNotInclude:(FSDatabse *)db
{
    for (FSDatabse *dbitem in _fsDatabases) {
        if ([dbitem.dbName isEqualToString:name] && (db != dbitem))
        {
            return YES;
        }
    }
    return NO;
}

- (void)removeDatabaseAtIndex:(NSInteger)index
{
    [_fsDatabases removeObjectAtIndex:index];
}

- (void)removeDatabaseOfObject:(FSDatabse *)database
{
    [_fsDatabases removeObject:database];
}

- (void)removeAllDatabase
{
    [_fsDatabases removeAllObjects];
}

- (NSArray *)sortDatabase
{
    return [self.databases sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *a = ((FSDatabse *)obj1).dbName;
        NSString *b = ((FSDatabse *)obj2).dbName;
        return [a compare:b];
    }];
}

- (NSArray *)allDatabaseOfName
{
    NSMutableArray *arrs = self.databases.count > 0 ? [NSMutableArray array] : nil;
    for (FSDatabse *db in self.databases) {
        [arrs addObject:db.dbName];
    }
    
    return arrs;
}

+ (FSDesignFileObject *)parseData:(NSData *)designdata error:(NSError **)error
{
    FSDesignFileObject *designer = nil;
    if (designdata) {
        @try {
            designer = [NSKeyedUnarchiver unarchiveObjectWithData:designdata];
        }
        @catch (NSException *exception) {
            *error = [NSError errorWithDomain:@"com.fsh.sqlitemodel.error" code:10001 userInfo:exception.userInfo];
        }
    }
    else
    {
        designer = [[FSDesignFileObject alloc]init];
    }
    
    return designer;
}

+ (FSDesignFileObject *)loadFromFile:(NSURL *)filepath error:(NSError **)error
{
    //解释sqlitemodel文件
    NSData *dt = [NSData dataWithContentsOfURL:filepath];
    FSDesignFileObject *ret = [self loadFromFileData:dt error:error];
    ret.modelname = [filepath lastPathComponent];
    return ret;
}

+ (FSDesignFileObject *)loadFromFileData:(NSData *)fileData error:(NSError **)error
{
    NSDictionary *design = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
    
    NSData *designdata = design[@"DesignerData"];
    
    return [self parseData:designdata error:error];
}

- (NSDictionary *)saveForDictionary
{
    /*
     <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
     <model name="Test1.sqlitemodel" userDefinedModelVersionIdentifier="" type="com.apple.fshSqlite.DataModel" documentVersion="1.0" lastSavedToolsVersion="1" systemVersion="11A491" minimumToolsVersion="Automatic" macOSVersion="Automatic" iOSVersion="Automatic">
     <elements/>
     </model>
     */

    //保存为sqlitemodel文件
    NSMutableDictionary *dic = [self getNeedSaveContents];
    
    NSString *mdname = self.modelname;
    NSString *version = self.modelVersion;
    NSDictionary *versionInfo = @{@"modelname":mdname,@"modelversion":version};
    
    [dic setObject:versionInfo forKey:@"SQLiteModelVersion"];
    
    return dic;
}

- (void)saveToFile:(NSURL *)filepath
{
    NSDictionary *dic = [self saveForDictionary];
    
    [NSKeyedArchiver archiveRootObject:dic toFile:[filepath path]];
}

- (NSData *)saveToData
{
    NSDictionary *dic = [self saveForDictionary];

    return [NSKeyedArchiver archivedDataWithRootObject:dic];
}

- (NSMutableDictionary *)getNeedSaveContents
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self parseObject:self outToNSArray:dic];
    return dic;
}

- (void)parseObject:(FSDesignFileObject *)designobject outToNSArray:(NSMutableDictionary *)dic
{
    NSMutableArray *staticdb = [NSMutableArray array];
    NSMutableArray *dynamicdb = [NSMutableArray array];
    [dic setObject:staticdb forKey:@"StaticDBList"];
    [dic setObject:dynamicdb forKey:@"DynamicDBList"];
    
    for (FSDatabse *db in designobject.databases)
    {
        if (db.dynamic) {
            [self parseNode:db toNSArray:dynamicdb];
            
            for (NSMutableDictionary *dbdic in dynamicdb) {
                if ([dbdic[@"DBName"]isEqualToString:db.dbName]) {
                    
                    NSUInteger v = [FSUtils stringArrayOrDictionaryConvert2hashvalue:dbdic deleteSpaceAndNewline:YES];
                    if (v != NSNotFound) {
                        
                        NSString *version = [FSUtils ToHex:v];
                        //NSLog(@"version == %@",version);
                        [dbdic setObject:version forKey:@"DBVersion"];
                    }
                }
            }
        }
        else
        {
            [self parseNode:db toNSArray:staticdb];
            
            for (NSMutableDictionary *dbdic in staticdb) {
                if ([dbdic[@"DBName"]isEqualToString:db.dbName]) {
                    
                    NSUInteger v = [FSUtils stringArrayOrDictionaryConvert2hashvalue:dbdic deleteSpaceAndNewline:YES];
                    if (v != NSNotFound) {
                        
                        NSString *version = [FSUtils ToHex:v];
                        //NSLog(@"version == %@",version);
                        [dbdic setObject:version forKey:@"DBVersion"];
                    }
                }
            }
        }
    }
    
    NSData *designerdata = [NSKeyedArchiver archivedDataWithRootObject:designobject];
    
    if (designerdata) {
        [dic setObject:designerdata forKey:@"DesignerData"];
    }
}

- (void)parseNode:(FSNode *)node toNSArray:(NSMutableArray *)array
{
    switch (node.type) {
        case nodeDatabase:
        {
            NSMutableDictionary *db = [NSMutableDictionary dictionary];
            [db setObject:node.nodename forKey:@"DBName"];
            //[db setObject:@"1.0" forKey:@"DBVersion"];
            [array addObject:db];
            
            NSMutableArray *tmp = [NSMutableArray array];
            //DBFields
            [db setObject:tmp forKey:@"DBTables"];
            for (FSTable *tb in ((FSDatabse *)node).tables)
            {
                [self parseNode:tb toNSArray:tmp];
            }
            
            tmp = [NSMutableArray array];
            [db setObject:tmp forKey:@"DBIndexs"];
            
            for (FSIndex *idxobj in ((FSDatabse *)node).indexObjects) {
                [self parseNode:idxobj toNSArray:tmp];
            }
            
            tmp = [NSMutableArray array];
            [db setObject:tmp forKey:@"DBViews"];
            
            for (FSView *v in ((FSDatabse *)node).views) {
                [self parseNode:v toNSArray:tmp];
            }
            
            tmp = [NSMutableArray array];
            [db setObject:tmp forKey:@"DBTriggers"];
            
            for (FSTrigger *trigger in ((FSDatabse *)node).triggers) {
                [self parseNode:trigger toNSArray:tmp];
            }
        }
            break;
        case nodeTabel:
        {
             NSMutableDictionary *tbs = [NSMutableDictionary dictionary];
            
            [tbs setObject:node.nodename forKey:@"DBTableName"];
            NSMutableArray *fields = [NSMutableArray array];
            [tbs setObject:fields forKey:@"DBFields"];
            [array addObject:tbs];
            
            for (FSColumn *column in node.childrens) {
                [self parseNode:column toNSArray:fields];
            }
        }
            break;
        case nodeColumn:
        {
            FSColumn *c = (FSColumn *)node;
            
            NSMutableDictionary *columns = [NSMutableDictionary dictionary];
            
            [columns setObject:c.fieldName forKey:@"FieldName"];
            NSString *ft = [c covertToString:c.fieldtype];
            [columns setObject:ft forKey:@"FieldType"];
            NSMutableArray *cs = (NSMutableArray*)[FSColumn convertFieldConstraitToArray:c.constraint];
            NSString *constraint = nil;
            
            if (c.defaultvalue.length > 0) {
                [cs addObject:[NSString stringWithFormat:@"DEFAULT %@",c.defaultvalue]];
            }
            
            constraint = [cs componentsJoinedByString:@","];
            if (constraint) {
                [columns setObject:constraint forKey:@"FieldConstraint"];
            }
            
            [array addObject:columns];
        }
            break;
        case nodeIndex:
        {
            FSIndex *i = (FSIndex*)node;
            NSMutableDictionary *indexs = [NSMutableDictionary dictionary];
            [indexs setObject:i.indexName forKey:@"FieldIndexName"];
            if (i.unique) {
                [indexs setObject:@"UNIQUE" forKey:@"FieldIndexType"];
            }
            [indexs setObject:i.indexTableName?i.indexTableName:@"" forKey:@"DBTableName"];
            
            NSString *fields = @"";
            if (i.indexFieldNames) {
                fields = [i.indexFieldNames componentsJoinedByString:@","];
                fields = [fields stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
            
            [indexs setObject:fields forKey:@"FieldName"];
            
            //后面两个是可选项
            if (i.ascFields.count > 0) {
                [indexs setObject:[[i.ascFields componentsJoinedByString:@","] uppercaseString] forKey:@"ColumnASC"];
            }
            
            if (i.descFields.count > 0) {
                [indexs setObject:[[i.descFields componentsJoinedByString:@","] uppercaseString] forKey:@"ColumnDESC"];
            }
            
            [array addObject:indexs];
        }
            break;
        case nodeView:
        {
            FSView *v = (FSView *)node;
            
            NSString *exesql = [v FetchExectureSql];
            if (exesql.length > 0) {
                [array addObject:exesql];
            }
        }
            break;
        case nodeTigger:
        {
            FSTrigger *trigger = (FSTrigger *)node;
            
            NSString *exesql = [trigger FetchExectureSql];
            
            if (exesql.length > 0) {
                [array addObject:exesql];
            }
        }
            break;
            
        default:
            break;
    }
}

@end

#pragma mark - FSNode
@implementation FSNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        _parentNode = nil;
        _childrens = [[NSMutableArray alloc]init];
        _allowRename = NO;
    }
    return self;
}

- (void)dealloc
{
    _parentNode = nil;
    
    //NSLog(@" class [%@] free",[self class]);
}

- (void)addChildrenNode:(FSNode *)children
{
    if (!self.allowRename) {
        //此比较是根据对象进行比较的，如果想按际自己的进行比较，则需要在子类中实现isEqual:方式来自己定制
        if (![_childrens containsObject:children]) {
            children->_parentNode = self;
            [_childrens addObject:children];
        }
    }
    else
    {
        children->_parentNode = self;
        [_childrens addObject:children];
    }
}


- (void)insertChildrenNode:(FSNode *)children atIndex:(NSInteger)index
{
    if (!self.allowRename) {
        if (![_childrens containsObject:children]) {
            children->_parentNode = self;
            [_childrens insertObject:children atIndex:index];
        }
    }
    else
    {
        children->_parentNode = self;
        [_childrens insertObject:children atIndex:index];
    }
}

- (void)replaceChildrenNode:(FSNode *)children atIndex:(NSInteger)index
{
    if (!self.allowRename) {
        if (![_childrens containsObject:children]) {
            children->_parentNode = self;
            [_childrens replaceObjectAtIndex:index withObject:children];
        }
    }
    else
    {
        children->_parentNode = self;
        [_childrens replaceObjectAtIndex:index withObject:children];
    }
}

- (BOOL)transferChildrenA:(FSNode *)childrenA toChildrenB:(FSNode *)childrenB
{
    NSInteger idxa = [_childrens indexOfObject:childrenA];
    NSInteger idxb = [_childrens indexOfObject:childrenB];
    if (idxa == -1 || idxb == -1) {
        return NO;
    }
    
    [_childrens replaceObjectAtIndex:idxa withObject:childrenB];
    
    [_childrens replaceObjectAtIndex:idxb withObject:childrenA];
    
    return YES;
}

- (BOOL)transferChildrenAAtIndex:(NSInteger)indexA toChildrenBAtIndex:(NSInteger)indexB
{
    FSNode *ca = [_childrens objectAtIndex:indexA];
    FSNode *cb = [_childrens objectAtIndex:indexB];
    if (!ca || !cb) {
        return NO;
    }
    
    [_childrens replaceObjectAtIndex:indexA withObject:cb];
    
    [_childrens replaceObjectAtIndex:indexB withObject:ca];
    
    return YES;
}

- (void)removeChildrenNode:(FSNode *)children
{
    [_childrens removeObject:children];
}

- (void)removeAllChildren
{
    [_childrens removeAllObjects];
}

- (void)removeChildrenNodeAtIndex:(NSInteger)index
{
    [_childrens removeObjectAtIndex:index];
}

- (void)removeChildrenNodeOfName:(NSString *)nodename
{
    NSArray * findchilds = [self findNodeFromChildrenOfName:nodename];
    for (FSNode *item in findchilds) {
        [self removeChildrenNode:item];
    }
}

- (FSNode *)findNodeAtIndex:(NSInteger)index
{
    return [_childrens objectAtIndex:index];
}

- (NSInteger)indexOfNode:(FSNode *)node
{
    return [_childrens indexOfObject:node];
}

//只在当前结点的一级子结点进行查找
- (NSArray *)findNodeFromChildrenOfName:(NSString *)name
{
    NSMutableArray *founds = [NSMutableArray array];
    
    for (FSNode *item in _childrens) {
        if ([item.nodename isEqualToString:name]) {
            [founds addObject:item];
        }
    }
    
    return founds.count > 0 ? founds : nil;
}

- (NSArray *)findNodeIndexsFromChildrenOfName:(NSString *)name
{
    NSMutableArray *founds = [NSMutableArray array];
    
    NSInteger idx = -1;
    
    for (FSNode *item in _childrens) {
        idx++;
        
        if ([item.nodename isEqualToString:name]) {
            [founds addObject:[NSIndexPath indexPathWithIndex:idx]];
        }
    }
    
    return founds.count > 0 ? founds : nil;
}

- (NSArray *)allChildrensNodeName
{
    if (_childrens.count == 0) {
        return nil;
    }
    
    NSMutableArray *founds = [NSMutableArray array];
    
    for (FSNode *item in _childrens) {
        [founds addObject:item.nodename];
    }
    
    return founds;
}

- (BOOL)hasNeighbour
{
    if (self.parentNode) {
        [self.parentNode hasChildren];
    }
    return NO;
}

- (FSNode *)perviousNeighbour
{
    FSNode *p = self.parentNode;
    if (p) {
        NSInteger selfidx = [p indexOfNode:self];
        selfidx--;
        if (selfidx != -1) {
            return [p.childrens objectAtIndex:selfidx];
        }
    }
    
    return nil;
}

- (FSNode *)nextNeighbour
{
    FSNode *p = self.parentNode;
    if (p) {
        NSInteger selfidx = [p indexOfNode:self];
        selfidx++;
        if (selfidx < p.childrens.count) {
            return [p.childrens objectAtIndex:selfidx];
        }
    }
    
    return nil;
}

- (NSArray *)allNeighbours
{
    FSNode *p = self.parentNode;
    if (p) {
        NSMutableArray *nb = [NSMutableArray array];
        for (FSNode *item in p.childrens) {
            if (item == self) {
                continue;
            }
            [nb addObject:item];
        }
        
        return nb.count > 0 ? nb : nil;
    }
    
    return nil;
}

- (BOOL)exsistNodeName:(NSString *)name
{
    return [self findNodeFromChildrenOfName:name].count > 0;
}

- (BOOL)exsistNodeNameInNeighbour:(NSString *)name
{
    NSArray *brothers = [self allNeighbours];
    
    for (FSNode *brother in brothers) {
        if ([brother.nodename isEqualToString:name]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasChildren
{
    return self.childrens.count > 0;
}

- (BOOL)hasParent
{
    return _parentNode != nil;
}

- (FSNode *)parentNode
{
    return _parentNode;
}

- (NSInteger)childcounts
{
    return _childrens.count;
}

- (NSArray *)childrens
{
    return [NSArray arrayWithArray:_childrens];
}

- (void)setNodename:(NSString *)name
{
    _nodename = name;
}

- (NSString *)nodename
{
    return _nodename;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSNode *copynode            = [[self class]allocWithZone:zone];
    copynode.type               = self.type;
    copynode.nodename           = [self.nodename copy];
    copynode.allowRename        = self.allowRename;
    copynode->_parentNode       = self->_parentNode;
    copynode->_childrens        = [self->_childrens copy];
    
    return copynode;
}

//NSKeyedArchiver archivedDataWithRootObject 触发
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.type) forKey:@"type"];
    
    if (self.nodename) {
        [aCoder encodeObject:self.nodename forKey:@"nodename"];
    }
    
    [aCoder encodeObject:@(self.allowRename) forKey:@"allowRename"];
    
    if (self.userinfo) {
        [aCoder encodeObject:self.userinfo forKey:@"userinfo"];
    }
    
    if (_parentNode) {
        [aCoder encodeObject:_parentNode forKey:@"_parentNode"];
    }
    
    if (_childrens) {
        [aCoder encodeObject:_childrens forKey:@"_childrens"];
    }
}

//NSKeyedUnarchiver unarchiveObjectWithData触发
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.type               = (NodeType)[[aDecoder decodeObjectForKey:@"type"]integerValue];
        self.nodename           = [aDecoder decodeObjectForKey:@"nodename"];
        self.allowRename        = [[aDecoder decodeObjectForKey:@"allowRename"]boolValue];
        self.userinfo           = [aDecoder decodeObjectForKey:@"userinfo"];
        self->_parentNode       = [aDecoder decodeObjectForKey:@"_parentNode"];
        self->_childrens        = [aDecoder decodeObjectForKey:@"_childrens"];
    }
    return self;
}

@end

#pragma mark - FSSqliteER
/*************************************库**************************************/
@implementation FSSqliteER

- (id)copyWithZone:(nullable NSZone *)zone
{
    return [super copyWithZone:zone];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hashkey = -1;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

- (NSUInteger)hashkey
{
    return _hashkey;
}

- (void)setHashKey:(NSUInteger)key
{
    _hashkey = key;
}

- (NSString *)deleteNotesForSqls:(NSString *)sqls
{
    if (!sqls) return nil;
    
    NSMutableString *msrc = [NSMutableString stringWithString:@""];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:NOTES_MATCH_FETCH
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                                                             error:nil];
    
    NSArray *array = [regex matchesInString:sqls options:NSMatchingReportProgress range:NSMakeRange(0, sqls.length)];
    
    NSRange rg = NSMakeRange(0, 0);
    
    for (NSTextCheckingResult *item in array)
    {
        if (rg.length == 0 && rg.location == 0) {
            [msrc appendString:[sqls substringToIndex:item.range.location]];
        }
        else
        {
            NSString *ds = [sqls substringWithRange:NSMakeRange(rg.location, item.range.location - rg.location)];
            [msrc appendString:ds];
        }
        
        rg = NSMakeRange(item.range.location + item.range.length, 0) ;
    }
    
    if (rg.location < sqls.length) {
        [msrc appendString:[sqls substringFromIndex:rg.location]];
    }
    
    return msrc.length > 0 ? msrc : sqls;
}

- (NSString *)uniqueName:(NSString *)name withPrefixLength:(NSInteger)len
{
    if ([self exsistNodeName:name])
    {
        NSString *nums = [name substringFromIndex:len];
        NSString *ps = [name substringToIndex:len];
        if (nums.length > 0) {
            NSInteger i = [nums integerValue];
            return [self uniqueName:[NSString stringWithFormat:@"%@%ld",ps,(long)i+1] withPrefixLength:len];
        }
        else
        {   //重置到从1开始
            return [self uniqueName:[NSString stringWithFormat:@"%@1",ps] withPrefixLength:len];
        }
    }
    
    return name;
}

- (NSString *)uniqueName:(NSString *)name
{
    return [self uniqueName:name withPrefixLength:name.length];
}

- (NSString *)makeSqlKeyValue
{
    //TODO : sub class.
    return nil;
}

- (NSString *)FetchExectureSql
{
    //TODO : sub class.
    return nil;
}

- (NSString *)prefixKey
{
    return @"Z";
}

@end

#pragma mark - 类目
/*************************************类目*************************************/
@implementation FSTableCategory

- (NSString *)makeUniqueTableName
{
    return [self uniqueName:@"tablename"];
}

@end

@implementation FSIndexCategory

- (NSString *)makeUniqueIndexName
{
    return [self uniqueName:@"indexname"];
}

@end

@implementation FSViewCategory

- (NSString *)makeUniqueViewName
{
    return [self uniqueName:@"viewname"];
}

@end

@implementation FSTriggerCategory

- (NSString *)makeUniqueTriggerName
{
    return [self uniqueName:@"triggername"];
}

@end

#pragma mark - 触发器
/**************************************触发器*************************************/
@implementation FSTrigger

+ (NSArray *)supportTriggerEvents
{
    return [NSArray arrayWithObjects:@"INSERT",@"DELETE",@"UPDATE",@"UPDATE OF", nil];
}

+ (NSArray *)supportTriggerActions
{
    return [NSArray arrayWithObjects:@"BEFORE",@"AFTER",@"INSTEAD OF", nil];
}

- (instancetype)initWithTriggerName:(NSString *)triggerName
{
    self = [super init];
    if (self) {
        self.nodename = triggerName;
        self.type = nodeTigger;
        self.allowRename = NO;
        self.sqls = @"BEGIN\n-- write your trigger action here\nEND;";
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.events             = [aDecoder decodeObjectForKey:@"events"];
        self.actions            = [aDecoder decodeObjectForKey:@"actions"];
        self.sqls               = [aDecoder decodeObjectForKey:@"sqls"];
        self.tableName          = [aDecoder decodeObjectForKey:@"tableName"];
        self.columns            = [aDecoder decodeObjectForKey:@"columns"];
        
        NSString *fs = [self makeSqlKeyValue];
        if (fs.length > 0) {
            NSString *rs = [FSUtils md5:fs];
            NSUInteger key = [rs hash];
            [self setHashKey:key];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.events forKey:@"events"];
    [aCoder encodeObject:self.actions forKey:@"actions"];
    [aCoder encodeObject:self.sqls forKey:@"sqls"];
    [aCoder encodeObject:self.tableName forKey:@"tableName"];
    [aCoder encodeObject:self.columns forKey:@"columns"];
    
    NSString *fs = [self makeSqlKeyValue];
    if (fs.length > 0) {
        NSString *rs = [FSUtils md5:fs];
        NSUInteger key = [rs hash];
        [self setHashKey:key];
    }
}

- (NSString *)makeSqlKeyValue
{
    NSString *sqlfmt = nil;
    
    if (!self.tableName) {
        return nil;
    }
    
    if ([self.events isEqualToString:@"UPDATE OF"]) {
        sqlfmt = @"CREATE TRIGGER IF NOT EXISTS \"%@\" %@ %@ %@ ON \"%@\"\n%@";
        
        NSMutableString *cls = [NSMutableString stringWithString:@""];
        
        [self.columns enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
            [cls appendFormat:@"\"%@\",",obj];
        }];
        
        if (cls.length > 0) {
            [cls deleteCharactersInRange:NSMakeRange(cls.length - 1, 1)];
        }
        
        sqlfmt = [NSString stringWithFormat:sqlfmt,self.triggerName,self.actions,self.events,
                  cls,self.tableName,self.sqls];
    }
    else
    {
        sqlfmt = @"CREATE TRIGGER IF NOT EXISTS \"%@\" %@ %@ ON \"%@\"\n%@";
        sqlfmt = [NSString stringWithFormat:sqlfmt,self.triggerName,self.actions,self.events,
                  self.tableName,self.sqls];
    }

    return sqlfmt;
}

- (NSString *)FetchExectureSql
{
    NSString *notessql = [self makeSqlKeyValue];
    return [self deleteNotesForSqls:notessql];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSTrigger *copytrigger      = [super copyWithZone:zone];
    copytrigger.triggerName     = [self.triggerName copy];
    copytrigger.events          = self.events;
    copytrigger.actions         = self.actions;
    copytrigger.sqls            = self.sqls;
    copytrigger.tableName       = self.tableName;
    copytrigger.columns         = [self.columns copy];
    [copytrigger setHashKey:self.hashkey];
    return copytrigger;
}

@end

#pragma mark - 索引
/**************************************索引*************************************/
@implementation FSIndex

- (instancetype)initWithIndexName:(NSString *)indexname
{
    self = [super init];
    if (self) {
        self.nodename = indexname;
        self.allowRename = NO;
        self.type = nodeIndex;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.unique             = [[aDecoder decodeObjectForKey:@"unique"]boolValue];
        self.indexTableName     = [aDecoder decodeObjectForKey:@"indexTableName"];
        self.indexFieldNames    = [aDecoder decodeObjectForKey:@"indexFieldNames"];
        self.ascFields          = [aDecoder decodeObjectForKey:@"ascFields"];
        self.descFields         = [aDecoder decodeObjectForKey:@"descFields"];
        self.indexsqls          = [aDecoder decodeObjectForKey:@"indexsqls"];
        
        NSString *fs = [self makeSqlKeyValue];
        if (fs.length > 0) {
            NSString *rs = [FSUtils md5:fs];
            NSUInteger key = [rs hash];
            [self setHashKey:key];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:@(self.unique) forKey:@"unique"];
    [aCoder encodeObject:self.indexTableName forKey:@"indexTableName"];
    [aCoder encodeObject:self.indexFieldNames forKey:@"indexFieldNames"];
    [aCoder encodeObject:self.ascFields forKey:@"ascFields"];
    [aCoder encodeObject:self.descFields forKey:@"descFields"];
    [aCoder encodeObject:self.indexsqls forKey:@"indexsqls"];

    NSString *fs = [self makeSqlKeyValue];
    if (fs.length > 0) {
        NSString *rs = [FSUtils md5:fs];
        NSUInteger key = [rs hash];
        [self setHashKey:key];
    }
}

- (NSString *)makeSqlKeyValue
{
    NSString *idxsqlfmt = CREATE_INDEX_FMT_SQL;
    NSString *tbname = self.indexTableName;
    NSString *idxname = self.indexName;
    NSString *fields = [self.indexFieldNames componentsJoinedByString:@","];//要加引号
    
    NSString *ret = @"";
    if (self.unique) {
        ret = [NSString stringWithFormat:idxsqlfmt,@"UNIQUE",idxname,tbname,fields];
    }
    else
    {
        ret = [NSString stringWithFormat:idxsqlfmt,@"",idxname,tbname,fields];
    }
    
    return [ret uppercaseString];
}

- (NSString *)FetchExectureSql
{
    return [self makeSqlKeyValue];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSIndex *copyindex      = [super copyWithZone:zone];
    copyindex.unique        = self.unique;
    copyindex.indexName     = [self.indexName copy];
    copyindex.indexsqls     = self.indexsqls;
    copyindex.indexTableName    = [self.indexTableName copy];
    copyindex.indexFieldNames   = [self.indexFieldNames copy];
    copyindex.ascFields         = [self.ascFields copy];
    copyindex.descFields        = [self.descFields copy];
    [copyindex setHashKey:self.hashkey];
    return copyindex;
}

@end

#pragma mark - 视图
/**************************************视图*************************************/
@implementation FSView

- (instancetype)initWithViewName:(NSString *)viewname
{
    self = [super init];
    if (self) {
        self.nodename = viewname;
        self.allowRename = NO;
        self.type = nodeView;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sqls = [aDecoder decodeObjectForKey:@"sqls"];
        if (self.sqls.length > 0) {
            NSString *rs = [FSUtils md5:self.sqls];
            NSUInteger key = [rs hash];
            [self setHashKey:key];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    self.sqls = [self makeSqlKeyValue];
    if (self.sqls.length > 0) {
        NSString *rs = [FSUtils md5:self.sqls];
        NSUInteger key = [rs hash];
        [self setHashKey:key];
    }
    [aCoder encodeObject:self.sqls forKey:@"sqls"];
}

- (NSString *)makeSqlKeyValue
{
    NSString *sql = CREATE_VIEW_FMT_SQL;
    
    if (self.sqls) {
        return [NSString stringWithFormat:sql,self.viewName,self.sqls];
    }
    
    return nil;
}

- (NSString *)FetchExectureSql
{
    NSString *notessql = [self makeSqlKeyValue];
    return [self deleteNotesForSqls:notessql];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSView *copyview    = [super copyWithZone:zone];
    copyview.viewName   = [self.viewName copy];
    copyview.sqls       = self.sqls;
    [copyview setHashKey:self.hashkey];
    return copyview;
}
@end

/**************************************外键*************************************/
@implementation FSForeignKey

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectIndexOfOptions = -1;
        self.selectIndexOfDeleteAction = -1;
        self.selectIndexOfUpdateAction = -1;
    }
    return self;
}

+ (NSArray *)supportOptions
{
    NSArray *list = @[@"None",@"DEFERRABLE",@"DEFERRABLE INITIALLY DEFERRED",
                      @"DEFERRABLE INITIALLY IMMEDIATE",@"NOT DEFERRABLE",
                      @"NOT DEFERRABLE INITIALLY DEFERRED",@"NOT DEFERRABLE INITIALLY IMMEDIATE"];
    return list;
}

+ (NSArray *)supportActionForDelete
{
    NSArray *list = @[@"On Delete",@"NOT ACTION",@"RESTRICT",@"SET NULL",
                      @"SET DEFAULT ",@"CASCADE"];
    return list;
}

+ (NSArray *)supportActionForUpdate
{
    NSArray *list = @[@"On Update",@"NOT ACTION",@"RESTRICT",@"SET NULL",
                      @"SET DEFAULT ",@"CASCADE"];
    return list;
}

- (NSString *)makeSqlKeyValue
{
    NSString *fk = @"";
    if (self.targetTable.length > 0 && self.targetColumn.length > 0)
    {
        fk = [NSString stringWithFormat:@" REFERENCES \"%@\" (\"%@\")",
              [self.targetTable uppercaseString],[self.targetColumn uppercaseString]];
    }
    
    if (self.selectIndexOfOptions > 0)
    {
        NSString *option = [[[self class] supportOptions] objectAtIndex:self.selectIndexOfOptions];
        fk = [fk stringByAppendingString:[NSString stringWithFormat:@" %@",option]];
    }
    
    if (self.selectIndexOfDeleteAction > 1) {
        NSString *ondelete = [[[self class] supportActionForDelete] objectAtIndex:self.selectIndexOfDeleteAction];
        fk = [fk stringByAppendingString:[NSString stringWithFormat:@" ON DELETE %@",ondelete]];
    }
    
    if (self.selectIndexOfUpdateAction > 1) {
        NSString *onupdate = [[[self class] supportActionForUpdate] objectAtIndex:self.selectIndexOfUpdateAction];
        fk = [fk stringByAppendingString:[NSString stringWithFormat:@" ON UPDATE %@",onupdate]];
    }
    
    return fk;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSForeignKey *copyfk = [[self class]allocWithZone:zone];
    copyfk.targetColumn = [self.targetColumn copy];
    copyfk.targetTable  = [self.targetTable copy];
    copyfk.selectIndexOfDeleteAction = self.selectIndexOfDeleteAction;
    copyfk.selectIndexOfOptions = self.selectIndexOfOptions;
    copyfk.selectIndexOfUpdateAction = self.selectIndexOfUpdateAction;
    
    return copyfk;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.targetTable forKey:@"targetTable"];
    [aCoder encodeObject:self.targetColumn forKey:@"targetColumn"];
    [aCoder encodeObject:@(self.selectIndexOfOptions) forKey:@"selectIndexOfOptions"];
    [aCoder encodeObject:@(self.selectIndexOfDeleteAction) forKey:@"selectIndexOfDeleteAction"];
    [aCoder encodeObject:@(self.selectIndexOfUpdateAction) forKey:@"selectIndexOfUpdateAction"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.targetTable                = [aDecoder decodeObjectForKey:@"targetTable"];
        self.targetColumn               = [aDecoder decodeObjectForKey:@"targetColumn"];
        self.selectIndexOfOptions       = [[aDecoder decodeObjectForKey:@"selectIndexOfOptions"]integerValue];
        self.selectIndexOfDeleteAction  = [[aDecoder decodeObjectForKey:@"selectIndexOfDeleteAction"]integerValue];
        self.selectIndexOfUpdateAction  = [[aDecoder decodeObjectForKey:@"selectIndexOfUpdateAction"]integerValue];
    }
    return self;
}

@end

#pragma mark - 字段
/**************************************字段*************************************/
@implementation FSColumn

- (instancetype)initWithName:(NSString *)filedName
{
    self = [super init];
    if (self) {
        self.nodename = filedName;
        self.allowRename = NO;
        self.type = nodeColumn;
        self.fieldtype = ftInteger;
        self.constraint = fcNone;
    }
    return self;
}

+ (FSColumn *)column:(NSString *)filedName
{
    return [[FSColumn alloc]initWithName:filedName];
}

+ (FSColumn *)column:(NSString *)filedName ofType:(FSFieldType)fieldtype withTypeLength:(NSInteger)length
{
    FSColumn *fc = [[FSColumn alloc]initWithName:filedName];
    [fc setFieldtype:fieldtype];
    [fc setTypeLength:length];
    return fc;
}

- (NSArray *)supportFieldTypes
{
    //TEXT,REAL,INTEGER,BLOB,VARCHAR,FLOAT,DOUBLE,DATE,TIME,BOOLEAN,TIMESTAMP,BINARY
    return [NSArray arrayWithObjects:@"INTEGER",@"DOUBLE",@"FLOAT",@"REAL",@"BOOLEAN",
                @"DATE",@"TIME",@"TIMESTAMP",@"TEXT",@"VARCHAR",@"BLOB",@"BINARY", nil];
}

- (NSString *)covertToString:(FSFieldType)fieldtype
{
    return [[self supportFieldTypes]objectAtIndex:fieldtype];
}

- (FSFieldType)covertToType:(NSString *)fieldstring
{
    return (FSFieldType)[[self supportFieldTypes]indexOfObject:fieldstring];
}

- (FSForeignKey *)foreignKey
{
    if (!_foreignKey)
    {
        _foreignKey = [[FSForeignKey alloc]init];
    }
    return _foreignKey;
}

+ (NSString *)covertFieldConstraint:(FSFieldConstraint)constraint
{
    NSString *cst = @"";

    if (constraint & fcPrimarykey) {
        cst = [cst stringByAppendingString:@" PRIMARY KEY"];
    }
    
    if (constraint & fcAutoIncreament) {
        cst = [cst stringByAppendingString:@" AUTOINCREMENT"];
    }
    
    if (constraint & fcNotNull) {
        cst = [cst stringByAppendingString:@" NOT NULL"];
    }
    
    if (constraint & fcUnique) {
        cst = [cst stringByAppendingString:@" UNIQUE"];
    }
    
    return cst;//[cst stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSArray *)convertFieldConstraitToArray:(FSFieldConstraint)constraint
{
    NSMutableArray *arr = [NSMutableArray array];
    
    if (constraint & fcPrimarykey) {
        [arr addObject:@"PRIMARY KEY"];
    }
    
    if (constraint & fcAutoIncreament) {
        [arr addObject:@"AUTOINCREMENT"];
    }
    
    if (constraint & fcNotNull) {
        [arr addObject:@"NOT NULL"];
    }
    
    if (constraint & fcUnique) {
        [arr addObject:@"UNIQUE"];
    }
    return arr;
}

- (NSString *)makeSqlKeyValue
{
    NSString *sqlkv = [NSString stringWithFormat:@"\"%@\" %@",self.fieldName,[self covertToString:self.fieldtype]];
    
    NSString *constraint = [[self class]covertFieldConstraint:self.constraint];
    
    if (constraint.length > 0) {
        sqlkv = [sqlkv stringByAppendingString:constraint];
    }
    
    if (self.defaultvalue.length > 0) {
        sqlkv = [sqlkv stringByAppendingString:[NSString stringWithFormat:@" DEFAULT %@",self.defaultvalue]];
    }
    
    if (self.enableForeignkey)
    {
        NSString *fk = [self.foreignKey makeSqlKeyValue];
        if (fk.length > 0) {
            sqlkv = [sqlkv stringByAppendingString:fk];
        }
    }
    
    return sqlkv;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSColumn *copycolumn = [super copyWithZone:zone];
    copycolumn.defaultvalue = self.defaultvalue;
    copycolumn.constraint   = self.constraint;
    copycolumn.typeLength   = self.typeLength;
    copycolumn.fieldtype    = self.fieldtype;
    copycolumn.mark         = self.mark;
    copycolumn.enableForeignkey = self.enableForeignkey;
    copycolumn->_foreignKey = [self->_foreignKey copy];
    copycolumn.fieldName    = [self.fieldName copy];
    [copycolumn setHashKey:self.hashkey];
    return copycolumn;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.defaultvalue       = [aDecoder decodeObjectForKey:@"defaultvalue"];
        self.constraint         = (FSFieldConstraint)[[aDecoder decodeObjectForKey:@"constraint"]integerValue];
        self.typeLength         = [[aDecoder decodeObjectForKey:@"typeLength"]integerValue];
        self.fieldtype          = (FSFieldType)[[aDecoder decodeObjectForKey:@"fieldtype"]integerValue];
        self.mark               = [aDecoder decodeObjectForKey:@"mark"];
        self.enableForeignkey   = [[aDecoder decodeObjectForKey:@"enableForeignkey"]boolValue];
        _foreignKey             = [aDecoder decodeObjectForKey:@"_foreignKey"];
        
        NSString *fs = [self makeSqlKeyValue];
        if (fs.length > 0) {
            NSString *rs = [FSUtils md5:fs];
            NSUInteger key = [rs hash];
            [self setHashKey:key];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.defaultvalue forKey:@"defaultvalue"];
    [aCoder encodeObject:@(self.constraint) forKey:@"constraint"];
    [aCoder encodeObject:@(self.typeLength) forKey:@"typeLength"];
    [aCoder encodeObject:@(self.fieldtype) forKey:@"fieldtype"];
    [aCoder encodeObject:self.mark forKey:@"mark"];
    [aCoder encodeObject:@(self.enableForeignkey) forKey:@"enableForeignkey"];
    [aCoder encodeObject:_foreignKey forKey:@"_foreignKey"];

    NSString *fs = [self makeSqlKeyValue];
    if (fs.length > 0) {
        NSString *rs = [FSUtils md5:fs];
        NSUInteger key = [rs hash];
        [self setHashKey:key];
    }
}

@end

#pragma mark - 表
/**************************************表*************************************/
@implementation FSTable

- (instancetype)initWithTableName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.allowRename = NO;
        self.type = nodeTabel;
        self.nodename = name;
    }
    return self;
}

- (FSColumn *)addColumn:(NSString *)fieldName
{
    if ([self exsistNodeName:fieldName])
    {
        NSLog(@"field name [%@] is exsisted.",fieldName);
        return nil;
    }
    FSColumn *fc = [FSColumn column:fieldName];
    [self addChildrenNode:fc];
    return fc;
}

- (FSColumn *)insertColumn:(NSString *)fieldName AtIndex:(NSInteger)position
{
    if ([self exsistNodeName:fieldName])
    {
        NSLog(@"field name [%@] is exsisted.",fieldName);
        return nil;
    }
    
    FSColumn *fc = [FSColumn column:fieldName];
    
    [self insertChildrenNode:fc atIndex:position];
    
    return fc;
}

- (NSArray *)allColumns
{
    return self.childrens;
}

- (NSArray *)allColumnsName
{
    return [self allChildrensNodeName];
}

- (FSColumn *)findColumn:(NSString *)fieldName
{
    NSArray *columns = [self findNodeFromChildrenOfName:fieldName];
    return columns.count > 0 ? columns[0] : nil;
}

- (FSColumn *)columnAtIndex:(NSInteger)index
{
    return (FSColumn *)[self findNodeAtIndex:index];
}

- (void)removeColumn:(FSColumn *)column
{
    [self removeChildrenNode:column];
}

- (void)removeColumnOfIndex:(NSInteger)index
{
    [self removeChildrenNodeAtIndex:index];
}

- (void)removeAllColumn
{
    [self removeAllChildren];
}

- (NSString *)makeUniqueColumnName
{
    return [self uniqueName:@"fieldname"];
}

- (NSString *)makeSqlKeyValue
{
    NSString *fmt = CREATE_TABLE_FMT_SQL;
    NSMutableArray *fields = [NSMutableArray array];
    for (FSColumn *column in self.allColumns)
    {
        NSString *fs = [column makeSqlKeyValue];
        
        [fields addObject:fs];
    }
    
    NSString *ctbs = [NSString stringWithFormat:fmt,self.tableName,[fields componentsJoinedByString:@","]];
    return [ctbs uppercaseString];
}

- (NSString *)FetchExectureSql
{
    return [self makeSqlKeyValue];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSTable *copytb = [super copyWithZone:zone];
    copytb.tableName = [self.tableName copy];
    copytb.createsqls = self.createsqls;
    [copytb setHashKey:self.hashkey];
    return copytb;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.createsqls = [aDecoder decodeObjectForKey:@"createsqls"];
        
        if (self.createsqls.length > 0) {
            NSString *rs = [FSUtils md5:self.createsqls];
            NSUInteger key = [rs hash];
            [self setHashKey:key];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    self.createsqls = [self makeSqlKeyValue];
    
    if (self.createsqls.length > 0) {
        NSString *rs = [FSUtils md5:self.createsqls];
        NSUInteger key = [rs hash];
        [self setHashKey:key];
    }
    
    [aCoder encodeObject:self.createsqls forKey:@"createsqls"];
}

@end

#pragma mark - 库
/**************************************库*************************************/
@implementation FSDatabse

- (instancetype)initWithDatabaseName:(NSString *)dbname
{
    self = [super init];
    if (self) {
        self.nodename = dbname;
        self.type = nodeDatabase;
        
        tableKind = [[FSTableCategory alloc]init];
        tableKind.nodename = @"tables";
        [self addChildrenNode:tableKind];
        indexKind = [[FSIndexCategory alloc]init];
        indexKind.nodename = @"indexs";
        [self addChildrenNode:indexKind];
        viewKind  = [[FSViewCategory alloc]init];
        viewKind.nodename = @"views";
        [self addChildrenNode:viewKind];
        triggerKind = [[FSTriggerCategory alloc]init];
        triggerKind.nodename = @"triggers";
        [self addChildrenNode:triggerKind];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dynamic                = [[aDecoder decodeObjectForKey:@"dynamic"]boolValue];
        self.minVersion             = [aDecoder decodeObjectForKey:@"minVersion"];
        self.maxVersion             = [aDecoder decodeObjectForKey:@"maxVersion"];
        self.version                = [aDecoder decodeObjectForKey:@"version"];
        
        tableKind                   = [aDecoder decodeObjectForKey:@"tableKind"];
        indexKind                   = [aDecoder decodeObjectForKey:@"indexKind"];
        viewKind                    = [aDecoder decodeObjectForKey:@"viewKind"];
        triggerKind                 = [aDecoder decodeObjectForKey:@"triggerKind"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:@(self.dynamic) forKey:@"dynamic"];
    [aCoder encodeObject:self.minVersion forKey:@"minVersion"];
    [aCoder encodeObject:self.maxVersion forKey:@"maxVersion"];
    [aCoder encodeObject:self.version forKey:@"version"];
    
    [aCoder encodeObject:tableKind forKey:@"tableKind"];
    [aCoder encodeObject:indexKind forKey:@"indexKind"];
    [aCoder encodeObject:viewKind forKey:@"viewKind"];
    [aCoder encodeObject:triggerKind forKey:@"triggerKind"];
    
}

- (NSString *)makeUniqueTableName
{
    return [tableKind makeUniqueTableName];
}

- (NSString *)makeUniqueIndexName
{
    return [indexKind makeUniqueIndexName];
}

- (NSString *)makeUniqueViewName
{
    return [viewKind makeUniqueViewName];
}

- (NSString *)makeUniqueTriggerName
{
    return [triggerKind makeUniqueTriggerName];
}

- (FSTable *)addTable:(NSString *)tablName
{
    if ([tableKind exsistNodeName:tablName])
    {
        NSLog(@"table name [%@] is exsisted.",tablName);
        return nil;
    }
    
    FSTable *table = [[FSTable alloc]initWithTableName:tablName];
    
    [tableKind addChildrenNode:table];
    
    return table;
}

- (FSIndex *)addIndex:(NSString *)indexName
{
    if ([indexKind exsistNodeName:indexName])
    {
        NSLog(@"index name [%@] is exsisted.",indexName);
        return nil;
    }
    
    FSIndex *index = [[FSIndex alloc]initWithIndexName:indexName];
    
    [indexKind addChildrenNode:index];
    
    return index;
}

- (FSView *)addView:(NSString *)viewName
{
    if ([viewKind exsistNodeName:viewName])
    {
        NSLog(@"view name [%@] is exsisted.",viewName);
        return nil;
    }
    
    FSView *view = [[FSView alloc]initWithViewName:viewName];
    
    [viewKind addChildrenNode:view];
    
    return view;
}

- (FSTrigger *)addTrigger:(NSString *)triggerName
{
    if ([triggerKind exsistNodeName:triggerName])
    {
        NSLog(@"trigger name [%@] is exsisted.",triggerName);
        return nil;
    }
    
    FSTrigger *trigger = [[FSTrigger alloc]initWithTriggerName:triggerName];
    
    [triggerKind addChildrenNode:trigger];
    
    return trigger;
}

- (void)removeTableOfName:(NSString *)tablName
{
    [tableKind removeChildrenNodeOfName:tablName];
}

- (void)removeAllTable
{
    [tableKind removeAllChildren];
}

- (void)removeTable:(FSTable *)table
{
    [tableKind removeChildrenNode:table];
}

- (void)removeTableAtIndex:(NSInteger)index
{
    [tableKind removeChildrenNodeAtIndex:index];
}

- (NSInteger)indexOfTableName:(NSString *)tableName
{
    NSArray *ts = [tableKind findNodeIndexsFromChildrenOfName:tableName];
    
    if (ts.count > 0) {
        NSIndexPath *idx = ts[0];
        
        return idx.length;
    }
    
    return NSNotFound;
}

- (NSInteger)indexOfTable:(FSTable *)table
{
    return [tableKind indexOfNode:table];
}

- (NSArray *)tables
{
    return [tableKind childrens];
}

- (NSArray *)tableNames
{
    return [tableKind allChildrensNodeName];
}

- (FSTable *)tableOfName:(NSString *)tableName
{
    NSArray *tbs = [tableKind findNodeFromChildrenOfName:tableName];
    
    return tbs.count > 0 ? tbs[0] : nil;
}

- (FSTable *)tableAtIndex:(NSInteger)index
{
    return (FSTable *)[tableKind findNodeAtIndex:index];
}

// ******************************  索引  *******************************//
- (void)removeIndexOfName:(NSString *)indexName
{
    [indexKind removeChildrenNodeOfName:indexName];
}

- (void)removeAllIndex
{
    [indexKind removeAllChildren];
}

- (void)removeIndex:(FSIndex *)indexObject
{
    [indexKind removeChildrenNode:indexObject];
}

- (void)removeIndexAtIndex:(NSInteger)index
{
    [indexKind removeChildrenNodeAtIndex:index];
}

- (NSInteger)indexOfIndexName:(NSString *)indexName
{
    NSArray *idxs = [indexKind findNodeIndexsFromChildrenOfName:indexName];
    if (idxs.count > 0) {
        NSIndexPath *idx = idxs[0];
        return idx.length;
    }
    return NSNotFound;
}

- (NSInteger)indexOfIndex:(FSIndex *)indexObject
{
    return [indexKind indexOfNode:indexObject];
}

- (NSArray *)indexObjects
{
    return [indexKind childrens];
}

- (FSIndex *)indexObjectOfName:(NSString *)indexName
{
    NSArray *founds =  [indexKind findNodeFromChildrenOfName:indexName];
    return founds.count > 0 ? founds[0] : nil;
}

- (FSIndex *)indexOjbectAtIndex:(NSInteger)index
{
    return (FSIndex *)[indexKind findNodeAtIndex:index];
}

- (NSArray *)indexNames
{
    return [indexKind allChildrensNodeName];
}

// ******************************  视图  *******************************//
- (void)removeViewOfName:(NSString *)viewName
{
    [viewKind removeChildrenNodeOfName:viewName];
}

- (void)removeAllView
{
    [viewKind removeAllChildren];
}

- (void)removeView:(FSView *)view
{
    [viewKind removeChildrenNode:view];
}

- (void)removeViewAtIndex:(NSInteger)index
{
    [viewKind removeChildrenNodeAtIndex:index];
}

- (NSInteger)indexOfViewName:(NSString *)viewName
{
    NSArray *idxs = [viewKind findNodeIndexsFromChildrenOfName:viewName];
    
    if (idxs.count > 0) {
        NSIndexPath *idx = idxs[0];
        return idx.length;
    }
    
    return NSNotFound;
}

- (NSInteger)indexOfView:(FSView *)view
{
    return [viewKind indexOfNode:view];
}

- (NSArray *)views
{
    return [viewKind childrens];
}

- (FSView *)viewOfName:(NSString *)viewName
{
    NSArray *founds = [viewKind findNodeFromChildrenOfName:viewName];
    
    return founds.count > 0 ? founds[0] : nil;
}

- (FSView *)viewAtIndex:(NSInteger)index
{
    return (FSView *)[viewKind findNodeAtIndex:index];
}

- (NSArray *)viewNames
{
    return [viewKind allChildrensNodeName];
}

// ******************************  触发器  *******************************//
- (void)removeTriggerOfName:(NSString *)triggerName
{
    [triggerKind removeChildrenNodeOfName:triggerName];
}

- (void)removeAllTrigger
{
    [triggerKind removeAllChildren];
}

- (void)removeTrigger:(FSTrigger *)trigger
{
    [triggerKind removeChildrenNode:trigger];
}

- (void)removeTriggerAtIndex:(NSInteger)index
{
    [triggerKind removeChildrenNodeAtIndex:index];
}

- (NSInteger)indexOfTriggerName:(NSString *)triggerName
{
    NSArray *idxs = [triggerKind findNodeIndexsFromChildrenOfName:triggerName];
    
    if (idxs.count > 0) {
        NSIndexPath *idx = idxs[0];
        return idx.length;
    }
    
    return NSNotFound;
}

- (NSInteger)indexOfTriggers:(FSTrigger *)trigger
{
    return [triggerKind indexOfNode:trigger];
}

- (NSArray *)triggers
{
    return [triggerKind childrens];
}

- (FSTrigger *)triggerOfName:(NSString *)triggerName
{
    NSArray *founds = [triggerKind findNodeFromChildrenOfName:triggerName];
    
    return founds.count > 0 ? founds[0] : nil;
}

- (FSTrigger *)triggerAtIndex:(NSInteger)index
{
    return (FSTrigger *)[triggerKind findNodeAtIndex:index];
}

- (NSArray *)triggerNames
{
    return [triggerKind allChildrensNodeName];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    FSDatabse *copydb = [super copyWithZone:zone];
    copydb.version = [self.version copy];
    copydb.dbName = [self.dbName copy];
    copydb.dynamic = self.dynamic;
    copydb.minVersion = [self.minVersion copy];
    copydb.maxVersion = [self.maxVersion copy];
    copydb->tableKind = [self->tableKind copy];
    copydb->indexKind = [self->indexKind copy];
    copydb->triggerKind = [self->triggerKind copy];
    copydb->viewKind = [self->viewKind copy];
    
    return copydb;
}

@end
