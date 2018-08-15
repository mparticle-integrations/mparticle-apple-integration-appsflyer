//
//  MPKitAppsFlyer.m
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

#import "MPKitAppsFlyer.h"
#if defined(__has_include) && __has_include(<AppsFlyerTracker/AppsFlyerTracker.h>)
#import <AppsFlyerTracker/AppsFlyerTracker.h>
#elif defined(__has_include) && __has_include(<AppsFlyerLib/AppsFlyerTracker.h>)
#import <AppsFlyerLib/AppsFlyerTracker.h>
#else
#import "AppsFlyerTracker.h"
#endif

#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    #import <UserNotifications/UserNotifications.h>
    #import <UserNotifications/UNUserNotificationCenter.h>
#endif

NSString *const MPKitAppsFlyerConversionResultKey = @"mParticle-AppsFlyer Attribution Result";
NSString *const MPKitAppsFlyerAttributionResultKey = @"mParticle-AppsFlyer Attribution Result";
NSString *const MPKitAppsFlyerAppOpenResultKey = @"mParticle-AppsFlyer App Open Result";
NSString *const MPKitAppsFlyerErrorKey = @"mParticle-AppsFlyer Error";
NSString *const MPKitAppsFlyerErrorDomain = @"mParticle-AppsFlyer";

NSString *const afAppleAppId = @"appleAppId";
NSString *const afDevKey = @"devKey";
NSString *const afAppsFlyerIdIntegrationKey = @"appsflyer_id_integration_setting";
NSString *const kMPKAFCustomerUserId = @"af_customer_user_id";

static AppsFlyerTracker *appsFlyerTracker = nil;
static id<AppsFlyerTrackerDelegate> temporaryDelegate = nil;

@interface MPKitAppsFlyer() <AppsFlyerTrackerDelegate>
@end

@implementation MPKitAppsFlyer

@synthesize kitApi = _kitApi;

- (id)providerKitInstance {
    return appsFlyerTracker;
}

+ (void)setDelegate:(id)delegate {
    if (appsFlyerTracker) {
        if (appsFlyerTracker.delegate) {
            NSLog(@"Warning: AppsFlyer delegate can not be set because it is already in use by kit. \
                  If you'd like to set your own delegate, please do so before you initialize mParticle.\
                  Note: When setting your own delegate, you will not be able to use \
                  `onAttributionComplete`.");
            return;
        }
        
        appsFlyerTracker.delegate = (id<AppsFlyerTrackerDelegate>)delegate;
    }
    else {
        temporaryDelegate = (id<AppsFlyerTrackerDelegate>)delegate;
    }
}

+ (NSNumber *)kitCode {
    return @92;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"AppsFlyer" className:@"MPKitAppsFlyer"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    NSString *appleAppId = configuration[afAppleAppId];
    NSString *devKey = configuration[afDevKey];
    if (!appleAppId || !devKey) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }

    appsFlyerTracker = [AppsFlyerTracker sharedTracker];
    appsFlyerTracker.appleAppID = appleAppId;
    appsFlyerTracker.appsFlyerDevKey = devKey;
    if (temporaryDelegate) {
        appsFlyerTracker.delegate = temporaryDelegate;
        temporaryDelegate = nil;
    }
    else {
        appsFlyerTracker.delegate = self;
    }

    _configuration = configuration;
    _started = YES;

    BOOL alreadyActive = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (alreadyActive) {
            [self didBecomeActive];
        }
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });

    NSString *appsFlyerUID = (NSString *) [appsFlyerTracker getAppsFlyerUID];
    if (appsFlyerUID){
        NSDictionary<NSString *, NSString *> *integrationAttributes = @{afAppsFlyerIdIntegrationKey:appsFlyerUID};
        [[MParticle sharedInstance] setIntegrationAttributes:integrationAttributes forKit:[[self class] kitCode]];
    }

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)didBecomeActive {
    [appsFlyerTracker trackAppLaunch];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
    [appsFlyerTracker handleOpenUrl:url options:options];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [appsFlyerTracker handleOpenURL:url sourceApplication:sourceApplication withAnnotation:annotation];
#pragma clang diagnostic pop
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    [appsFlyerTracker continueUserActivity:userActivity restorationHandler:restorationHandler];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)didUpdateUserActivity:(nonnull NSUserActivity *)userActivity {
    [appsFlyerTracker didUpdateUserActivity:userActivity];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)receivedUserNotification:(nonnull NSDictionary *)userInfo {
    [appsFlyerTracker handlePushNotification:userInfo];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (nonnull MPKitExecStatus *)userNotificationCenter:(nonnull UNUserNotificationCenter *)center willPresentNotification:(nonnull UNNotification *)notification {
    [appsFlyerTracker handlePushNotification:notification.request.content.userInfo];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)userNotificationCenter:(nonnull UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response {
    [appsFlyerTracker handlePushNotification:response.notification.request.content.userInfo];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}
#endif

- (nonnull MPKitExecStatus *)setUserIdentity:(nullable NSString *)identityString identityType:(MPUserIdentity)identityType {
    MPKitExecStatus *execStatus;
    if (identityType == MPUserIdentityCustomerId) {
        [appsFlyerTracker setCustomerUserID:identityString];
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    } else if (identityType == MPUserIdentityEmail) {
        if (identityString) {
            [appsFlyerTracker setUserEmails:@[identityString] withCryptType:EmailCryptTypeNone];
        }
        else {
            [appsFlyerTracker setUserEmails:nil withCryptType:EmailCryptTypeNone];
        }
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    } else {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeFail];
    }
    return execStatus;
}

+ (NSString * _Nullable)generateProductIdList:(nullable MPCommerceEvent *)event {
    NSString *csvString = nil;
    if (event != nil) {
        NSArray *products = event.products;
        if (products != nil && products.count > 0) {
            NSMutableArray *productSkuArray = [NSMutableArray array];
            for (int i = 0; i < products.count; i += 1) {
                MPProduct *product = products[i];
                NSString *sku = product.sku;
                if (sku != nil && sku.length > 0) {
                    NSString *skuNoCommas = [sku stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
                    if (skuNoCommas) {
                        [productSkuArray addObject:skuNoCommas];
                    }
                }
            }
            if (productSkuArray.count > 0) {
                NSString *productsString = [productSkuArray componentsJoinedByString:@","];
                if (productsString) {
                    csvString = productsString;
                }
            }
        }
    }
    return csvString;
}

- (nonnull MPKitExecStatus *)logCommerceEvent:(nonnull MPCommerceEvent *)commerceEvent {
    MPKitExecStatus *execStatus;
    
    // If a customer id is available, add it to the commerce event user defined attributes
    FilteredMParticleUser *user = [self currentUser];
    NSString *customerId = [user.userId stringValue];
    if (customerId.length) {
        MPCommerceEvent *surrogateCommerceEvent = [commerceEvent copy];
        surrogateCommerceEvent.userDefinedAttributes[kMPKAFCustomerUserId] = customerId;
        commerceEvent = surrogateCommerceEvent;
    }
    
    MPCommerceEventAction action = commerceEvent.action;

    if (action == MPCommerceEventActionAddToCart ||
        action == MPCommerceEventActionAddToWishList ||
        action == MPCommerceEventActionCheckout ||
        action == MPCommerceEventActionPurchase)
    {
        NSMutableDictionary *values = [NSMutableDictionary dictionary];
        if (commerceEvent.currency) {
            values[AFEventParamCurrency] = commerceEvent.currency;
        }

        NSString *customerUserId = commerceEvent.userDefinedAttributes[kMPKAFCustomerUserId];
        if (customerUserId) {
            values[kMPKAFCustomerUserId] = customerUserId;
        }

        NSString *appsFlyerEventName = nil;
        if (action == MPCommerceEventActionAddToCart || action == MPCommerceEventActionAddToWishList) {
            NSArray<MPProduct *> *products = commerceEvent.products;
            NSMutableDictionary *productValues = nil;
            NSUInteger initialForwardCount = [products count] > 0 ? 0 : 1;
            execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess forwardCount:initialForwardCount];
            appsFlyerEventName = action == MPCommerceEventActionAddToCart ? AFEventAddToCart : AFEventAddToWishlist;

            for (MPProduct *product in products) {
                productValues = [values mutableCopy];
                if (product.price) {
                    productValues[AFEventParamPrice] = product.price;
                }

                if (product.quantity) {
                    productValues[AFEventParamQuantity] = product.quantity;
                }

                if (product.sku) {
                    productValues[AFEventParamContentId] = product.sku;
                }

                if (product.category) {
                    productValues[AFEventParamContentType] = product.category;
                }

                [appsFlyerTracker trackEvent:appsFlyerEventName withValues:productValues ? productValues : values];
                [execStatus incrementForwardCount];
            }
        } else {
            execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
            appsFlyerEventName = action == MPCommerceEventActionCheckout ? AFEventInitiatedCheckout : AFEventPurchase;
            NSNumber *quantity = [MPKitAppsFlyer computeProductQuantity:commerceEvent];
            if (quantity != nil) {
                values[AFEventParamQuantity] = quantity;
            }
            
            NSString *csvString = [MPKitAppsFlyer generateProductIdList:commerceEvent];
            if (csvString != nil) {
                values[AFEventParamContentId] = csvString;
            }

            MPTransactionAttributes *transactionAttributes = commerceEvent.transactionAttributes;
            if (transactionAttributes.revenue.intValue) {
                if (action == MPCommerceEventActionPurchase) {
                    values[AFEventParamRevenue] = transactionAttributes.revenue;
                    if (transactionAttributes.transactionId.length) {
                        values[AFEventParamOrderId] = transactionAttributes.transactionId;
                    }
                } else {
                    values[AFEventParamPrice] = transactionAttributes.revenue;
                }
            }

            [appsFlyerTracker trackEvent:appsFlyerEventName withValues:values];
        }
    }
    else {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess forwardCount:0];
        NSArray *expandedInstructions = [commerceEvent expandedInstructions];
        for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
            [self logEvent:commerceEventInstruction.event];
            [execStatus incrementForwardCount];
        }
    }
    return execStatus;
}

+ (nonnull NSNumber *) computeProductQuantity: (nullable MPCommerceEvent *) event {
    int quantity = 0;
    if ([event.products count] > 0) {
        for (MPProduct *product in event.products) {
            if ([product.quantity intValue] > 0){
                quantity += [product.quantity intValue];
            } else {
                quantity += 1;
            }
        }
    } else {
        quantity = 1;
    }
    return [NSNumber numberWithInt:quantity];
}

- (nonnull MPKitExecStatus *)logEvent:(nonnull MPEvent *)event {
    
    // If a customer id is available, add it to the event attributes
    FilteredMParticleUser *user = [self currentUser];
    NSString *customerId = [user.userId stringValue];
    if (customerId.length) {
        MPEvent *surrogateEvent = [event copy];
        NSMutableDictionary *mutableInfo = [surrogateEvent.info mutableCopy];
        mutableInfo[kMPKAFCustomerUserId] = customerId;
        surrogateEvent.info = mutableInfo;
        event = surrogateEvent;
    }
    
    NSString *eventName = event.name;
    NSDictionary *eventValues = event.info;
    [appsFlyerTracker trackEvent:eventName withValues:eventValues];
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)setOptOut:(BOOL)optOut {
    appsFlyerTracker.deviceTrackingDisabled = optOut;
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppsFlyer) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (NSError *)errorWithMessage:(NSString *)message {
    NSError *error = [NSError errorWithDomain:MPKitAppsFlyerErrorDomain code:0 userInfo:@{MPKitAppsFlyerErrorKey:message}];
    return error;
}

- (void)onConversionDataReceived:(NSDictionary *)installData {
    if (!installData) {
        [_kitApi onAttributionCompleteWithResult:nil error:[self errorWithMessage:@"Received nil installData from AppsFlyer"]];
        return;
    }
    
    NSMutableDictionary *outerDictionary = [NSMutableDictionary dictionary];
    outerDictionary[MPKitAppsFlyerConversionResultKey] = installData;

    MPAttributionResult *attributionResult = [[MPAttributionResult alloc] init];
    attributionResult.linkInfo = outerDictionary;

    [_kitApi onAttributionCompleteWithResult:attributionResult error:nil];
}

- (void)onConversionDataRequestFailure:(NSError *)error {
    [_kitApi onAttributionCompleteWithResult:nil error:error];
}

- (void)onAppOpenAttribution:(NSDictionary *)attributionData {
    if (!attributionData) {
        [_kitApi onAttributionCompleteWithResult:nil error:[self errorWithMessage:@"Received nil attributionData from AppsFlyer"]];
        return;
    }
    
    NSMutableDictionary *outerDictionary = [NSMutableDictionary dictionary];
    outerDictionary[MPKitAppsFlyerAppOpenResultKey] = attributionData;

    MPAttributionResult *attributionResult = [[MPAttributionResult alloc] init];
    attributionResult.linkInfo = outerDictionary;

    [_kitApi onAttributionCompleteWithResult:attributionResult error:nil];
}

- (void)onAppOpenAttributionFailure:(NSError *)error {
    [_kitApi onAttributionCompleteWithResult:nil error:error];
}

- (MPKitAPI *)kitApi {
    if (_kitApi == nil) {
        _kitApi = [[MPKitAPI alloc] init];
    }
    
    return _kitApi;
}

#pragma helper methods

- (FilteredMParticleUser *)currentUser {
    return [[self kitApi] getCurrentUserWithKit:self];
}

@end
