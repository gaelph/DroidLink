//
//  NotificationHandler.h
//  DroidLink
//
//  Created by Gaël PHILIPPE on 07/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#define kWriteToBTClientNotification @"WriteToBTClient"
#define kMessageReplyNotification @"MessageReply"

@interface NotificationHandler : NSObject<NSUserNotificationCenterDelegate> {
    NSMutableArray * deliveredNotificationsIdentifiers;
    
    NSUserNotificationCenter * notificationCenter;
}

- (void) deliverNotification:(NSDictionary *)notification;
- (void) dismissNotification:(NSDictionary *)notification;

#pragma mark -
#pragma mark NotificationCenterDelegate

- (void) userNotificationCenter:(NSUserNotificationCenter *)center
        didDeliverNotification:(NSUserNotification *)notification;

- (void) userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification;

- (BOOL) userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification;

@end
