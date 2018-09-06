//
//  _03_SourceTests.m
//  203-SourceTests
//
//  Created by 许毓方 on 2018/9/5.
//  Copyright © 2018 SN. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface _03_SourceTests : XCTestCase

@end

@implementation _03_SourceTests

- (void)setUp {
    [super setUp];
    NSArray *arr = @[@2, @3];

    NSUInteger idx = [arr indexOfObject:@"s"];
    if (idx == NSNotFound) {
        NSLog(@"notfound");
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
