//
//  LCHttpClient.h
//  SocialNetwork
//
//  Created by Feng Junwen on 5/15/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloud/AVHTTPClient.h>

@interface LCHttpClient : NSObject

+(LCHttpClient *)sharedInstance;

@property (nonatomic, readonly, strong) AVHTTPClient * clientImpl;

@property (nonatomic, readwrite, copy) NSString * applicationId;
@property (nonatomic, readwrite, copy) NSString * applicationKey;
@property (nonatomic, copy) NSString * baseURL;

@property (nonatomic, readwrite, copy) NSString * applicationIdField;
@property (nonatomic, readwrite, copy) NSString * applicationKeyField;
@property (nonatomic, readwrite, copy) NSString * sessionTokenField;
@property (nonatomic, readwrite, assign) NSTimeInterval timeoutInterval;

-(void)postObject:(NSString *)path
   withParameters:(NSDictionary *)parameters
            block:(AVIdResultBlock)block;

-(void)getObject:(NSString *)path
   withParameters:(NSDictionary *)parameters
            block:(AVIdResultBlock)block;

-(void)putObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
           block:(AVIdResultBlock)block;

-(void)deleteObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
           block:(AVIdResultBlock)block;

@end
