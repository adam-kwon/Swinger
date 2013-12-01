//
//  Enemy.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Enemy.h"
#import "Notifications.h"
#import "GamePlayLayer.h"
#import "Player.h"
#import "PowerUp.h"
#import "MissileLauncher.h"
#import "GrenadeLauncher.h"

@implementation Enemy

@synthesize state;

- (id) init {
	if ((self = [super init])) {
        
        screenSize = [CCDirector sharedDirector].winSize;
        state = kEnemyStateAlive;
        
        // listen for missile activation and check if you are in range for missile
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(powerUpActivated:) 
                                                     name:NOTIFICATION_POWERUP_ACTIVATED 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(powerUpDeactivated:) 
                                                     name:NOTIFICATION_POWERUP_DEACTIVATED 
                                                   object:nil];
    }
    
    return self;
}

- (void) powerUpActivated: (NSNotification *) notification {
    
    PowerUp *currentPower = (PowerUp*)notification.object;
    
    switch ([currentPower gameObjectType]) {
        case kGameObjectMissileLauncher:
        case kGameObjectGrenadeLauncher: {
            missileActivated = YES;
            break;
        } 
        default:
            break;
    }
}

- (void) powerUpDeactivated: (NSNotification *) notification {
    
    PowerUp *currentPower = (PowerUp*)notification.object;
    
    switch ([currentPower gameObjectType]) {
        case kGameObjectMissileLauncher:
        case kGameObjectGrenadeLauncher: {
            missileActivated = NO;
            break;
        }
        default:
            break;
    }
}

- (CGPoint) getLeftEdge {
    NSAssert(NO, @"This is an abstract method and should be overriden");
    return CGPointZero;
}

- (void) attack: (Player *) player at: (CGPoint) location {
    NSAssert(NO, @"This is an abstract method and should be overriden");
}

- (BOOL) willKill:(Player *)player {
    NSAssert(NO, @"This is an abstract method and should be overriden");
    return NO;
}

- (BOOL) isVisible {
    NSAssert(NO, @"This is an abstract method and should be overriden");
    return NO;
}

- (void) die {
    //
    //CCLOG(@"I THE ENEMY AM NOW DEAD! %d", gameObjectId);
    state = kEnemyStateDead;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENEMY_KILLED object:self];
}

- (BOOL) canKill: (Player *)player {
    
    BOOL canKill = (state == kEnemyStateAlive);
    
    /*if (player.currentPower != nil) {
        
        switch ([player.currentPower gameObjectType]) {
            case kGameObjectShield: {
                canKill = NO;
                break;
            }
            case kGameObjectSpeedBoost: {
                canKill = NO;
                break;
            }
            case kGameObjectAngerPotion: {
                canKill = NO;
                break;
            }
            default:
                break;
        }
    }*/
    
    if ([player willKill]) {
        canKill = NO;
    }
    
    return canKill;
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    
}

- (void) setSwingerVisible:(BOOL)visible {
    
}

- (CGPoint) getCatchPoint {
    return CGPointZero;
}

- (float) getHeight {
    return self.position.y;
}

- (void) checkPowerups {
    
    if (state == kEnemyStateAlive && missileActivated) {
        
        Player *player = [[GamePlayLayer sharedLayer] getPlayer];
        PowerUp *currentPower = player.currentPower;
        
        if (currentPower == nil ||
            ([currentPower gameObjectType] != kGameObjectMissileLauncher &&
             [currentPower gameObjectType] != kGameObjectGrenadeLauncher)) {
            return;
        }
        
        if ([currentPower gameObjectType] == kGameObjectGrenadeLauncher &&
            ((GrenadeLauncher *)currentPower).grenadeState >= kGrenadeTriggered) {
            
            if (((GrenadeLauncher *)currentPower).grenadeState >= kGrenadeDetonated && [self isVisible]) {
                //CCLOG(@"GRENADE LAUNCHER IS IN RANGE TO KILL ME %d", self.gameObjectId);
                [(GrenadeLauncher *)currentPower launchAt:self];
                state = kEnemyStateMissileLocked;
            }
            
            return;
        }
        
        CGPoint targetPos = [self getLeftEdge]; //ccp([self getPhysicsBody]->GetPosition().x * PTM_RATIO, [self getPhysicsBody]->GetPosition().y * PTM_RATIO);
        CGPoint playerPos = ccp([player getPhysicsBody]->GetPosition().x * PTM_RATIO, [player getPhysicsBody]->GetPosition().y * PTM_RATIO);
        
        float scale = [GamePlayLayer sharedLayer].scale;
        float xDiff = powf(fabs(targetPos.x - playerPos.x), 2);
        float yDiff = powf(fabs(targetPos.y - playerPos.y), 2);
        float distance = sqrtf(xDiff+yDiff) * scale;
        float missileRange = [(MissileLauncher *)currentPower getRange];
        
        //CCLOG(@"----Distance missile to enemy: %f -----scale: %f -----missile range: %f ------", distance, scale, missileRange);
        if (distance <= missileRange) {
            
            if ([currentPower gameObjectType] == kGameObjectGrenadeLauncher) {
                
                if (((GrenadeLauncher *)currentPower).grenadeState < kGrenadeTriggered) {
                    // grenade launcher is in range to be triggered
                    //CCLOG(@"GRENADE LAUNCHER IS IN RANGE TO BE TRIGGERED %d", self.gameObjectId);
                    [(GrenadeLauncher *)currentPower trigger];
                }
            }
            else {
                // missile launcher is in range
                //CCLOG(@"MISSILE LAUNCHER IS IN RANGE TO KILL ME %d", self.gameObjectId);
                [(MissileLauncher *)currentPower launchAt: self];
                state = kEnemyStateMissileLocked;
            }
        }
    }
}

- (void) dealloc {
    CCLOG(@"------------------------------ Enemy being dealloced");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_ACTIVATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_DEACTIVATED object:nil];
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [super dealloc];
}

@end
