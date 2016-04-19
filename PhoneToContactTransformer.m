//
//  PhoneToContactTransformer.m
//  DroidLink
//
//  Created by Gaël PHILIPPE on 15/02/2016.
//  Copyright © 2016 Gaël PHILIPPE. All rights reserved.
//

#import "PhoneToContactTransformer.h"
#import <AddressBook/AddressBook.h>

#import "LogUtils.h"

#ifdef TAG
#undef TAG
#endif

#define TAG "PhoneToContactTransformer"

@implementation PhoneToContactTransformer

+ (Class)transformedValueClass { return [NSString class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    NSString * number = (value == nil) ? nil : (NSString*)value;
    if ([number isEqualToString:@""]) return nil;
    if (number == nil) return nil;
    number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * personName;
    ABAddressBook * addressBook = [ABAddressBook sharedAddressBook];
    
    ABSearchElement * homePhone = [ABPerson searchElementForProperty:kABPhoneProperty label:kABPhoneHomeLabel key:nil value:number comparison:kABEqual];
    
    ABSearchElement * workPhone = [ABPerson searchElementForProperty:kABPhoneProperty label:kABPhoneWorkLabel key:nil value:number comparison:kABEqual];
    
    ABSearchElement * iPhone = [ABPerson searchElementForProperty:kABPhoneProperty label:kABPhoneiPhoneLabel key:nil value:number comparison:kABEqual];
    
    ABSearchElement * mobilePhone = [ABPerson searchElementForProperty:kABPhoneProperty label:kABPhoneMobileLabel key:nil value:number comparison:kABEqual];
    
    ABSearchElement * mainPhone = [ABPerson searchElementForProperty:kABPhoneProperty label:kABPhoneMainLabel key:nil value:number comparison:kABEqual];
    
    ABSearchElement * combinedSearch = [ABSearchElement searchElementForConjunction:kABSearchOr children:@[mainPhone, mobilePhone, iPhone, workPhone, homePhone]];
    
    NSArray * peopleFound = [addressBook recordsMatchingSearchElement:combinedSearch];
    
    if ([peopleFound count] == 0) {
        return number;
    }
    
    for (ABPerson * person in peopleFound) {
        
        ABMultiValue * phoneNumbers = [person valueForProperty:kABPhoneProperty];
        NSUInteger count = [phoneNumbers count];
        for (int i = 0; i < count; i++) {
            NSString * tempNumber = [phoneNumbers valueAtIndex:i];
            tempNumber = [tempNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            tempNumber = [tempNumber stringByReplacingOccurrencesOfString:@"+33 (0)" withString:@"0"];
            
            LOG(@"%@ vs %@", tempNumber, number)
            if ([tempNumber isEqualToString:number]) {
                NSString * firstName = [person valueForProperty:kABFirstNameProperty];
                NSString * lastName = [person valueForProperty:kABLastNameProperty];
                
                personName = [firstName stringByAppendingFormat:@" %@", lastName];
                
                LOG(@"found %@", personName)
                return personName;
            }
        }
        
        
        
    }
    
    return personName;
}

@end
