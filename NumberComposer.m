//
//  NumberComposer.m
//  DroidLink
//
//  Created by Gaël PHILIPPE on 07/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import "NumberComposer.h"

#define kValidChars @"1234567890ABCDabcd*#+"

@implementation NCTextField

- (BOOL) acceptsFirstResponder { return YES; };
- (BOOL) canBecomeKeyView { return YES; };

- (void) awakeFromNib {
    [self setDelegate:self];
}

- (NSRange) selectedText {
    return [[_window fieldEditor:YES forObject:self] selectedRange];
}

- (IBAction)addDigit:(id)sender {
    NSButton * button = sender;
    
    NSPoint point = NSMakePoint(0, 0);
    NSEvent * event = [NSEvent keyEventWithType:NSKeyDown location:point modifierFlags:0 timestamp:0 windowNumber:0 context:nil characters:button.title charactersIgnoringModifiers:button.title isARepeat:NO keyCode:0];
    
    [NSApp sendEvent:event];
}

static id eventMonitor = nil;

-(BOOL) becomeFirstResponder {
    BOOL okToChange = [super becomeFirstResponder];
    
    if (okToChange) {
        //[self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
        
        eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent * (NSEvent * event) {
            NSString * characters = event.characters;
            unichar character = '\0';
            if (characters.length > 0) {
                character = [characters characterAtIndex:0];
            }
            NSString * characterString = [NSString stringWithFormat:@"%c", character];
            
            NSArray * validCharacters = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"8",@"9",@"a",@"b",@"c",@"d",@"A",@"B",@"C,",@"D",@"+",@"*",@"#"];
            
            if ([validCharacters containsObject:characterString] || character == NSDeleteCharacter || character == NSRightArrowFunctionKey || character == NSLeftArrowFunctionKey) {
                NSEvent * upperEvent = [NSEvent keyEventWithType:event.type location:event.locationInWindow modifierFlags:event.modifierFlags timestamp:event.timestamp windowNumber:event.windowNumber context:event.context characters:event.characters.uppercaseString charactersIgnoringModifiers:event.charactersIgnoringModifiers.uppercaseString isARepeat:event.isARepeat keyCode:event.keyCode];
                
                event = upperEvent;
                
                if ([validCharacters containsObject:characterString]) {
                    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:event.characters.uppercaseString forKey:@"character"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyPress" object:self userInfo:userInfo];
                }
                
            } else {
                event = nil;
            }
            
            return event;
        }];
    }
    
    return okToChange;
}

- (void) textDidEndEditing:(NSNotification *)notification {
    [NSEvent removeMonitor:eventMonitor];
    eventMonitor = nil;
    
    self.stringValue = ((NSTextView *)[notification object]).string;
}


@end
