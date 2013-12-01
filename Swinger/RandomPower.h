//
//  Random.h
//  Swinger
//
//  Created by Isonguyo Udoka on 10/31/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PowerUp.h"

@interface RandomPower : PowerUp {
    
    PowerUp * power; // the current random power
    GameObjectType originalType; // original 
}

+ make: (GameObjectType) type;

@end
