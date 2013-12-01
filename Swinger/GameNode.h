//
//  GameNode.h
//  Swinger
//
//  Created by Min Kwon on 6/9/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "VRope.h"

@interface GameNode : CCNode {
    
    CCSpriteBatchNode* ropeSpriteSheet; //sprite sheet for rope segment
	NSMutableArray* vRopes; //array to hold rope references
    
}

- (void) updateRopes: (ccTime) dt;
- (VRope*) addRope: (b2Body*) body1 body2: (b2Body*) body2;

@end
