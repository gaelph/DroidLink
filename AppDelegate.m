//
//  AppDelegate.m
//  DroidLink
//
//  Created by Gaël PHILIPPE on 02/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import <IOBluetooth/Bluetooth.h>
#import "AppDelegate.h"
#import "LogUtils.h"

#ifdef TAG
#undef TAG
#endif

#define TAG "DroidLink"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end


@implementation AppDelegate
@synthesize daemonsProxy;
//@synthesize serialPort;
@synthesize numberTextField;
@synthesize phoneToContactTransformer;
#pragma mark -
#pragma mark NotificationHandler Relations

- (NSData *) JSONDataWithDictionary:(NSDictionary *) dictionary {
    NSError * err;
    
    NSData * returnData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    
    return returnData;
}


- (void) sendDismissalForNotificationKey:(NSString *)key {
    NSMutableDictionary * message = [[NSMutableDictionary alloc] init];
    message[kMessageTypeKey] = kMessageTypeDismissal;
    message[kMessageIdenKey] = key;
    
    NSLog(@"%@", message);
    
    NSDictionary * userInfo = @{kMessageMessageKey : [self JSONDataWithDictionary:message]};
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kBTNLConnectionMessageToSendNotification object:nil userInfo:userInfo deliverImmediately:YES];
}

- (void) onNotificationHandlerNotification:(NSNotification *) notification {
    
    if ([notification.name isEqualToString:kWriteToBTClientNotification]) {
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kBTNLConnectionMessageToSendNotification object:nil userInfo:notification.userInfo deliverImmediately:YES];
    }
    
    if ([notification.name isEqualToString:kMessageReplyNotification]) {
        NSUserNotification * userNotification = notification.userInfo[@"notification"];
        NSString * userResponse = userNotification.response.string;
        NSMutableDictionary * message = [[NSMutableDictionary alloc] init];
        
        message[kMessageTypeKey] = kMessageTypeMsgReply;
        message[kMessageIdenKey] = userNotification.identifier;
        message[kMessageMessageKey] = userResponse;
        
        if (userNotification.userInfo[kMessagePeopleKey] != nil)
            message[kMessagePeopleKey] = userNotification.userInfo[kMessagePeopleKey];
        if (userNotification.userInfo[kMessagePhoneNumberKey] != nil)
            message[kMessagePhoneNumberKey] = userNotification.userInfo[kMessagePhoneNumberKey];
        
        NSLog(@"%@", message);
        
        //NSDictionary * userInfo = [NSDictionary dictionaryWithObject:[self JSONDataWithDictionary:message] forKey:kMessageMessageKey];
        NSDictionary * userInfo = @{kMessageMessageKey : [self JSONDataWithDictionary:message]};
        
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kBTNLConnectionMessageToSendNotification object:nil userInfo:userInfo deliverImmediately:YES];
        
        [self sendDismissalForNotificationKey:userNotification.identifier];
    }
    
}

- (void) messageReceived:(NSData *) data {
    
    NSError * err;
    
    NSLog(@"Received message of %li bytes", [data length]);
    
    NSDictionary * notification = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    if (err.code != 0) {
        NSLog(@"Error parsing JSON : %li", (long)err.code);
        NSLog(@"%@ | %@", err.localizedDescription, err.localizedFailureReason);
    }
    
    NSString * type = notification[kMessageTypeKey];
    
    if ([type isEqualToString:@"notification"]) {
        [notificationHandler deliverNotification:notification];
        
    } else if ([type isEqualToString:kMessageTypeDismissal]) {
        [notificationHandler dismissNotification:notification];
        
    } 
}

//TODO: Move this to a dedicated XPC Service ?
#pragma mark -
#pragma mark handsfree

- (void) callStarted {
    [[self dialHangUpButton] setTitle:@"Hang Up"];
    [[self dialHangUpButton] setAction:@selector(hangUp:)];
    
    //[callingWindowController showWindow:[self callingWindow]];
}

- (void) callEnded {
    [[self dialHangUpButton] setTitle:@"Call"];
    [[self dialHangUpButton] setAction:@selector(dialNumber:)];
    
    //[callingWindowController close];
}

- (void) onHandsfreeConnected {
    [[self connectButton] setTitle:@"Disconnect"];
}

- (void) onHandsfreeDisconnected {
    [[self connectButton] setTitle:@"Connect"];
}

- (IBAction)dialNumber:(id)sender {
    AppDelegate * appDelegate = [NSApp delegate];
    NSString * numberString = [[appDelegate numberTextField] stringValue];
    
    [daemonsProxy dial:numberString];
}

- (IBAction)acceptCall:(id)sender {
    [daemonsProxy acceptCall];
}

- (IBAction)hangUp:(id)sender {
    //AppDelegate * appDelegate = [NSApp delegate];
    
    [daemonsProxy hangUp];
}

- (IBAction) switchConnection:(id)sender {
    //NSButton * button = sender;
    BOOL state = [daemonsProxy handsfreeConnected];
    
    switch (state) {
        case YES:
            [daemonsProxy disconnectHandsfree];
            //[daemonsProxy closeNotificationListenerService];
            break;
            
        case NO:
        default:
            [daemonsProxy connectHandsfree];
            //[daemonsProxy startNotificationListenerService];
            break;
    }
}

#pragma mark -
#pragma mark App funcs

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    if (notificationHandler == nil) notificationHandler = [[NotificationHandler alloc] init];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:notificationHandler];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationHandlerNotification:) name:nil object:notificationHandler];
    
    
    /*NSArray * apps = [[NSWorkspace sharedWorkspace] runningApplications];
    BOOL shouldLaunch = YES;
    
    for (NSRunningApplication * app in apps) {
        if ([[app bundleIdentifier] isEqualToString:@"com.bidou.dlnotificationmirroringd"]) {
            LOG(@"Deamon is Running")
            shouldLaunch = NO;
        }
    }
    
    if (shouldLaunch) {
        NSString * pathToDeamon = [[NSBundle mainBundle] pathForResource:@"dlnotificationmirroringd" ofType:@"app"];
        [[NSWorkspace sharedWorkspace] launchApplication:pathToDeamon];
    }*/
    
    if (daemonsProxy == nil) daemonsProxy = [[DroidLinkDaemonsProxy alloc] init];
    [daemonsProxy setDelegate:self];
    [daemonsProxy setNotificationMirrorConnected:NO];
    [daemonsProxy setHandsfreeConnected:NO];
    [daemonsProxy registerToNotificationMirroringNotifications];
    [daemonsProxy registerToHandsfreeNotifications];
    [daemonsProxy queryNotificationMirroringState];
    [daemonsProxy queryHandsfreeConnectionState];
    
    
    [daemonsProxy addObserver:self forKeyPath:@"phoneName" options:NSKeyValueObservingOptionNew context:nil];
    
    callingWindowController = [[NSWindowController alloc] initWithWindow:[self callingWindow]];
    
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (object == daemonsProxy) {
        
        if ([keyPath isEqualToString:@"phoneName"]) {
                
            if (![[[self devicesController] arrangedObjects] containsObject:[daemonsProxy phoneName]]) {
                if (daemonsProxy.phoneName != nil)
                    [[self devicesController] addObject:[daemonsProxy phoneName]];
            }
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    //[self.serialPort close];
}
@end
