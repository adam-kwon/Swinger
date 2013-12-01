//
//  CannonFuse.h
//  Swinger
//
//  Created by Isonguyo Udoka on 6/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@interface CannonFuse : ARCH_OPTIMAL_PARTICLE_SYSTEM {
    
}

+ (id) particleWithFile:(NSString*)plistFile;
- (id) initWithFile:(NSString *)plistFile;
- (void) generateSizeAndScale;

@end
