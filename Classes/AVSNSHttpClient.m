//
//  LCHttpClient.m
//  SocialNetwork
//
//  Created by Feng Junwen on 5/15/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import "AVSNSHttpClient.h"
#import "AVOSCloudSNSUtils.h"

@interface AVSNSHttpClient ()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation AVSNSHttpClient

+ (AVSNSHttpClient*)sharedInstance {
    static dispatch_once_t once;
    static AVSNSHttpClient * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.baseURL = [NSURL URLWithString:@"https://api.leancloud.cn/1.1/"];
        sharedInstance.operationQueue = [[NSOperationQueue alloc] init];
    });
    return sharedInstance;
}

- (NSString *)queryStringFromParameters:(NSDictionary *)parameters {
    NSMutableString *queries = [[NSMutableString alloc] init];
    NSArray *keys = [parameters allKeys];
    for (int i = 0; i < keys.count; i++) {
        if (i != 0) {
            [queries appendString:@"&"];
        }
        NSString *value = [parameters valueForKey:keys[i]];
        [queries appendFormat:@"%@=%@", keys[i], value];
    }
    return [queries stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[AVOSCloud getApplicationId] forHTTPHeaderField:@"X-AVOSCloud-Application-Id"];
    
    NSString *timestamp=[NSString stringWithFormat:@"%.0f",1000*[[NSDate date] timeIntervalSince1970]];
    NSString *sign=[AVOSCloudSNSUtils calMD5:[NSString stringWithFormat:@"%@%@",timestamp,[AVOSCloud getClientKey]]];
    NSString *headerValue=[NSString stringWithFormat:@"%@,%@",sign,timestamp];
    [request setValue:headerValue forHTTPHeaderField:@"X-AVOSCloud-Request-Sign"];
    
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:kAVDefaultNetworkTimeoutInterval];
    [request setHTTPMethod:method];
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"DELETE"]) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:@"?%@", [self queryStringFromParameters:parameters]]];
        [request setURL:url];
    } else {
        [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
        NSError *error;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
        if (error) {
            SLog(@"%@ error : %@", [self class], error);
        }
    }
    return request;
}

- (void)goRequest:(NSURLRequest *)request block:(AVIdResultBlock)block {
    SLog(@"request url : %@", request.URL);
    SLog(@"request headers : %@", [request allHTTPHeaderFields]);
    SLog(@"request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            block(nil, connectionError);
        } else {
            if (response && data.length > 0) {
                NSError *error;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error) {
                    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    SLog(@"reponse : %@", responseString);
                    block(nil, [AVOSCloudSNSUtils errorWithText:@"HTTP request failed, reponse string: %@", responseString]);
                } else {
                    SLog(@"reponse : %@", dictionary);
                    block(dictionary, nil);
                }
            }
        }
    }];
}

- (NSDictionary *)whereDictionaryFromConditions:(NSDictionary *)conditions {
    NSDictionary *where = [NSDictionary dictionary];
    if (conditions.count>0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:conditions options:0 error:nil];
        NSString *conditionString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        where = @{@"where":conditionString};
    }
    return where;
}

-(void)getObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
           block:(AVIdResultBlock)block {
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:[self whereDictionaryFromConditions:parameters]];
    [self goRequest:request block:block];
}

-(void)postObject:(NSString *)path
   withParameters:(NSDictionary *)parameters
            block:(AVIdResultBlock)block
{
    NSMutableURLRequest *request= [self requestWithMethod:@"POST" path:path parameters:parameters];
    [self goRequest:request block:block];
}

-(void)putObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
           block:(AVIdResultBlock)block {
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    [self goRequest:request block:block];
}

-(void)deleteObject:(NSString *)path
     withParameters:(NSDictionary *)parameters
              block:(AVIdResultBlock)block {
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    [self goRequest:request block:block];
}

@end
