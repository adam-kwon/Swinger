//
//  Shield.h
//  Swinger
//
//  Banana shield for the player
//  Created by Isonguyo Udoka on 8/17/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PowerUp.h"

@interface Shield : PowerUp {
    
    CCSprite * shieldActivated; // show a shield infront of the player - should be animated
}

+ make;

@end
