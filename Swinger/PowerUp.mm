//
//  PowerUp.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/17/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PowerUp.h"
#import "Notifications.h"
#import "GamePlayLayer.h"
#import "StoreManager.h"

@implementation PowerUp

@synthesize state;
@synthesize gameObjectId;
@synthesize comboType;
//@synthesize type;

- (id) init {
    self = [super init];
    if (self) {
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        // Register for powerup activation notifications and deactivate yourself appropriately
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(deactivate:) 
                                                     name:NOTIFICATION_POWERUP_ACTIVATED 
                                                   object:nil];
        
        // Register for game over/level finished notifications and deactivate yourself appropriately
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(gameOver:) 
                                                     name:NOTIFICATION_GAME_OVER 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(gameOver:) 
                                                     name:NOTIFICATION_FINISHED_LEVEL 
                                                   object:nil];
        
        
        //type = [[StoreManager sharedInstance] getPowerUpType: [self gameObjectType]];
        comboType = kPowerUpSingle;
    }
    
    return self;
}

- (PowerUpType) getType {
    return [[StoreManager sharedInstance] getPowerUpType: [self gameObjectType]];
}

- (BOOL) canCombine: (PowerUp *) power {
    // --
    return (comboType == kPowerUpCombo && power.comboType == kPowerUpCombo);
}

- (void) gameOver: (NSNotification *) notification {
    
    state = kPowerUpNone;
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(fading) forTarget:self];
}

- (void) deactivate: (NSNotification *) notification {
    
    if (state == kPowerUpActivated && notification.object != self) { 
        // if its not you and you are active, deactivate yourself as the most recent power up supercedes previous ones
        
        [[CCScheduler sharedScheduler] unscheduleSelector:@selector(fading) forTarget:self];
        
        if (comboType != kPowerUpCombo || ((PowerUp *) notification.object).comboType != kPowerUpCombo) {
            // do not deactivate yourself yet, if you are a combo powerup and the new power up is combo
            CCLOG(@"I HAVE BEEN SUPERCEDED BY ANOTHER POWERUP! %@", notification.object);
            [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
            [self deactivate];
        }
    }
}

- (void) deactivate {
    //NSAssert(NO, @"This method must be overriden by all concrete powerups");
    
    if (state != kPowerUpNone) {
        state = kPowerUpNone;
        [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
        [self deactivationNotificationHelper];
        [[GamePlayLayer sharedLayer] collect:self];
    }
}

- (void) deactivationNotificationHelper {

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POWERUP_DEACTIVATED object:self];
}

- (void) activate {
    //NSAssert(NO, @"This method must be overriden by all concrete powerups");
    if (state == kPowerUpNone) {
        state = kPowerUpActivated;
        [self activationNotificationHelper]; // send out the notification
        sprite.visible = NO;
        int duration =[self getDuration];
        
        [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
        [[CCScheduler sharedScheduler] scheduleSelector : @selector(deactivate) forTarget:self interval:duration paused:NO];
        
        // do sound
    }
}

- (void) activationNotificationHelper {
    
    int duration = [self getDuration];
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(fading) forTarget:self interval:duration-5 paused:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POWERUP_ACTIVATED object:self];
}

- (CCSprite *) getSprite {
    NSAssert(NO, @"This method must be overriden by all concrete powerups");
    return nil;
}

- (int) getDuration {
    NSAssert(NO, @"This method must be overriden by all concrete powerups");
    return -1;
}

- (void) fading {
    
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(fading) forTarget:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POWERUP_FADING object:self];
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    startingPosition = pos;
    [self moveTo:pos];
    [self show];
}


#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    NSAssert(NO, @"This method must be overriden by all concrete powerups");
}

- (void) destroyPhysicsObject {
    if (world != NULL && body != NULL) {
        world->DestroyBody(body);
    }
}

- (b2Body*) getPhysicsBody {
    return body;
}

- (b2Vec2) previousPosition {
    return previousPosition;
}

- (b2Vec2) smoothedPosition {
    return smoothedPosition;
}

- (void) setPreviousPosition:(b2Vec2)p {
    previousPosition = p;
}

- (void) setSmoothedPosition:(b2Vec2)p {
    smoothedPosition = p;
}

- (float) previousAngle {
    return previousAngle;
}

- (float) smoothedAngle {
    return smoothedAngle;
}

- (void) setPreviousAngle:(float)a {
    previousAngle = a;
}

- (void) setSmoothedAngle:(float)a {
    smoothedAngle = a;
}


#pragma mark - GameObject protocol
- (void) updateObject:(ccTime)dt scale:(float)scale {
    NSAssert(NO, @"This method must be overriden by all concrete powerups");
}

- (GameObjectType) gameObjectType {
    NSAssert(NO, @"This method must be overriden by all concrete powerups");
    return kGameObjectNone;
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (void) show {
    //self.visible = YES;
}

- (void) hide {
    //self.visible = NO;
}

- (void) reset {
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
    state = kPowerUpNone;
    
    self.visible = YES;
    sprite.visible = YES;
    body->SetActive(true);
    [self showAt:startingPosition];
}

- (void) dealloc {
    CCLOG(@"------------------------------ Powerup being dealloced");
    [self unscheduleAllSelectors];
    [self stopAllActions];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_ACTIVATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_OVER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FINISHED_LEVEL object:nil];
    
    [super dealloc];
}

@end
