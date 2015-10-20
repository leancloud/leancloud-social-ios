//
//  LeanCloudSocialTests.m
//  LeanCloudSocialTests
//
//  Created by lzw on 15/10/20.
//  Copyright © 2015年 LeanCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <LeanCloudSocial/AVOSCloudSNS.h>
#import <AVOSCloud/AVOSCloud.h>
#import <Expecta/Expecta.h>

const void *AVOSCloudSNSNotifation = &AVOSCloudSNSNotifation;

#define WAIT [self waitNotification:AVOSCloudSNSNotifation];
#define NOTIFY [self postNotification:AVOSCloudSNSNotifation];

@interface SocialTest : XCTestCase

@end

@implementation SocialTest

- (void)waitNotification:(const void *)notification {
    NSString *name = [NSString stringWithFormat:@"%p", notification];
    [self expectationForNotification:name object:nil handler:nil];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)postNotification:(const void *)notification {
    NSString *name = [NSString stringWithFormat:@"%p", notification];
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

+ (void)setUp {
    [super setUp];
    NSString *appId = @"2jjvnj3938p6pns11r41dlte2n98bm6m7bkblm1cysttm7in";
    NSString *appKey = @"7dtvdetcfggpalwtf91pdoootc7csxx0vxyi3ayqtbnlklq2";
    [AVOSCloud setApplicationId:appId clientKey:appKey];
}

- (void)setUp {
    
}

- (void)tearDown {
    
}

- (void)testWeiboLogin {
    NSDictionary *authData = @{@"access_token": @"2.00_hkjqBJKf8mCe3c8acf73as6LRxC", @"id":@"1695406573", @"expires_at": @"2015-10-27T18:59:46.676Z", @"platform": @1};
    [AVUser loginWithAuthData:authData platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
        expect(error).to.beNil();
        expect(user).notTo.beNil();
        NOTIFY
    }];
    WAIT
}

@end


