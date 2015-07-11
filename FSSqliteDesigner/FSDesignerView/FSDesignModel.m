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

#import "FSDesignModel.h"

@implementation FSDesignModel

@end
