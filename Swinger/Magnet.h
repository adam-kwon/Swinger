//
//  Magnet.h
//  Swinger
//
//  Created by Min Kwon on 8/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GameObject.h"
#import "PhysicsObject.h"
#import "PowerUp.h"

@interface Magnet : PowerUp {

}

- (float) getRange;

+ (id) make;

@end
