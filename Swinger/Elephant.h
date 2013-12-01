//
//  Elephant.h
//  Swinger
//
//  Created by James Sandoz on 6/19/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "BaseCatcherObject.h"

typedef enum {
    kElephantStateNone,
    kElephantStateWalking,
    kElephantStateBucking
} ElephantState;

@class Player;

@interface Elephant : BaseCatcherObject {
    CCSprite *elephantSprite;
    
    CCSpeed *walkSpeedAction;
    
    float leftPos;
    float rightPos;
    
    float walkVelocity;
    float playerCatchHeight;
    float timeout;
    
    ElephantState state;
    
    b2Fixture *fixture;
    float scrollBufferZone;
    
    Player *player;
    b2Joint *playerJoint;
    BOOL playerFlipped;
    
    // used to prevent us from attempting to turn the same direction several times in a row due to elephant positioning
    int justTurned;
}

- (void) load:(Player *)thePlayer;

- (void) jump;
- (void) buck;
- (void) reset;

@property (readwrite, nonatomic, assign) float leftPos;
@property (readwrite, nonatomic, assign) float rightPos;
@property (readwrite, nonatomic, assign) float walkVelocity;
@property (readwrite, nonatomic, assign) float timeout;

@end
