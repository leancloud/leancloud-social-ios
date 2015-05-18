//
//  SocialNetworkTests.m
//  SocialNetworkTests
//
//  Created by Feng Junwen on 5/14/15.
//  Copyright (c) 2015 LeanCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <AVOSCloud/AVOSCloud.h>
#import "LeanCloudSNS.h"
#import "AVUser+SNS.h"

@interface SocialNetworkTests : XCTestCase

@end

@implementation SocialNetworkTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRenrenAccount {
    // This is an example of a functional test case.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
