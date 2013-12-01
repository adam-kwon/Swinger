//
//  StarsFirework.m
//  Swinger
//
//  Created by Min Kwon on 6/9/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StarsFirework.h"

@implementation StarsFirework


-(id) initWithFile:(NSString *)plistFile {
    
    [self generateSizeAndScale];
    
    self.visible = NO;
    [self stopSystem];
    
    
    return [super initWithFile:plistFile];
}

+(id) particleWithFile:(NSString*) plistFile {
	return [[[self alloc] initWithFile:plistFile] autorelease];
}

- (void) generateSizeAndScale {
    float g_xScale = 1.0;
    float randSize = CCRANDOM_0_1();
    float scale = (randSize == 0 ? 0.1 * g_xScale : randSize * 0.5f * g_xScale);
    if (scale <= 0.1*g_xScale) {
        scale = 0.1*g_xScale;   
    }
    self.scale = scale;    
}

- (void)dealloc
{
    [super dealloc];
}

@end
