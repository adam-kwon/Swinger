//
//  Wheel.h
//  Swinger
//
//  Created by Isonguyo Udoka on 6/18/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCSprite.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"
#import "BaseCatcherObject.h"
#import "Player.h"

typedef enum {
    kWheelRotating,
    kWheelCaughtPlayer,
    kWheelDestroyed
} WheelState;

@interface Wheel : BaseCatcherObject {
    
    WheelState state;
    
    Player    *player;
    
    b2Body     * anchor;
    b2Fixture  * wheel;
    
    b2RevoluteJoint * wheelJoint;
    b2Joint         * playerJoint;
    
    CCSprite    *wheelSprite;
    CCSprite    *baseSprite;
    
    float       dtSum;
    float       playerXPos;
    BOOL        firstUpdate;
    
    float       motorSpeed; // spin rate
    float       speedDelta;
    float       currentSpeed; // current speed of the player
    float       speedFactor;
    float       timeout;// how long before player tires out and falls to his death
    float       currentPace;
    
    NSDate     *lastTapTime;
    
    CCSpeed    *runSpeedAction;
    float       animRate;
    float       speedUpdateAmount;
    float       radius; // need this because wheel sprite is not a perfect circle, if I calculate radius on the fly i get different values over time
    
    CGPoint     loadPosition;
    
    float       jumpForce;
    BOOL        trajectoryDrawn;
    CCArray    *dashes;
}


- (void) load : (Player*) player at: (CGPoint) location;
- (void) unload;
- (void) fling;
- (void) handleTap;

@property (nonatomic, readwrite, assign) float motorSpeed;
@property (nonatomic, readwrite, assign) float timeout;

@end
