//
//  LCHttpClient.h
//  SocialNetwork
//
//  Created by Feng Junwen on 5/15/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface AVSNSHttpClient : NSObject

+(AVSNSHttpClient *)sharedInstance;

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
