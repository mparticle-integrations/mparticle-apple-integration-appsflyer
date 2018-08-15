//
//  MPKitAppsFlyer.h
//
//  Copyright 2016 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

extern NSString * _Nonnull const MPKitAppsFlyerConversionResultKey;
extern NSString * _Nonnull const MPKitAppsFlyerAppOpenResultKey;
extern NSString * _Nonnull const MPKitAppsFlyerErrorKey;
extern NSString * _Nonnull const MPKitAppsFlyerErrorDomain;

@interface MPKitAppsFlyer : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable) MPKitAPI *kitApi;

+ (void)setDelegate:(id _Nonnull)delegate;
+ (NSNumber * _Nonnull)computeProductQuantity:(nullable MPCommerceEvent *)event;
+ (NSString * _Nullable)generateProductIdList:(nullable MPCommerceEvent *)event;
@end

extern NSString * _Nonnull const MPKitAppsFlyerAttributionResultKey __deprecated_msg("Use MPKitAppsFlyerConversionResultKey instead.");
