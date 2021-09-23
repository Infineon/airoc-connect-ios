/*
 * (c) 2014-2020, Cypress Semiconductor Corporation or a subsidiary of 
 * Cypress Semiconductor Corporation.  All rights reserved.
 * 
 * This software, including source code, documentation and related 
 * materials ("Software"),  is owned by Cypress Semiconductor Corporation 
 * or one of its subsidiaries ("Cypress") and is protected by and subject to 
 * worldwide patent protection (United States and foreign), 
 * United States copyright laws and international treaty provisions.  
 * Therefore, you may use this Software only as provided in the license 
 * agreement accompanying the software package from which you 
 * obtained this Software ("EULA").
 * If no EULA applies, Cypress hereby grants you a personal, non-exclusive, 
 * non-transferable license to copy, modify, and compile the Software 
 * source code solely for use in connection with Cypress's 
 * integrated circuit products.  Any reproduction, modification, translation, 
 * compilation, or representation of this Software except as specified 
 * above is prohibited without the express written permission of Cypress.
 * 
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND, 
 * EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress 
 * reserves the right to make changes to the Software without notice. Cypress 
 * does not assume any liability arising out of the application or use of the 
 * Software or any product or circuit described in the Software. Cypress does 
 * not authorize its products for use in any products where a malfunction or 
 * failure of the Cypress product may reasonably be expected to result in 
 * significant property damage, injury or death ("High Risk Product"). By 
 * including Cypress's product in a High Risk Product, the manufacturer 
 * of such system or application assumes all risk of such use and in doing 
 * so agrees to indemnify Cypress against all liability.
 */

#import <UIKit/UIKit.h>
#import "UNUserNotificationCenter+Additions.h"
#import "Constants.h"

#define NOTIFICATION_REQUEST_ID     @"Local notification"

@interface UNUserNotificationCenter (Delegate) <UNUserNotificationCenterDelegate>
@end

@implementation UNUserNotificationCenter (Additions)

- (void)requestNotificationAuthorization {
    self.delegate = self;
    [self requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            NSLog(@"[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:] failed with error: %@", error);
        } else if (!granted) {
            NSLog(@"[UNUserNotificationCenter requestAuthorizationWithOptions:completionHandler:] not granted");
        }
    }];
}

- (void)cleanUp {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)notifyWithContentBody:(NSString *)body {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.body = body;
    content.sound = [UNNotificationSound defaultSound];
    content.badge = [NSNumber numberWithInteger:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
    
    // Deliver the notification in five seconds.
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:5.f
                                                  repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:NOTIFICATION_REQUEST_ID
                                                                          content:content
                                                                          trigger:trigger];
    // Schedule localNotification
    [self addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"[UNUserNotificationCenter addNotificationRequest:withCompletionHandler:] failed with error: %@", error);
        }
    }];
}

#pragma mark - UNUserNotificationCenterDelegate

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    if ([NOTIFICATION_REQUEST_ID isEqualToString:response.notification.request.identifier]) {
        if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {

        } else if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {

        } else {

        }
    }
    completionHandler();
}

// The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification {
}

@end
