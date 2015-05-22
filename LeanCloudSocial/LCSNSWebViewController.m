//
//  AVSNSWebViewController.m
//  AVOS
//
//  Created by Qihe Bian on 11/28/14.
//
//

#import "LCSNSWebViewController.h"
#import "NSURL+AVAdditions.h"

extern NSString * const AVOSCloudSNSErrorDomain;
@interface LCSNSWebViewController ()

@end

@implementation LCSNSWebViewController

- (NSDictionary *)extractParamsFromUrl:(NSURL *)url {
    NSMutableDictionary *params = [[url av_queryDictionary] mutableCopy];
    return params;
}

-(void)dispatchActionWithURL:(NSURL *)url {
    NSDictionary *params = [self extractParamsFromUrl:url];
    NSString *param = [params objectForKey:@"param"];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:NULL];
    [self close];
    if (self.callback) {
        NSString *errorString = [dict objectForKey:@"error"];
        if (errorString) {
            self.callback(nil, [NSError errorWithDomain:AVOSCloudSNSErrorDomain code:5 userInfo:@{@"error":errorString}]);
        } else {
            self.callback(dict, nil);
        }
    }
}

@end
