//
//  LogUtils.h
//  DroidLink
//
//  Created by Gaël PHILIPPE on 07/01/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#ifndef LogUtils_h
#define LogUtils_h

#import <Cocoa/Cocoa.h>

#define  TAG @""
#define  LOG(fmt, ...) NSLog(@"%s : %@", TAG, [NSString stringWithFormat:fmt, ##__VA_ARGS__]);


#endif /* LogUtils_h */
