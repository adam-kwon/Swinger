//
//  Random.m
//  Swinger
//
//  Created by Isonguyo Udoka on 10/31/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "RandomPower.h"
#import "GamePlayLayer.h"
#import "Magnet.h"
#import "Shield.h"
#import "SpeedBoost.h"
#import "JetPack.h"
#import "AngerPotion.h"
#import "CoinDoubler.h"
#import "MissileLauncher.h"
#import "GrenadeLauncher.h"

@implementation RandomPower

- (id) initWithType: (GameObjectType) type {
    self = [super init];
    if (self) {
        originalType = type;
        power = [self createRandomPower];
    }
    return self;
}

+ (id) make: (GameObjectType) type {
    return [[[self alloc] initWithType: type] autorelease];
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    //body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    [self moveTo:pos];

    if (power != nil) {
        [power showAt: pos];
    }
    
    [self show];
}

- (void) reset{
    
    if (power != nil) {
        [power safeToDelete];
        [[GamePlayLayer sharedLayer] addToDeleteList: power];
        power = nil;
    }
    
    power = [self createRandomPower];
    [power createPhysicsObject:world];
    [power showAt: self.position];
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
 
    if (power != nil) {
        [power createPhysicsObject:world];
    }
}

- (PowerUp *) createRandomPower {
    //
    GameObjectType type = [[GamePlayLayer sharedLayer] checkForLockedPowers: originalType];
    PowerUp * thePower = nil;
    
    if (type == kGameObjectMagnet) {
        thePower = [Magnet make];
    }
    else if (type == kGameObjectSpeedBoost) {
        thePower = [SpeedBoost make];
    }
    else if (type == kGameObjectAngerPotion) {
        thePower = [AngerPotion make];
    }
    else if (type == kGameObjectMissileLauncher) {
       thePower = [MissileLauncher make];
    }
    else if (type == kGameObjectGrenadeLauncher) {
        thePower = [GrenadeLauncher make];
    }
    else if (type == kGameObjectJetPack) {
        thePower = [JetPack make];
    }
    else if (type == kGameObjectCoinDoubler) {
        thePower = [CoinDoubler make];
    }
    else if (type == kGameObjectShield) {
        thePower = [Shield make];
    }
    
    if (thePower != nil) {
        //
        //[thePower createPhysicsObject:world];
        //[thePower showAt: self.position];
        thePower.gameObjectId = [[GamePlayLayer sharedLayer] getNextObjectId];
        [[GamePlayLayer sharedLayer] addChild:thePower];
    }
    
    return thePower;
}

- (GameObjectType) gameObjectType {
    
    /*if (power != nil) {
        return [power gameObjectType];
    }*/
    
    return originalType;
}

- (CCSprite *) getSprite {
    return nil;//[power getSprite];
}

- (void) show {
    self.visible = YES;
    if (power != nil)
        [power show];
}

- (void) hide {
    //sprite.visible = NO;
    if (power != nil)
        [power hide];
}

- (void) dealloc {
    CCLOG(@"=====================Destroying Random Power==============================");
    
    if (power != nil) {
        CCLOG(@"RANDOM POWER IS NOT NIL!");
        power = nil;
    }
    
    [super dealloc];
}

@end
