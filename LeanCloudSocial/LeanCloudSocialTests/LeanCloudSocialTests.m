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

+ (void)setUp {
    [super setUp];
    NSString *appId = @"2jjvnj3938p6pns11r41dlte2n98bm6m7bkblm1cysttm7in";
    NSString *appKey = @"7dtvdetcfggpalwtf91pdoootc7csxx0vxyi3ayqtbnlklq2";
    [AVOSCloud setApplicationId:appId clientKey:appKey];
    [AVOSCloud setAllLogsEnabled:YES];
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
        expect(user.objectId).equal(@"55b8a95000b066e34529739d");
        NOTIFY
    }];
    WAIT
}

- (void)testAddOrDeleteAuthData {
    AVUser *user = [self registerOrLoginWithUsername:NSStringFromSelector(_cmd) password:@"123456"];
    NSDictionary *authData = @{@"access_token":@"OezXcEiiBSKSxW0eoylIeN_WWsgxroiydYCNnIX5hyDjK3CwA1hc2bvS1oaaaYqwk8o-2bKJz2qlhCTl5MJBIw70tud0svhSApBGYTXjV5CNzUbvZUoIlo10kJg81IGht1bzyQ4-rVHJ3x4baiYz-g", @"expires_in":@(3600), @"openid":@"oazTlwQwmWLyzz7wxnAXDsSZUjcM"};
    [user addAuthData:authData platform:AVOSCloudSNSPlatformWeiXin block:^(AVUser *user, NSError *error) {
        expect(error).to.beNil();
        expect(user).notTo.beNil();
        expect(user[@"authData"][@"weixin"]).beSupersetOf(authData);
        
        [user deleteAuthDataForPlatform:AVOSCloudSNSPlatformWeiXin block:^(AVUser *user, NSError *error) {
            expect(error).to.beNil();
            expect(user).notTo.beNil();
            expect(user[@"authData"][@"weixin"]).beNil();
            NOTIFY
        }];
    }];
    WAIT
}

#pragma mark - Utils

- (void)waitNotification:(const void *)notification {
    NSString *name = [NSString stringWithFormat:@"%p", notification];
    [self expectationForNotification:name object:nil handler:nil];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)postNotification:(const void *)notification {
    NSString *name = [NSString stringWithFormat:@"%p", notification];
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

- (AVUser *)registerOrLoginWithUsername:(NSString *)username password:(NSString *)password {
    AVUser *user = [AVUser user];
    user.username = username;
    user.password = password;
    NSError *error;
    [user signUp:&error];
    if (!error) {
        return user;
    } else if (error.code == kAVErrorUsernameTaken){
        NSError *loginError;
        AVUser *loginUser = [AVUser logInWithUsername:username password:password error:&loginError];
        XCTAssertNil(loginError);
        return loginUser;
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"can not sign up or login"];
        return nil;
    }
}


@end


