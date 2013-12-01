//
//  MissileLauncher.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PowerUp.h"
#import "Enemy.h"

@interface MissileLauncher : PowerUp {
    
}

+ make;

- (float) getRange;
- (void) launchAt: (Enemy*) enemy;

@end
