//
//  PlayerFire.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/12/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@interface PlayerFire : ARCH_OPTIMAL_PARTICLE_SYSTEM {
    
}

+ (id) particleWithFile:(NSString*)plistFile;
- (id) initWithFile:(NSString *)plistFile;
- (void) generateSizeAndScale;

@end
