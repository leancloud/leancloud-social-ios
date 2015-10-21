//
//  LeanCloudSocialTests.m
//  LeanCloudSocialTests
//
//  Created by lzw on 15/10/20.
//  Copyright © 2015年 LeanCloud. All rights reserved.
//


#import "AVSNSTestCase.h"

@interface AVUserSNSTest : AVSNSTestCase

@end

@implementation AVUserSNSTest

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

@end


