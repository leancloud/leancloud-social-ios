//
//  AVUtils.m
//  SocialNetwork
//
//  Created by Feng Junwen on 5/15/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "LCUtils.h"
#import <AVOSCloud/AVGlobal.h>

#import <CommonCrypto/CommonDigest.h>


@implementation LCUtils

+(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+(void)copyDictionary:(NSDictionary *)src
             toObject:(AVObject *)target {
    ;
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

@end

