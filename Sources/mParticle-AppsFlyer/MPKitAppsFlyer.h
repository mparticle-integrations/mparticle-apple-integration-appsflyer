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
