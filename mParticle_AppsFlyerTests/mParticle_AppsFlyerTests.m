//
//  mParticle_AppsFlyerTests.m
//  mParticle_AppsFlyerTests
//
//  Created by Sam Dozor on 1/30/18.
//  Copyright © 2018 mParticle. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "mParticle_AppsFlyer.h"
@interface mParticle_AppsFlyerTests : XCTestCase

@end

@implementation mParticle_AppsFlyerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testComputeQuantityWithNoEvent {
    XCTAssertEqual(1, [[MPKitAppsFlyer computeProductQuantity:nil] intValue]);
}
- (void)testComputeQuantityWithNoProducts {
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    XCTAssertEqual(1, [[MPKitAppsFlyer computeProductQuantity:event] intValue]);
}

- (void)testComputeQuantityWithProductWithNoQuantity {
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    MPProduct *product = [[MPProduct alloc] initWithName:@"foo" sku:@"bar" quantity:@0 price:@50];
    [event addProduct:product];
    XCTAssertEqual(1, [[MPKitAppsFlyer computeProductQuantity:event] intValue]);
}

- (void)testComputeQuantityWithProductWithMultipleQuantities {
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    MPProduct *product = [[MPProduct alloc] initWithName:@"foo" sku:@"bar" quantity:@3 price:@50];
    MPProduct *product2 = [[MPProduct alloc] initWithName:@"foo2" sku:@"bar2" quantity:@2 price:@50];
    [event addProduct:product];
    [event addProduct:product2];
    XCTAssertEqual(5, [[MPKitAppsFlyer computeProductQuantity:event] intValue]);
}

- (void)testGenerateSkuStringNoEvent {
    MPCommerceEvent *event = nil;
    XCTAssertNil([MPKitAppsFlyer generateProductIdList:event]);
}

- (void)testGenerateSkuStringNoProducts {
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    XCTAssertNil([MPKitAppsFlyer generateProductIdList:event]);
}

- (void)testGenerateSkuStringSingleProduct {
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    MPProduct *product = [[MPProduct alloc] initWithName:@"foo" sku:@"foo-sku" quantity:@3 price:@50];
    [event addProduct:product];
    XCTAssertEqualObjects(@"foo-sku",[MPKitAppsFlyer generateProductIdList:event]);
}

- (void)testGenerateSkuStringMultipleProducts {
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    MPProduct *product = [[MPProduct alloc] initWithName:@"foo" sku:@"foo-sku" quantity:@3 price:@50];
    MPProduct *product2 = [[MPProduct alloc] initWithName:@"foo2" sku:@"foo-sku-2" quantity:@2 price:@50];
    [event addProduct:product];
    [event addProduct:product2];
    XCTAssertEqualObjects(@"foo-sku,foo-sku-2",[MPKitAppsFlyer generateProductIdList:event]);
}

- (void)testGenerateSkuStringEmbeddedCommas {
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase];
    MPProduct *product = [[MPProduct alloc] initWithName:@"foo" sku:@"foo-sku" quantity:@3 price:@50];
    MPProduct *product2 = [[MPProduct alloc] initWithName:@"foo2" sku:@"foo-sku-2" quantity:@2 price:@50];
    MPProduct *product3 = [[MPProduct alloc] initWithName:@"foo3" sku:@"foo-sku-,3" quantity:@2 price:@50];
    [event addProduct:product];
    [event addProduct:product2];
    [event addProduct:product3];
    XCTAssertEqualObjects(@"foo-sku,foo-sku-2,foo-sku-%2C3",[MPKitAppsFlyer generateProductIdList:event]);
}

@end
