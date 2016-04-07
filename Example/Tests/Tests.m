//
//  DZAuthSessionTests.m
//  DZAuthSessionTests
//
//  Created by stonedong on 04/04/2016.
//  Copyright (c) 2016 stonedong. All rights reserved.
//
#import "DZAuthSession.h"
@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTAssert(DZShareAuthSessionManager, @"Get Shared Auth Session Manager");
}

@end

