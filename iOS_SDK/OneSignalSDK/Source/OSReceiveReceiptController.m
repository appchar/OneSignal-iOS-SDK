/**
 * Modified MIT License
 *
 * Copyright 2017 OneSignal
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * 1. The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * 2. All copies of substantial portions of the Software may only be used in connection
 * with services provided by OneSignal.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "OSReceiveReceiptController.h"
#import "Requests.h"
#import "OneSignalClient.h"
#import "OSSubscription.h"
#import "OneSignalCommonDefines.h"
#import "OneSignalUserDefaults.h"

@implementation OSReceiveReceiptController

- (instancetype)init
{
    self = [super init];
    return self;
}

- (void)sendReceiveReceiptCachedWithNotification:(NSString *)notificationId {
    NSUserDefaults *userDefaultsShared = [OneSignalSharedUserDefaults getSharedUserDefault];
    let currentSubscriptionState = [[OSSubscriptionState alloc] initAsFrom];
    let playerId = [currentSubscriptionState userId];
    let appId = [userDefaultsShared stringForKey:NSUD_APP_ID];

    [self sendReceiveReceiptWithPlayerId:playerId notificationId:notificationId appId:appId];
}

- (void)sendReceiveReceiptWithPlayerId:(NSString *)playerId notificationId:(NSString *)notificationId appId:(NSString *)appId {
    [self sendReceiveReceiptWithPlayerId:playerId notificationId:notificationId appId:appId successBlock:nil failureBlock:nil];
}

- (void)sendReceiveReceiptWithPlayerId:(nonnull NSString *)playerId
                        notificationId:(nonnull NSString *)notificationId
                                 appId:(nonnull NSString *)appId
                          successBlock:(nullable OSResultSuccessBlock)success
                          failureBlock:(nullable OSFailureBlock)failure {
    let message = [NSString stringWithFormat:@"OneSignal sendReceiveReceiptWithPlayerId playerId:%@ notificationId: %@, appId: %@", playerId, notificationId, appId];
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:message];

    if (![self checkReceiveReceiptsStatus]) {
        [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"sendReceiveReceiptWithPlayerId disabled"];
        return;
    }
    OSRequestReceiveReceipts *request = [OSRequestReceiveReceipts withPlayerId:playerId notificationId:notificationId appId:appId];
    
    [OneSignalClient.sharedClient executeRequest:request onSuccess:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } onFailure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (BOOL)checkReceiveReceiptsStatus {    
    return [OneSignalSharedUserDefaults getSavedBool:ONESIGNAL_ENABLE_RECEIVE_RECEIPTS defaultValue:NO];
}

@end
