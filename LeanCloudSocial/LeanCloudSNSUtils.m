//
//  AVOSCloudSNSUtils.m
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import "LeanCloudSNSUtils.h"

@implementation LeanCloudSNSUtils
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

@end
