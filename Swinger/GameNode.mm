//
//  GameNode.m
//  Swinger
//
//  Created by Min Kwon on 6/9/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GameNode.h"
#import "PhysicsWorld.h"
#import "PhysicsSystem.h"
#import "GamePlayLayer.h"

// This custom node is necessary in order for Box2d debug drawing to work correctly.
// This is because we are storing all the game objects inside a node, and then
// adding that node to the GamePlayLayer instead of adding it to GamePlayLayer directly.
// Not required in 2012 because we were scrolling GamePLayLayer directly. Here we're
// scrolling the GameNode
@implementation GameNode

- (id) init {
    self = [super init];
    
    if (self != nil) {
        // +++ Add rope spritesheet to layer
		ropeSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"rope.png" ];
		[self addChild:ropeSpriteSheet z:100];
		// +++ Init array that will hold references to all our ropes
		vRopes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (VRope*) addRope: (b2Body*) body1 body2: (b2Body*) body2 {
    // +++ Create VRope with two b2bodies and pointer to spritesheet
	VRope *newRope = [[VRope alloc] init:body1 body2:body2 batchNode:ropeSpriteSheet];
	[vRopes addObject:newRope];
    
    return newRope;
}

- (void) updateRopes: (ccTime) dt {
    
    // +++ Update rope physics
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] update:dt];
	}
}

-(void)removeRopes {
    CCLOG(@"*************Deallocating VRopes**************");
    
	for(uint i=0;i<[vRopes count];i++) {
		[[vRopes objectAtIndex:i] removeSprites];
		[[vRopes objectAtIndex:i] release];
	}
	[vRopes removeAllObjects];
}

- (void) dealloc {
    CCLOG(@"**************Deallocing game node*********");
    [self removeRopes];
    
    [super dealloc];
}

#if DEBUG
-(void) draw {
    [super draw];
    //    glColor4ub(255, 255, 255, 255);
    //    glLineWidth(4);
    //
    //    for (CatcherGameObject *co in levelObjects) {
    //        if ([co gameObjectType] == kGameObjectCatcher) {
    //            RopeSwinger *rs = (RopeSwinger*)co;
    //            ccDrawLine(rs.ropeSwivelPosition, rs.catcherSprite.position);
    //        }
    //    }
    //    
    //    glLineWidth(1);
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
    glPushMatrix();
    glScalef( CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0f);
#if USE_FIXED_TIME_STEP == 1
    PhysicsSystem::Instance()->drawDebug();
#else
    [[PhysicsWorld sharedWorld] drawDebug];
#endif
    glPopMatrix();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // +++ Update rope sprites
    for(uint i=0;i<[vRopes count];i++) {
        [[vRopes objectAtIndex:i] updateSprites];
    }
}

#else
- (void) draw {
    [super draw];
    
    // +++ Update rope sprites
    for(uint i=0;i<[vRopes count];i++) {
        [[vRopes objectAtIndex:i] updateSprites];
    }
}

#endif

@end
