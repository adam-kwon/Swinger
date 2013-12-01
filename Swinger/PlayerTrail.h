//
//  PlayerTrail.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/13/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"

@interface PlayerTrail : ARCH_OPTIMAL_PARTICLE_SYSTEM {
    
}

+ (id) particleWithFile:(NSString*)plistFile;
- (id) initWithFile:(NSString *)plistFile;
- (void) generateSizeAndScale;
@end
