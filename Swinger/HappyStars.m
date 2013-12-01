//
//  HappyStars.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/25/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "HappyStars.h"

@implementation HappyStars

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
