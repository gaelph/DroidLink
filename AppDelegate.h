//
//  AppDelegate.h
//  DroidLink
//
//  Created by Gaël PHILIPPE on 02/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

#import "NotificationHandler.h"
#import "DroidLinkDaemonsProxy.h"

#import "BTNLdistributedNotifications.h"

#import "NumberComposer.h"

#import "CallingWindow.h"

#import "MessageKeys.h"

#import "PhoneToContactTransformer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, DroidLinkListener>
{
    NSUserNotificationCenter * notificationCenter;
    NotificationHandler * notificationHandler;
    
    NSWindowController * callingWindowController;
}

@property IBOutlet DroidLinkDaemonsProxy * daemonsProxy;
//@property IBOutlet BTSerialPort * serialPort;

@property IBOutlet NCTextField * numberTextField;
@property IBOutlet NSButton * connectButton;

@property IBOutlet NSArray * devices;
@property IBOutlet NSArrayController * devicesController;

@property IBOutlet CallingWindow * callingWindow;

@property IBOutlet NSButton * dialHangUpButton;

@property IBOutlet PhoneToContactTransformer * phoneToContactTransformer;

- (void)messageReceived:(NSData *)message;
 
@end

