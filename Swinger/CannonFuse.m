//
//  CannonFuse.m
//  Swinger
//
//  Created by Isonguyo Udoka on 6/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CannonFuse.h"

@implementation CannonFuse

-(id) initWithFile:(NSString *)plistFile {

    if ((self = [super initWithFile:plistFile]) != nil) {
        
        [self generateSizeAndScale];
        self.positionType = kCCPositionTypeGrouped;
        self.visible = NO;
        [self stopSystem];
    }
    
    return self;
}

+(id) particleWithFile:(NSString*) plistFile {
	return [[[self alloc] initWithFile:plistFile] autorelease];
}

- (void) generateSizeAndScale {
    self.scale = 1;    
}

- (void)dealloc {
    [super dealloc];
}

@end
