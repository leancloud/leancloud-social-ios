//
//  LCHttpClient.m
//  SocialNetwork
//
//  Created by Feng Junwen on 5/15/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "LCHttpClient.h"
#import <AVOSCloud/AVJSONRequestOperation.h>
#import "LCUtils.h"

@interface LCHttpClient ()

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t completionQueue;
#else
@property (nonatomic, assign) dispatch_queue_t completionQueue;
#endif


@end

@implementation LCHttpClient

@synthesize clientImpl = _clientImpl;
@synthesize applicationId, applicationIdField, applicationKey, applicationKeyField, sessionTokenField;
@synthesize baseURL, timeoutInterval;

+ (LCHttpClient*)sharedInstance {
    static dispatch_once_t once;
    static LCHttpClient * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.timeoutInterval = kAVDefaultNetworkTimeoutInterval;
        sharedInstance.applicationIdField = @"X-avoscloud-Application-Id";
        sharedInstance.applicationKeyField = @"X-avoscloud-Application-Key";
        sharedInstance.sessionTokenField = @"X-avoscloud-Session-Token";
        
        sharedInstance.applicationId = [AVOSCloud getApplicationId];
        sharedInstance.applicationKey = [AVOSCloud getClientKey];
    });
    return sharedInstance;
}

- (AVHTTPClient *)clientImpl {
    if (!_clientImpl) {
        NSURL * url = [NSURL URLWithString:@"https://api.leancloud.cn/1.1"];
        _clientImpl = [AVHTTPClient clientWithBaseURL:url];
        
        //最大并发请求数 4
        _clientImpl.operationQueue.maxConcurrentOperationCount=4;
        
        [_clientImpl registerHTTPOperationClass:[AVJSONRequestOperation class]];
        [_clientImpl setParameterEncoding:AVJSONParameterEncoding];
    }
    [self updateHeaders];
    return _clientImpl;
}

-(void)updateHeaders {
    
    NSString *timestamp=[NSString stringWithFormat:@"%.0f",1000*[[NSDate date] timeIntervalSince1970]];
    NSString *sign=[LCUtils calMD5:[NSString stringWithFormat:@"%@%@",timestamp,self.applicationKey]];
    NSString *headerValue=[NSString stringWithFormat:@"%@,%@",sign,timestamp];
    
    [_clientImpl setDefaultHeader:@"x-avoscloud-request-sign" value:headerValue];
    [_clientImpl setDefaultHeader:self.applicationIdField value:self.applicationId];
    [_clientImpl setDefaultHeader:self.applicationKeyField value:self.applicationKey];
    [_clientImpl setDefaultHeader:@"Accept" value:@"application/json"];
}

- (dispatch_queue_t)completionQueue {
    if (!_completionQueue) {
        _completionQueue = dispatch_queue_create("com.leancloud.completionQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _completionQueue;
}

-(NSMutableURLRequest *)createRequest:(NSString *)method
                                 path:(NSString *)path
                           parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [self.clientImpl requestWithMethod:method path:path parameters:parameters];
    [request setTimeoutInterval:self.timeoutInterval];
    return request;
}

-(void)enqueueHTTPRequestOperation:(AVHTTPRequestOperation *)operation
{
    [self.clientImpl enqueueHTTPRequestOperation:operation];
}

-(void)postObject:(NSString *)path
   withParameters:(NSDictionary *)parameters
            block:(AVIdResultBlock)block
{
    NSMutableURLRequest *request = [self createRequest:@"POST" path:path parameters:parameters];

    [self goRequest:request saveResult:NO block:block retryTimes:0];
}

- (void)goRequest:(NSURLRequest *)request saveResult:(BOOL)save block:(AVIdResultBlock)block retryTimes:(int)times {
    AVJSONRequestOperation *operation = [[AVJSONRequestOperation alloc] initWithRequest:request];
    operation.successCallbackQueue = self.completionQueue;
    operation.failureCallbackQueue = self.completionQueue;
    [operation setCompletionBlockWithSuccess:^(AVHTTPRequestOperation *operation, id responseObject) {
        if (block && ![operation isCancelled]) {
            block(responseObject, nil);
        }
    } failure:^(AVHTTPRequestOperation *operation, NSError *error) {
        // if this operation isn't cancelled
        if (![operation isCancelled]) {
            block([(AVJSONRequestOperation *)operation responseJSON], error);
        };
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

-(void)getObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
           block:(AVIdResultBlock)block {
    
    NSMutableURLRequest *request = [self createRequest:@"GET" path:path parameters:parameters];
    
    [self goRequest:request saveResult:NO block:block retryTimes:0];
}

-(void)putObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
           block:(AVIdResultBlock)block {
    NSMutableURLRequest *request = [self createRequest:@"PUT" path:path parameters:parameters];
    
    [self goRequest:request saveResult:NO block:block retryTimes:0];
}

-(void)deleteObject:(NSString *)path
     withParameters:(NSDictionary *)parameters
              block:(AVIdResultBlock)block {
    NSMutableURLRequest *request = [self createRequest:@"DELETE" path:path parameters:parameters];
    
    [self goRequest:request saveResult:NO block:block retryTimes:0];
}

@end
