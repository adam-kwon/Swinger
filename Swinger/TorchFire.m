//
//  TorchFire.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/11/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "TorchFire.h"

@implementation TorchFire

-(id) initWithFile:(NSString *)plistFile {
    
    if((self = [super initWithFile:plistFile]) != nil) {
        //self.autoRemoveOnFinish = YES;
        //self.positionType = kCCPositionTypeGrouped;
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
