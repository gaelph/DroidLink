//
//  NotificationMirroringState.h
//  DroidLink
//
//  Created by Gaël PHILIPPE on 10/02/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>



@protocol DroidLinkListener <NSObject>

- (void) messageReceived:(NSData *) data;
- (void) callStarted;
- (void) callEnded;

- (void) onHandsfreeConnected;
- (void) onHandsfreeDisconnected;

@end




@interface DroidLinkDaemonsProxy : NSObject

@property BOOL notificationMirrorConnected;
@property BOOL handsfreeConnected;

@property NSString * phoneName;
@property NSString * callPhoneNumber;
@property BOOL callActive;


@property id delegate;



- (void) closeNotificationListenerService;
- (void) startNotificationListenerService;
- (void) onChannelOpenedNotification:(NSNotification *)aNotification;
- (void) onChannelClosedNotification:(NSNotification *)aNotification;
- (void) onReceiveConnectionStates:(NSNotification *)aNotification;
- (void) registerToNotificationMirroringNotifications;
- (void) queryNotificationMirroringState;


- (void) connectHandsfree;
- (void) disconnectHandsfree;
- (void) dial:(NSString *) number;
- (void) hangUp;
- (void) acceptCall;
- (void) rejectCall;
- (void) keyPress:(NSString *)key;

- (void) onHandsfreeChangedNotification:(NSNotification *)aNotification;
- (void) onCallInfo:(NSNotification *)aNotification;
- (void) registerToHandsfreeNotifications;
- (void) queryHandsfreeConnectionState;


@end
