//
//  IAP.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/22/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "IAP.h"

@implementation IAP
@synthesize price;
@synthesize desc;
@synthesize productId;
@synthesize sortOrder;

- (void) dealloc {
    [super dealloc];
}

- (NSString*) getPriceString {
    NSString *s = [NSString stringWithFormat:@"%@ %@", desc, price];
    return s;
}

@end
