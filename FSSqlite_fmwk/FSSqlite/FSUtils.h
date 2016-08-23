//
//  FSUtils.h
//  FSSqliteDesigner
//
//  Created by fengsh on 30/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSUtils : NSObject
+ (NSString*) sha1:(NSString*)input;
+ (NSString *) md5:(NSString *) input;
///int 转 16进制字符串
+ (NSString *)ToHex:(NSUInteger)intvalue;
///json 数据转为字典
+ (NSDictionary *)jsonDataConvertToDictionary:(NSData *)jsondata;
///数组或字典转为string
+ (NSString *)stringArrayOrDictionaryConvert2:(id)arrordic;
///求字典或json数组对象的hash,flag为YES时则去除空格和换行符，制表符
+ (NSUInteger)stringArrayOrDictionaryConvert2hashvalue:(id)arrordic deleteSpaceAndNewline:(BOOL)flag;
///将数组或字典转为nsdata
+ (NSData *)dictionaryOrArrayConvert2Data:(id)object;
@end
