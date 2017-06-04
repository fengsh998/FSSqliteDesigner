//
//  FSSqliteParse.m
//  FSSqliteDemo
//
//  Created by fengsh on 16/1/7.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import "FSSqliteParse.h"
#import "FSSqliteDDL.h"
#import "FSDesignFileObject.h"

@implementation FSSqliteParse

- (NSData *)loadFileMainVersionDBFromSqlitemodeld:(NSString *)filepath
{
    return nil;
}

- (NSDictionary *)makeDBSqlForDescriptionModel:(NSData *)modeldata
{
    return nil;
}

@end

@implementation FSSqliteEngine

- (id<FSSqliteProtocol>)defalutSqliteParse
{
    return [[FSSqliteParseImpl alloc]init];
}

@end

@implementation FSSqliteParseImpl

- (NSData *)loadFileMainVersionDBFromSqlitemodeld:(NSString *)filepath
{
    NSString *vms = [filepath stringByAppendingPathComponent:@"version-model.plist"];
    
    NSDictionary *vm = [NSDictionary dictionaryWithContentsOfFile:vms];
    vms =  vm[@"currentModelName"];
    
    vms = [filepath stringByAppendingPathComponent:vms];
    
    return  [self loadFileFromSqliteModel:vms];
}

- (NSData *)loadFileFromSqliteModel:(NSString *)filepath
{
    NSURL *furl = [NSURL fileURLWithPath:filepath];
    if (furl) {
        return [NSData dataWithContentsOfURL:furl];
    }
    
    return nil;
}

- (NSDictionary *)makeDBSqlForDescriptionModel:(NSData *)modeldata
{
    FSDesignFileObject *dbfile = [FSDesignFileObject loadFromFileData:modeldata error:nil];
    
    NSDictionary *dbStructure = [dbfile exportSqls];
    
    return dbStructure;
}

///从数组a,b中取出相同的元素
- (NSArray *)same:(NSArray *)a with:(NSArray *)b
{
    NSPredicate *commPrd = [NSPredicate predicateWithFormat:@"SELF in %@", a];
    NSArray *comns = [b filteredArrayUsingPredicate:commPrd];
    return comns;
}

///从数组a,b中取出a中不在b中的元素
- (NSArray *)elementInA:(NSArray *)a butNotInB:(NSArray *)b
{
    //获取需要删除
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)",b];
    NSArray *ns = [a filteredArrayUsingPredicate:prd];
    return ns;
}

- (NSDictionary *)compareSqliteModel:(NSData *)modeldata andNewSqliteModel:(NSData *)newmodeldata
{
    NSError *error = nil;
    
    FSDesignFileObject *A = [FSDesignFileObject loadFromFileData:modeldata error:&error];
    if (error) {
        NSLog(@"params modeldata <%p> %@",modeldata,error);
        return nil;
    }
    
    FSDesignFileObject *B = [FSDesignFileObject loadFromFileData:newmodeldata error:&error];
    if (error) {
        NSLog(@"params newmodeldata <%p> %@",newmodeldata,error);
        return nil;
    }

    //A,B的版本号相同，就直接返回
    if ([A.modelVersion isEqualToString:B.modelVersion]) {
        return nil;
    }
    
    NSArray *ans = [A allDatabaseOfName];
    NSArray *bns = [B allDatabaseOfName];
    
    NSArray *comns = [self same:ans with:bns];
//    NSArray *delns = [self elementInA:ans butNotInB:bns];
//    NSArray *addns = [self elementInA:bns butNotInB:ans];

    NSMutableDictionary *sqlsdic = [NSMutableDictionary dictionary];
    for (NSString *dbname in comns) {
        @autoreleasepool {
            FSDatabse *a = [A databaseOfName:dbname];
            FSDatabse *b = [B databaseOfName:dbname];
            if (a && b) {
                NSArray *comsqls = [self compareDatabase:a withnewDB:b];
                if (comsqls.count > 0) {
                    [sqlsdic setObject:comsqls forKey:dbname];
                }
            }
        }
    }
    
    /* 暂不处理了如果模板有表就可以创建没有就说明不使用了
    for (NSString *dbname in delns) {
        @autoreleasepool {

        }
    }
    
    for (NSString *dbname in addns) {
        @autoreleasepool {
            
        }
    }
     */
   
    
    return sqlsdic.count > 0 ? sqlsdic : nil;
}

- (NSArray <NSString *> *)compareSqliteModel:(NSData *)modeldata andNewSqliteModel:(NSData *)newmodeldata withDBName:(NSString *)dbname
{
    NSError *error = nil;
    FSDesignFileObject *A = [FSDesignFileObject loadFromFileData:modeldata error:&error];
    if (error) {
        NSLog(@"params modeldata <%p> %@",modeldata,error);
        return nil;
    }
    FSDesignFileObject *B = [FSDesignFileObject loadFromFileData:newmodeldata error:&error];
    if (error) {
        NSLog(@"params newmodeldata <%p> %@",newmodeldata,error);
        return nil;
    }
    
    FSDatabse *fda =[A databaseOfName:dbname];
    FSDatabse *fdb = [B databaseOfName:dbname];
    
    if (fda && fdb) {
        NSArray *comsqls = [self compareDatabase:fda withnewDB:fdb];
        
        return comsqls;
    }
    
    return nil;
}

- (NSArray *)compareDatabase:(FSDatabse *)adb withnewDB:(FSDatabse *)bdb
{
    NSMutableArray * arrs = [NSMutableArray array];
    
    NSArray *tablesqls = [self compareTableInDatabase:adb withnewDB:bdb];
    
    if (tablesqls.count > 0) {
        [arrs addObjectsFromArray:tablesqls];
    }
    
    NSArray *indexsqls = [self compareIndexInDatabase:adb withnewDB:bdb];
    
    if (indexsqls.count > 0) {
        [arrs addObjectsFromArray:indexsqls];
    }
    
    NSArray *viewsqls = [self compareViewInDatabase:adb withnewDB:bdb];
    
    if (viewsqls.count > 0) {
        [arrs addObjectsFromArray:viewsqls];
    }
    
    NSArray *triggersqls = [self compareTriggerInDatabase:adb withnewDB:bdb];
    
    if (triggersqls.count > 0) {
        [arrs addObjectsFromArray:triggersqls];
    }
    
    return arrs;
}

//表语句
/*
 ALTER TABLE "aa" ADD "column2" TEXT;
 
 ALTER TABLE "aa" RENAME TO sqlitemanager_temp_table_217134969264;
 
 CREATE TABLE "aa" ("column1" TEXT, "column3" TEXT, "column4" TEXT, "column2" TEXT);
 
 INSERT INTO "aa" ("column1","column3","column4","column2") SELECT "column1","column3","column4","column2" FROM sqlitemanager_temp_table_217134969264;
 
 DROP TABLE sqlitemanager_temp_table_217134969264;
 
 COMMIT;
 */
- (NSArray *)compareTableInDatabase:(FSDatabse *)adb withnewDB:(FSDatabse *)bdb
{
    NSArray *atbs = [adb tableNames];
    NSArray *btbs = [bdb tableNames];
    
    NSArray *comns = [self same:atbs with:btbs];
    NSArray *delns = [self elementInA:atbs butNotInB:btbs];
    NSArray *addns = [self elementInA:btbs butNotInB:atbs];
    
    NSMutableArray *sqls = [NSMutableArray array];
    //比对相同的表
    for (NSString *tablename in comns) {
        
        FSTable *atab = [adb tableOfName:tablename];
        FSTable *btab = [bdb tableOfName:tablename];
        
        if (atab && btab && (atab.hashkey != btab.hashkey)) {
            
            NSMutableArray *ans = [NSMutableArray array];
            NSMutableArray *bns = [NSMutableArray array];
            for (FSColumn *col in atab.allColumns) {
                [ans addObject:[NSString stringWithFormat:@"\"%@\"",[col.fieldName uppercaseString]]];
            }
            
            for (FSColumn *col in btab.allColumns) {
                [bns addObject:[NSString stringWithFormat:@"\"%@\"",[col.fieldName uppercaseString]]];
            }
            
            NSArray *commfields = [self same:ans with:bns];
            
            NSString *comfields = [commfields componentsJoinedByString:@","];
            
            NSInteger acount = atab.allColumns.count;
            NSInteger bcount = btab.allColumns.count;
            
            if (bcount < acount) {
                NSString *tmptablename = [NSString stringWithFormat:@"fssqlite_table_tmp_%@",tablename];
                //获取相同的字段名
                [sqls addObject:[NSString stringWithFormat:RENAME_TABLENAME_SQL,tablename,tmptablename]];
                
                [sqls addObject:btab.createsqls];
                
                [sqls addObject:[NSString stringWithFormat:EXPORT_DATA_DEST_TABLE,tablename,comfields,comfields,tmptablename]];
                
                [sqls addObject:[NSString stringWithFormat:DROP_TABLE_SQL,tmptablename]];
                
            }
            else
            {
                //相同的字段顺序里是否有改变
                BOOL haschange = NO;
                for (NSInteger i = 0; i < acount; i++) {
                    FSColumn *bcol = [btab columnAtIndex:i];
                    FSColumn *acol = [atab columnAtIndex:i];
                    if (bcol.hashkey != acol.hashkey) {
                        haschange = YES;
                        break;
                    }
                }
                
                if (!haschange) {
                    NSMutableArray *fs = [NSMutableArray array];
                    for (NSInteger i = acount; i < bcount; i++) {
                        FSColumn *bcol = [btab columnAtIndex:i];
                        [fs addObject:[bcol makeSqlKeyValue]];
                    }
                    
                    [sqls addObject:[NSString stringWithFormat:@"ALTER TABLE \"%@\" ADD %@",tablename,[fs componentsJoinedByString:@","]]];
                }
                else
                {
                    NSString *tmptablename = [NSString stringWithFormat:@"fssqlite_table_tmp_%@",tablename];
                    //获取相同的字段名
                    [sqls addObject:[NSString stringWithFormat:RENAME_TABLENAME_SQL,tablename,tmptablename]];
                    
                    [sqls addObject:btab.createsqls];
                    
                    [sqls addObject:[NSString stringWithFormat:EXPORT_DATA_DEST_TABLE,tablename,comfields,comfields,tmptablename]];
                    
                    [sqls addObject:[NSString stringWithFormat:DROP_TABLE_SQL,tmptablename]];
                }
            }
            
        }
    }
    
    //处理删除的表，注意相关的视图，索引，触发器是否有影响
    for (NSString *tablename in delns) {
        //构建删除却本
        //DROP TABLE IF EXSIST
        [sqls addObject:[NSString stringWithFormat:DROP_TABLE_SQL,tablename]];
    }
    
    //处理添加的表
    for (NSString *tablename in addns) {
        //构建添加脚本
        FSTable *btab = [bdb tableOfName:tablename];
        [sqls addObject:[btab createsqls]];
    }
    
    return sqls;
}

//索引语句
- (NSArray *)compareIndexInDatabase:(FSDatabse *)adb withnewDB:(FSDatabse *)bdb
{
    NSArray  *aidxs = [adb indexNames];
    NSArray  *bidxs = [bdb indexNames];
    
    NSMutableArray *sqls = [NSMutableArray array];
    
    NSArray *commidxs = [self same:aidxs with:bidxs];
    
    NSArray *delidxs = [self elementInA:aidxs butNotInB:bidxs];
    
    NSArray *addidxs = [self elementInA:bidxs butNotInB:aidxs];
    
    for (NSString *idxname in commidxs) {
        FSIndex *a = [adb indexObjectOfName:idxname];
        FSIndex *b = [bdb indexObjectOfName:idxname];
        
        if (a && b && a.hashkey != b.hashkey) {
            [sqls addObject:[NSString stringWithFormat:DROP_INDEX_SQL,idxname]];
            [sqls addObject:[b makeSqlKeyValue]];
        }
    }
    
    for (NSString *idxname in delidxs) {
        [sqls addObject:[NSString stringWithFormat:DROP_INDEX_SQL,idxname]];
    }
    
    for (NSString *idxname in addidxs) {
        FSIndex *b = [bdb indexObjectOfName:idxname];
        [sqls addObject:[b makeSqlKeyValue]];
    }
    
    
    return sqls;
}

//视图语句
- (NSArray *)compareViewInDatabase:(FSDatabse *)adb withnewDB:(FSDatabse *)bdb
{
    NSArray  *avss = [adb indexNames];
    NSArray  *bvss = [bdb indexNames];
    
    NSMutableArray *sqls = [NSMutableArray array];
    
    NSArray *commvs = [self same:avss with:bvss];
    
    NSArray *delvs = [self elementInA:avss butNotInB:bvss];
    
    NSArray *addvs = [self elementInA:bvss butNotInB:avss];
    
    for (NSString *vsname in commvs) {
        FSView *a = [adb viewOfName:vsname];
        FSView *b = [bdb viewOfName:vsname];
        
        if (a && b && a.hashkey != b.hashkey) {
            [sqls addObject:[NSString stringWithFormat:DROP_VIEW_SQL,vsname]];
            [sqls addObject:[b makeSqlKeyValue]];
        }
    }
    
    for (NSString *vsname in delvs) {
        [sqls addObject:[NSString stringWithFormat:DROP_VIEW_SQL,vsname]];
    }
    
    for (NSString *vsname in addvs) {
        FSIndex *b = [bdb indexObjectOfName:vsname];
        [sqls addObject:[b makeSqlKeyValue]];
    }
    
    
    return sqls;

}

//触发器语句
- (NSArray *)compareTriggerInDatabase:(FSDatabse *)adb withnewDB:(FSDatabse *)bdb
{
    
    NSArray  *atgs = [adb triggerNames];
    NSArray  *btgs = [bdb triggerNames];
    
    NSMutableArray *sqls = [NSMutableArray array];
    
    NSArray *commtg = [self same:atgs with:btgs];
    
    NSArray *deltg = [self elementInA:atgs butNotInB:btgs];
    
    NSArray *addtg = [self elementInA:btgs butNotInB:atgs];
    
    for (NSString *tgname in commtg) {
        FSTrigger *a = [adb triggerOfName:tgname];
        FSTrigger *b = [bdb triggerOfName:tgname];
        
        if (a && b && a.hashkey != b.hashkey) {
            [sqls addObject:[NSString stringWithFormat:DROP_TRIGGER_SQL,tgname]];
            [sqls addObject:[b makeSqlKeyValue]];
        }
    }
    
    for (NSString *tgname in deltg) {
        [sqls addObject:[NSString stringWithFormat:DROP_TRIGGER_SQL,tgname]];
    }
    
    for (NSString *tgname in addtg) {
        FSIndex *b = [bdb indexObjectOfName:tgname];
        [sqls addObject:[b makeSqlKeyValue]];
    }
    
    
    return sqls;

}


@end
