//
//  NumberComposer.h
//  DroidLink
//
//  Created by Gaël PHILIPPE on 07/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NCTextField : NSTextField<NSTextFieldDelegate> {
    
}

- (BOOL) acceptsFirstResponder;

- (IBAction)addDigit:(id)sender;


@end
