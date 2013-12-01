//
//  PowerUp.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/17/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "BaseCatcherObject.h"

typedef enum {
    kPowerUpTypeShort,
    kPowerUpTypeMedium,
    kPowerUpTypeLong,
    kPowerUpTypeExtended
} PowerUpType;

typedef enum {
    kPowerUpNone,
    kPowerUpActivated
} PowerUpState;

typedef enum {
    kPowerUpSingle,
    kPowerUpCombo
} PowerUpComboType;

@interface PowerUp : CCNode<GameObject, PhysicsObject> {
    int gameObjectId;

    //PowerUpType type;
    PowerUpState state;
    PowerUpComboType comboType;
    BOOL isSafeToDelete;
    b2Body *body;
    b2World *world;
    CGSize screenSize;
    
    CCSprite * sprite;
    
    CGPoint startingPosition;
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;
}

- (void) activate;
- (void) deactivate;
- (void) showAt:(CGPoint)pos;
- (CCSprite *) getSprite;
- (int) getDuration;
- (BOOL) canCombine: (PowerUp *) power;
- (PowerUpType) getType;

// notification helpers
- (void) activationNotificationHelper;
- (void) deactivationNotificationHelper;

@property (nonatomic, readonly) PowerUpState state;
@property (nonatomic, readonly) PowerUpComboType comboType;
//@property (nonatomic, readonly) PowerUpType type;

@end
