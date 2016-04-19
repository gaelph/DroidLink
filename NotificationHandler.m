//
//  NotificationHandler.m
//  DroidLink
//
//  Created by Gaël PHILIPPE on 07/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import "NotificationHandler.h"
#import "NSUserNotification_Private.h"
#import "MessageKeys.h"

@implementation NotificationHandler

#pragma mark -
#pragma mark NotificationCenter

- (void) dismissNotification:(NSDictionary *)notification {
    for (NSUserNotification * deliveredNotification in [notificationCenter deliveredNotifications]) {
        if ([[deliveredNotification identifier] isEqualToString:notification[kMessageIdenKey]]) {
            NSLog(@"Removing notification with iden %@", notification[kMessageIdenKey]);
            [notificationCenter removeDeliveredNotification:deliveredNotification];
            return;
        }
    }
    NSLog(@"Received a dismissal for %@, but no matching notification was found", notification[kMessageIdenKey]);
    return;
}

- (void) deliverNotification:(NSDictionary *)notification {
    if (notificationCenter == nil) {
        notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    }
    
    NSUserNotification * userNotification = [[NSUserNotification alloc] init];
    [userNotification setTitle:notification[kMessageTitleKey]];
    [userNotification setIdentifier:notification[kMessageIdenKey]];
    [userNotification setInformativeText:notification[kMessageTextKey]];
    [userNotification setSubtitle:notification[kMessageAppNameKey]];
    
    if ([notification[kMessageCategoryKey] isEqualToString:@"msg"]) {
        [userNotification setHasReplyButton:YES];
        NSLog(@"%@", notification[kMessagePeopleKey]);
        NSDictionary * userInfo = @{kMessagePeopleKey : notification[kMessagePeopleKey] , kMessagePhoneNumberKey: notification[kMessagePhoneNumberKey]};
        [userNotification setUserInfo:userInfo];
    } else if ([notification[kMessageCategoryKey] isEqualToString:@"call"] || [notification[kMessagePackageNameKey] isEqualToString:@"com.google.android.dialer"]) {
        NSLog(@"Call Notification");
        //[userNotification setHasReplyButton:YES];
        [userNotification setHasActionButton:YES];
        
        [userNotification setOtherButtonTitle:@"Reject"];
        [userNotification setActionButtonTitle:@"Accept"];
    }
    
    NSString * object = notification[@"icon"];
    if (object != nil) {
        NSData * decodedData = [[NSData alloc] initWithBase64EncodedString:notification[@"icon"] options:0];
        NSImage * image = [[NSImage alloc] initWithData:decodedData];
        [userNotification setValue:image forKey:@"_identityImage"];
        [userNotification setValue:@(NO) forKey:@"_identityImageHasBorder"];
    }
    
    NSLog(@"Delivering notification with iden : %@", userNotification.identifier);
    
    [notificationCenter deliverNotification:userNotification];
}


#pragma mark -
#pragma mark NotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
        didDeliverNotification:(NSUserNotification *)notification {
    /* Found here :http://stackoverflow.com/questions/21110714/mac-os-x-nsusernotificationcenter-notification-get-dismiss-event-callback/21365269#21365269 */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       BOOL notificationStillPresent;
                       do {
                           notificationStillPresent = NO;
                           for (NSUserNotification *nox in [[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications]) {
                               if ([nox.identifier isEqualToString:notification.identifier]) notificationStillPresent = YES;
                           }
                           if (notificationStillPresent) [NSThread sleepForTimeInterval:0.20f];
                       } while (notificationStillPresent);
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self userNotificationCenter:center didActivateNotification:notification];
                       });
                   });
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {
    
    if (notification.activationType == NSUserNotificationActivationTypeNone) {
        if ([notification.otherButtonTitle isEqualToString:@"Reject"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REJECT_CALL" object:nil];
        } else {
            
            NSMutableDictionary * message = [[NSMutableDictionary alloc] init];
            message[kMessageTypeKey] = kMessageTypeDismissal;
            message[kMessageIdenKey] = notification.identifier;
            
            NSLog(@"%@", message);
            [[NSNotificationCenter defaultCenter] postNotificationName:kWriteToBTClientNotification object:self userInfo:message];
        }
    }
    
    if (notification.activationType == NSUserNotificationActivationTypeReplied){
        NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
        
        userInfo[kMessageTypeNotification] = notification;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageReplyNotification object:self userInfo:userInfo];
    }
    
    if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
        
        if ([notification.actionButtonTitle isEqualToString:@"Accept"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ACCEPT_CALL" object:nil];
        }
    }
    
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
    return true;
}

@end
