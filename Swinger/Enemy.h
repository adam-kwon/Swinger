//
//  Enemy.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "BaseCatcherObject.h"
#import "Player.h"

typedef enum {
    kEnemyStateNone,
    kEnemyStateAlive,
    kEnemyStateMissileLocked,
    kEnemyStateDead
} EnemyState;

@interface Enemy : BaseCatcherObject {
    
    EnemyState state;
    BOOL missileActivated;
}

- (BOOL) isVisible;
- (CGPoint) getLeftEdge;
- (void) checkPowerups;
- (BOOL) canKill: (Player *) player;
- (BOOL) willKill: (Player *) player;
- (void) attack: (Player *) player at: (CGPoint) location;
- (void) die;

@property (nonatomic, readonly) EnemyState state;

@end
