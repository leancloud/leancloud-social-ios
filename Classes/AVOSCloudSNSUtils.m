//
//  AVOSCloudSNSUtils.m
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#define dateFormat   @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"

#import "AVOSCloudSNSUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AVOSCloudSNSUtils
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params{
    NSURL* parsedURL = [NSURL URLWithString:baseURL];
    
    NSString* queryPrefix=nil;
    
    if ([baseURL hasSuffix:@"?"]) {
        queryPrefix=@"";
    }else{
        queryPrefix=parsedURL.query?@"&":@"?";
    }
    
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator])
    {
        CFStringRef escaped_value= CFURLCreateStringByAddingPercentEscapes(
                                                                                               NULL, /* allocator */
                                                                                               (CFStringRef)[params objectForKey:key],
                                                                                               NULL, /* charactersToLeaveUnescaped */
                                                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                               kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, (__bridge NSString*)escaped_value]];
        CFRelease(escaped_value);
        
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

+ (NSDictionary *)unserializeURL:(NSString *)url
{
    NSArray *cpmts= [url componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?#&"]];
    
    if (cpmts.count<2) {
        return nil;
    }
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    for (int i=1; i<cpmts.count; i++) {
        NSArray *kv= [cpmts[i] componentsSeparatedByString:@"="];
        if (kv.count!=2) continue;
        
        [dict setObject:kv[1] forKey:kv[0]];
    }
    
    return dict;
}

+ (NSDictionary *)unserializeJSONP:(NSString *)jsonp {
    NSRange begin = [jsonp rangeOfString:@"(" options:NSLiteralSearch];
    NSRange end = [jsonp rangeOfString:@")" options:NSBackwardsSearch|NSLiteralSearch];
    BOOL parseFail = (begin.location == NSNotFound || end.location == NSNotFound || end.location - begin.location < 2);
    if (!parseFail)
    {
        NSString *json = [jsonp substringWithRange:NSMakeRange(begin.location + 1, (end.location - begin.location) - 1)];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:NULL];
        return dict;
    } else {
        return nil;
    }
}

+(NSDate*)expireDateWithOffset:(NSInteger)offset{
    //加上网络延迟的冗余
    offset-=20;
    
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:offset];
    return date;
}

+(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

#pragma mark - Safe way to call block

#define safeBlock(first_param) \
if (block) { \
if ([NSThread isMainThread]) { \
block(first_param, error); \
}else {\
dispatch_async(dispatch_get_main_queue(), ^{ \
block(first_param, error); \
}); \
} \
}

+ (void)callBooleanResultBlock:(AVBooleanResultBlock)block
                         error:(NSError *)error
{
    safeBlock(error == nil);
}

+ (void)callIntegerResultBlock:(AVIntegerResultBlock)block
                        number:(NSInteger)number
                         error:(NSError *)error {
    safeBlock(number);
}

+ (void)callArrayResultBlock:(AVArrayResultBlock)block
                       array:(NSArray *)array
                       error:(NSError *)error {
    safeBlock(array);
}

+ (void)callObjectResultBlock:(AVObjectResultBlock)block
                       object:(AVObject *)object
                        error:(NSError *)error {
    safeBlock(object);
}

+ (void)callUserResultBlock:(AVUserResultBlock)block
                       user:(AVUser *)user
                      error:(NSError *)error {
    safeBlock(user);
}

+ (void)callIdResultBlock:(AVIdResultBlock)block
                   object:(id)object
                    error:(NSError *)error {
    safeBlock(object);
}

+ (void)callImageResultBlock:(AVImageResultBlock)block
                       image:(UIImage *)image
                       error:(NSError *)error
{
    safeBlock(image);
}

+ (void)callFileResultBlock:(AVFileResultBlock)block
                     AVFile:(AVFile *)file
                      error:(NSError *)error
{
    safeBlock(file);
}

+ (void)callProgressBlock:(AVProgressBlock)block
                  percent:(NSInteger)percentDone {
    if (block) {
        if ([NSThread isMainThread]) {
            block(percentDone);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(percentDone);
            });
        }
    }
}

+(void)callSetResultBlock:(AVSetResultBlock)block
                      set:(NSSet *)set
                    error:(NSError *)error
{
    if (block) {
        if ([NSThread isMainThread]) {
            block(set, error);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(set, error);
            });
        }
    }
}

+(void)callCloudQueryResultBlock:(AVCloudQueryCallback)block
                          result:(AVCloudQueryResult *)result
                           error:error {
    safeBlock(result);
}

+ (NSString*)calMD5:(NSString *)input {
    const char *cstr = [input UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

+ (NSError *)errorWithText:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
    va_list ap;
    va_start(ap, format);
    NSDictionary *errorInfo = @{NSLocalizedDescriptionKey : [[NSString alloc] initWithFormat:format arguments:ap]};
    va_end(ap);
    NSError *error = [NSError errorWithDomain:@"LeanCloudSocial Domain" code:0 userInfo:errorInfo];
    return error;
}

@end
