//
//  NotificationMirroringState.m
//  DroidLink
//
//  Created by Gaël PHILIPPE on 10/02/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import "DroidLinkDaemonsProxy.h"
#import "MessageKeys.h"
#import "BTNLdistributedNotifications.h"
#import "LogUtils.h"

#ifdef TAG
#undef TAG
#endif

#define TAG "DroidLinkProxy"

@implementation DroidLinkDaemonsProxy

@synthesize notificationMirrorConnected;
@synthesize handsfreeConnected;

@synthesize phoneName;
@synthesize callPhoneNumber;
@synthesize callActive;

@synthesize delegate;

#pragma mark -
#pragma mark Notification Mirroring

- (void) closeNotificationListenerService {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kBTNLConnectionCloseBoth object:nil userInfo:nil deliverImmediately:YES];
}

- (void) startNotificationListenerService {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kBTNLConnectionStartBoth object:nil userInfo:nil deliverImmediately:YES];
}

- (void) onChannelOpenedNotification:(NSNotification *)aNotification {
    LOG(@"Received Channel Opened Notification")
    [self setNotificationMirrorConnected:YES];
}

- (void) onChannelClosedNotification:(NSNotification *)aNotification {
    LOG(@"Received Channel Closed Notification")
    [self setNotificationMirrorConnected:NO];
}

- (void) onReceiveConnectionStates:(NSNotification *)aNotification {
    LOG(@"Received Connection Status Notification")
    BOOL connected = NO;
    NSDictionary * statuses = [aNotification userInfo];
    
    for (NSString * key in statuses) {
        if ([statuses[key] boolValue]) connected = YES;
    }
    
    LOG(@"Connection status is %@", connected?@"connected":@"disconnected")
    [self setNotificationMirrorConnected:connected];
    
}

- (void) onMessageReceived:(NSNotification *) aNotification {
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(messageReceived:)]) {
            [delegate messageReceived:[aNotification userInfo][kMessageMessageKey]];
        }
    }
}

- (void) registerToNotificationMirroringNotifications {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelOpenedNotification:) name:kBTNLConnectionRFCOMMChannelOpened object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelClosedNotification:) name:kBTNLConnectionRFCOMMChannelClosed object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReceived:) name:kBTNLConnectionMessageReceivedNotification object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveConnectionStates:) name:kBTNLConnectionBroadcastState object:nil];
    
}

- (void) queryNotificationMirroringState {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kBTNLConnectionQueryState object:nil userInfo:nil deliverImmediately:YES];
}

#pragma mark -
#pragma mark HandsFree Proxy

- (void) connectHandsfree {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDLHFConnect object:nil userInfo:nil deliverImmediately:YES];
    
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(onHandsfreeConnected)]) {
            [delegate onHandsfreeConnected];
        }
    }
}

- (void) disconnectHandsfree {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDLHFDisconnect object:nil userInfo:nil deliverImmediately:YES];
    
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(onHandsfreeDisconnected)]) {
            [delegate onHandsfreeDisconnected];
        }
    }
}

- (void) dial:(NSString *)number {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDLHFDial object:@"com.lebidou.handsfree" userInfo:@{@"number" : number} deliverImmediately:YES];
    
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(callStarted)]) {
            [delegate callStarted];
        }
    }
}

- (void) hangUp {
    [self setCallActive:NO];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDLHFHangUp object:nil userInfo:nil deliverImmediately:YES];
    
    if (delegate != nil) {
        if ([delegate respondsToSelector:@selector(callEnded)]) {
            [delegate callEnded];
        }
    }
}

- (void) acceptCall {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDLHFAcceptCall object:nil userInfo:nil deliverImmediately:YES];
}

- (void) keyPress:(NSString *)key {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDLHFKeyPress object:nil userInfo:@{@"key" : key} deliverImmediately:YES];
}

- (void) onAccept:(NSNotification *) aNotification {
    [self acceptCall];
}

- (void) onReject:(NSNotification *) aNotification {
    [self hangUp];
}

- (void) onHandsfreeChangedNotification:(NSNotification *)aNotification {
    LOG(@"Received Handsfree Connection Status Notification")
    BOOL connected = NO;
    NSDictionary * statuses = [aNotification userInfo];
    
    for (NSString * key in statuses) {
        [self setPhoneName:key];
        if ([statuses[key] boolValue]) connected = YES;
    }
    
    LOG(@"Handsfree Connection status is %@", connected?@"connected":@"disconnected")
    [self setHandsfreeConnected:connected];
    
    if (connected) {
        if (delegate != nil) {
            if ([delegate respondsToSelector:@selector(onHandsfreeConnected)]) {
                [delegate onHandsfreeConnected];
            }
        }
    } else {
        if (delegate != nil) {
            if ([delegate respondsToSelector:@selector(onHandsfreeDisconnected)]) {
                [delegate onHandsfreeDisconnected];
            }
        }
    }
}

- (void) onCallInfo:(NSNotification *)aNotification  {
    NSDictionary * info = aNotification.userInfo;
    
    [self setPhoneName:info[@"phone_name"]];
    
    if (((int)info[@"call_setup"]) != 1) {
        [self setCallPhoneNumber:info[@"callee"]];
    } else {
        [self setCallPhoneNumber:info[@"caller"]];
        
        if (delegate != nil) {
            if ([delegate respondsToSelector:@selector(callStarted)]) {
                [delegate callStarted];
            }
        }
        
    }
    
    [self setCallActive:(BOOL)info[@"call_active"]];
    
}

- (void) onKeyPress:(NSNotification *) notification {
    NSString * character = [notification.userInfo valueForKey:@"character"];
    
    [[NSDistributedNotificationCenter defaultCenter]postNotificationName:kDLHFKeyPress object:nil userInfo:@{@"key" : character} deliverImmediately:true];
}

- (void) onDevicesFound:(NSNotification *) notification {
    NSDictionary * info = notification.userInfo;
    
    for (NSString * name in info) {
        [self setPhoneName:name];
    }
}

- (void) registerToHandsfreeNotifications {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onHandsfreeChangedNotification:) name:kDLHFConnectionBroadcastState object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallInfo:) name:kDLHFCallInfo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyPress:) name:@"KeyPress" object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(onDevicesFound:) name:kDLHFDevicesFound object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReject:) name:@"REJECT_CALL" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAccept:) name:@"ACCEPT_CALL" object:nil];
}

- (void) queryHandsfreeConnectionState {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDLHFConnectionQueryState object:nil userInfo:nil deliverImmediately:YES];
}

@end
