//
//  FSUtils.m
//  FSSqliteDesigner
//
//  Created by fengsh on 30/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation FSUtils

+ (NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

+ (NSString *)ToHex:(NSUInteger)intvalue
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig= intvalue % 16;
        intvalue = intvalue / 16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
                
            default:
                nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (intvalue == 0) {
            break;  
        }
    }  
    return str;  
}

+ (NSDictionary *)jsonDataConvertToDictionary:(NSData *)jsondata
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:jsondata
                          options:kNilOptions
                          error:&error];
    return !error ? json : nil;
}

+ (NSData *)dictionaryOrArrayConvert2Data:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]] ||
        [object isKindOfClass:[NSArray class]])
    {
        NSError *parseError = nil;
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&parseError];
        if (!parseError)
        {
            return jsonData;
        }
    }
    return nil;
}

+ (NSString *)stringArrayOrDictionaryConvert2:(id)arrordic
{
    NSData * dt = [self dictionaryOrArrayConvert2Data:arrordic];
    if (dt) {
        NSString *arrstring = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
        return [arrstring lowercaseString];
    }
    return nil;
}

+ (NSUInteger)stringArrayOrDictionaryConvert2hashvalue:(id)arrordic deleteSpaceAndNewline:(BOOL)flag
{
    NSString *ss = [self stringArrayOrDictionaryConvert2:arrordic];
    
    if (flag)
    {
        ss = [ss stringByReplacingOccurrencesOfString:@" " withString:@""];
        ss = [ss stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
        ss = [ss stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        ss = [ss stringByReplacingOccurrencesOfString:@"\\t" withString:@""];
        ss = [ss stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    
    //发现太长的string 小改一部分hash值是相同的，所以使用sha1或md5来将字符串减少来获取hash
    ss = [self sha1:ss];
    
    if (ss.length > 0) {
        return ss.hash;
    }
    
    return NSNotFound;
}

@end
