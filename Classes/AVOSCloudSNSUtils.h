//
//  AVOSCloudSNSUtils.h
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVOSCloudSNS.h"
#import <AVOSCloud/AVOSCloud.h>

#ifdef DEBUG
#   define SLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define SLog(fmt, ...)
#endif

#define NameStringOfParam(param) [NSString stringWithFormat:@"%s", #param]

@interface AVOSCloudSNSUtils : NSObject
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params;
+ (NSDictionary *)unserializeURL:(NSString *)url;
+ (NSDictionary *)unserializeJSONP:(NSString *)jsonp;

+(NSDate*)expireDateWithOffset:(NSInteger)offset;

#pragma mark -

+(NSString *)stringFromDate:(NSDate *)date;

+ (NSError *)errorWithText:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

#pragma mark - Block

+ (void)callBooleanResultBlock:(AVBooleanResultBlock)block
                         error:(NSError *)error;

+ (void)callIntegerResultBlock:(AVIntegerResultBlock)block
                        number:(NSInteger)number
                         error:(NSError *)error;

+ (void)callArrayResultBlock:(AVArrayResultBlock)block
                       array:(NSArray *)array
                       error:(NSError *)error;

+ (void)callObjectResultBlock:(AVObjectResultBlock)block
                       object:(AVObject *)object
                        error:(NSError *)error;

+ (void)callUserResultBlock:(AVUserResultBlock)block
                       user:(AVUser *)user
                      error:(NSError *)error;

+ (void)callIdResultBlock:(AVIdResultBlock)block
                   object:(id)object
                    error:(NSError *)error;

+ (void)callProgressBlock:(AVProgressBlock)block
                  percent:(NSInteger)percentDone;


+ (void)callImageResultBlock:(AVImageResultBlock)block
                       image:(UIImage *)image
                       error:(NSError *)error;

+ (void)callFileResultBlock:(AVFileResultBlock)block
                     AVFile:(AVFile *)file
                      error:(NSError *)error;

+(void)callSetResultBlock:(AVSetResultBlock)block
                      set:(NSSet *)set
                    error:(NSError *)error;
+(void)callCloudQueryResultBlock:(AVCloudQueryCallback)block
                          result:(AVCloudQueryResult *)result
                           error:error;

+ (NSString*)calMD5:(NSString*)input;


@end
