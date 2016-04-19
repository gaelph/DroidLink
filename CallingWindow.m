//
//  CallingWindow.m
//  DroidLink
//
//  Created by Gaël PHILIPPE on 09/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import "CallingWindow.h"

#define WINDOW_FRAME_PADDING 75

@implementation CallingWindow

- (id) initWithContentRect:(NSRect)contentRect
                           styleMask:(NSUInteger) windowStyle
                             backing:(NSBackingStoreType) bufferingType
                               defer:(BOOL)deferCreation
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation];
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
    }
    
    return self;
}

- (NSRect)contentRectForFrameRect:(NSRect)windowFrame
{
    windowFrame.origin = NSZeroPoint;
    return NSInsetRect(
                       windowFrame, WINDOW_FRAME_PADDING, WINDOW_FRAME_PADDING);
}

+ (NSRect)frameRectForContentRect:(NSRect)windowContentRect
                        styleMask:(NSUInteger)windowStyle
{
    return NSInsetRect(
                       windowContentRect, -WINDOW_FRAME_PADDING, -WINDOW_FRAME_PADDING);
}

- (void)setContentView:(NSView *)aView
{
    if ([childContentView isEqualTo:aView])
    {
        return;
    }
    
    NSRect bounds = [self frame];
    bounds.origin = NSZeroPoint;
    
    NSView *frameView = [super contentView];
    if (!frameView)
    {
        frameView =
        [[NSView alloc]
          initWithFrame:bounds]
         ;
        
        [super setContentView:frameView];
    }
    
    if (childContentView)
    {
        [childContentView removeFromSuperview];
    }
    childContentView = aView;
    [childContentView setFrame:[self contentRectForFrameRect:bounds]];
    [childContentView
     setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [frameView addSubview:childContentView];
}

@end
