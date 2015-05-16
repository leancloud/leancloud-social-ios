//
//  AVOSCloudSNSUtils.h
//  AVOSCloudSNS
//
//  Created by Travis on 13-10-21.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeanCloudSNS.h"

#define NameStringOfParam(param) [NSString stringWithFormat:@"%s", #param]

@interface LeanCloudSNSUtils : NSObject
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params;
+ (NSDictionary *)unserializeURL:(NSString *)url;
+ (NSDictionary *)unserializeJSONP:(NSString *)jsonp;

+(NSDate*)expireDateWithOffset:(NSInteger)offset;

@end
