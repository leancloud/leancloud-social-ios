//
//  AVUtils.h
//  SocialNetwork
//
//  Created by Feng Junwen on 5/15/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

@interface LCUtils : NSObject

+(NSString *)stringFromDate:(NSDate *)date;

+(void)copyDictionary:(NSDictionary *)src
             toObject:(AVObject *)target;

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
