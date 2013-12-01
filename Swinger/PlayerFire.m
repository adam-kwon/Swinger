//
//  PlayerFire.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/12/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PlayerFire.h"

@implementation PlayerFire

-(id) initWithFile:(NSString *)plistFile {
    
    if((self = [super initWithFile:plistFile]) != nil) {
        self.positionType = kCCPositionTypeGrouped;
        [self generateSizeAndScale];
        
        self.visible = NO;
        [self stopSystem];
    }
    
    return self;
}

+(id) particleWithFile:(NSString*) plistFile {
	return [[[self alloc] initWithFile:plistFile] autorelease];
}

- (void) generateSizeAndScale {
    self.scale = 0.75f;    
}

- (void)dealloc
{
    [super dealloc];
}

@end