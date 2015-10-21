//
//  AVOSCloudSNSTest.m
//  LeanCloudSocial
//
//  Created by lzw on 15/10/21.
//  Copyright © 2015年 LeanCloud. All rights reserved.
//

#import "AVSNSTestCase.h"

@interface AVOSCloudSNS(Test)

+(NSMutableDictionary*)ssoConfigs;

@end

@interface AVOSCloudSNSTest : AVSNSTestCase

@end

@implementation AVOSCloudSNSTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetupPlatform {
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"2548122881" andAppSecret:@"ba37a6eb3018590b0d75da733c4998f8" andRedirectURI:@"http://wanpaiapp.com/oauth/callback/sina"];
    expect([AVOSCloudSNS ssoConfigs]).notTo.beNil();
    expect([AVOSCloudSNS ssoConfigs][@(AVOSCloudSNSSinaWeibo)][@"appkey"]).to.equal(@"2548122881");
}

- (void)testIsAppInstalledForType {
    for (AVOSCloudSNSType type = AVOSCloudSNSSinaWeibo; type <= AVOSCloudSNSWeiXin; type ++) {
        BOOL installed = [AVOSCloudSNS isAppInstalledForType:type];
        expect(installed).to.beFalsy;
    }
}

@end
