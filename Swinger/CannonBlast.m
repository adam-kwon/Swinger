//
//  CannonBlast.m
//  Swinger
//
//  Created by Isonguyo Udoka on 6/16/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CannonBlast.h"

@implementation CannonBlast

-(id) initWithFile:(NSString *)plistFile {
    
    if ((self = [super initWithFile:plistFile]) != nil) {
        
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
    self.scaleX = 0.1;    
}

- (void)dealloc
{
    [super dealloc];
}

@end
