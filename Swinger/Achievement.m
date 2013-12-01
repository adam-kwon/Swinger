//
//  Achievement.m
//  Swinger
//
//  Created by James Sandoz on 9/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Achievement.h"

#define ACH_KEY        "ACH_KEY"
#define ACH_GK_ACHIEVE "ACH_GK_ACHIEVE"


@implementation Achievement

@synthesize key;
@synthesize gkAchievement;

- (id) initForKey:(NSString *)theKey gameCenterId:(NSString *)gcId {
    if ((self = [super init])) {
        key = theKey;
        gkAchievement = [[[GKAchievement alloc] initWithIdentifier:gcId] retain];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        key = [aDecoder decodeObjectForKey:@ACH_KEY];
        gkAchievement = [aDecoder decodeObjectForKey:@ACH_GK_ACHIEVE];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.key forKey:@ACH_KEY];
    [aCoder encodeObject:self.gkAchievement forKey:@ACH_GK_ACHIEVE];
}

- (void) dealloc {
    [gkAchievement release];
    [super dealloc];
}

@end
