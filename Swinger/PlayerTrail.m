//
//  PlayerTrail.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/13/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PlayerTrail.h"

@implementation PlayerTrail

-(id) initWithFile:(NSString *)plistFile {
    
    if((self = [super initWithFile:plistFile]) != nil) {
        //self.positionType = kCCPositionTypeFree;
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
    self.scale = 0.5;    
}

- (void)dealloc
{
    [super dealloc];
}
@end
