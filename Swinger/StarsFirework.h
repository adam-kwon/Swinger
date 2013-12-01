//
//  StarsFirework.h
//  Swinger
//
//  Created by Min Kwon on 6/9/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@interface StarsFirework : ARCH_OPTIMAL_PARTICLE_SYSTEM {
    
}

+ (id) particleWithFile:(NSString*)plistFile;
- (id) initWithFile:(NSString *)plistFile;
- (void) generateSizeAndScale;

@end
