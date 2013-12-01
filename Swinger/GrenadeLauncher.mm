//
//  GameChanger.m
//  Swinger
//
//  Created by Isonguyo Udoka on 11/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GrenadeLauncher.h"
#import "Enemy.h"
#import "Missile.h"
#import "GamePlayLayer.h"
#import "AudioEngine.h"
#import "AudioConstants.h"

@implementation GrenadeLauncher

@synthesize grenadeState;

- (id) init {
    self = [super init];
    if (self) {
        comboType = kPowerUpCombo;
        sprite = [CCSprite spriteWithFile:@"grenade.png"];
        grenadeState = kGrenadeNone;
        [self addChild: sprite];
    }
    return self;
}

+ (id) make {
    return [[[self alloc] init] autorelease];
}

- (float) getRange {
    
    float range = screenSize.width/2;
    PowerUpType type = [self getType];
    
    if (type == kPowerUpTypeMedium) {
        range = screenSize.width/2;
    } else if (type == kPowerUpTypeLong) {
        range = screenSize.width/2;
    } else if (type == kPowerUpTypeExtended) {
        range = screenSize.width;
    }
    
    return range;
}

- (void) trigger {
    
    if (grenadeState == kGrenadeNone) {
        grenadeState = kGrenadeTriggered;
     
        // freeze game play, elevate a few feet from players height then detonate
        // .
        // ..
        // ...
        
        [[AudioEngine sharedEngine] playEffect:SND_TIME_BOMB];
        
        detonator = [self getSprite];
        b2Body * pBody = [[[GamePlayLayer sharedLayer] getPlayer] getPhysicsBody];
        detonationPoint = ccp(pBody->GetPosition().x*PTM_RATIO, pBody->GetPosition().y*PTM_RATIO);
        detonator.position = detonationPoint;
        
        [[GamePlayLayer sharedLayer] addChild: detonator];
        
        [[CCScheduler sharedScheduler] setTimeScale:0.05];
        CCMoveBy * move = [CCMoveBy actionWithDuration:0.01 position:ccp(0,ssipadauto(100))];
        CCDelayTime * wait = [CCDelayTime actionWithDuration:0.05];
        /*CCMoveBy * shake1 = [CCMoveBy actionWithDuration:0.01 position:ccp(2.5,0)];
        CCMoveBy * shake2 = [CCMoveBy actionWithDuration:0.01 position:ccp(-2.5,0)];
        CCMoveBy * shake3 = [CCMoveBy actionWithDuration:0.01 position:ccp(2.5,0)];
        CCMoveBy * shake4 = [CCMoveBy actionWithDuration:0.01 position:ccp(-2.5,0)];
        CCMoveBy * shake5 = [CCMoveBy actionWithDuration:0.01 position:ccp(2.5,0)];
        CCMoveBy * shake6 = [CCMoveBy actionWithDuration:0.01 position:ccp(-2.5,0)];
        CCMoveBy * shake7 = [CCMoveBy actionWithDuration:0.01 position:ccp(2.5,0)];
        CCMoveBy * shake8 = [CCMoveBy actionWithDuration:0.01 position:ccp(-2.5,0)];*/
        CCCallFunc * launch = [CCCallFunc actionWithTarget:self selector:@selector(detonate)];
 //       CCEaseExponentialIn * ease = [CCEaseExponentialIn actionWithAction:[CCSequence actions: move, shake1, shake2, shake3, shake4, shake5, shake6, shake6, shake7, shake8, launch, nil]];
        
        [detonator runAction:[CCSequence actions: move, wait,/*shake1, shake2, shake3, shake4, shake5, shake6, shake6, shake7, shake8,*/ launch, nil]];
    }
}

- (void) detonate {
    
    CCFadeOut * fade = [CCFadeOut actionWithDuration:0.01];
    [detonator runAction:fade];
    grenadeState = kGrenadeDetonated;
    [[CCScheduler sharedScheduler] setTimeScale:1];
}

- (void) deactivate {
    
    [super deactivate];
}

- (void) launchAt: (Enemy*) enemy {
    
    if (enemy.state != kEnemyStateMissileLocked && enemy.state != kEnemyStateDead && enemy.state != kEnemyStateNone) {
        //CCLOG(@"---------missile launched at enemy %d-------", enemy.gameObjectId);
        Missile *missile = [Missile make: kProjectileGrenade target: enemy pos: ccp(detonationPoint.x, detonationPoint.y + 100)];
        missile.gameObjectId = [GamePlayLayer sharedLayer].goId++;
        [missile createPhysicsObject: world];
        
        if (grenadeState == kGrenadeDetonated) {
            grenadeState = kGrenadeComplete;
            
            [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
            [[CCScheduler sharedScheduler] scheduleSelector : @selector(deactivate) forTarget:self interval:0.1 paused:NO];
        }
    }
}

- (int) getDuration {
    
    // Activated until an enemy triggers it then it goes off
    int duration = 10000000;
    /*PowerUpType type = [self getType];
    
    if (type == kPowerUpTypeMedium) {
        duration = 8;
    } else if (type == kPowerUpTypeLong) {
        duration = 10;
    } else if (type == kPowerUpTypeExtended) {
        duration = 12;
    }*/
    
    return duration;
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

- (CGRect) boundingBox {
    CGRect r = CGRectMake(self.position.x, self.position.y, [sprite boundingBox].size.width, [sprite boundingBox].size.height);
    return r;
}

#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    b2CircleShape shape;
    shape.m_radius = ([sprite boundingBox].size.height/2)/PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.f;
    fixtureDef.friction = 5.3f;
    fixtureDef.isSensor = YES;
    fixtureDef.filter.categoryBits = CATEGORY_STAR; // Use same as star (intentional)
    fixtureDef.filter.maskBits = CATEGORY_JUMPER;
    body->CreateFixture(&fixtureDef);
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

- (b2Body*) getPhysicsBody {
    return body;
}

#pragma mark - GameObject protocol
- (void) updateObject:(ccTime)dt scale:(float)scale {
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    
    if (state == kPowerUpActivated && body->IsActive()) {
        body->SetActive(false);
    }
    
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, self.position.x, scale),
                           normalizeToScreenCoord(gamePlayPosition.y, self.position.y, scale));
    
    CGRect box = [self boundingBox];
    if (sprite.visible) {
        if ((worldPos.x < -box.size.width || worldPos.x > screenSize.width)
            || (worldPos.y < -box.size.height || worldPos.y > screenSize.height))
        {
            [self hide];
        }
    } else if (!sprite.visible && state != kPowerUpActivated) {
        if ((worldPos.x >= -box.size.width && worldPos.x <= screenSize.width)
            && (worldPos.y >= -box.size.height && worldPos.y <= screenSize.height))
        {
            [self show];
        }
    }
    
    // show missile launcher on monkeys shoulder
    
}

- (GameObjectType) gameObjectType {
    return kGameObjectGrenadeLauncher;
}

- (CCSprite *) getSprite {
    return [CCSprite spriteWithFile:@"grenade.png"];
}

- (void) show {
    self.visible = YES;
    sprite.visible = YES;
}

- (void) hide {
    sprite.visible = NO;
}

- (void) reset {
    
    if (detonator != nil) {
        [detonator removeFromParentAndCleanup:YES];
        detonator = nil;
    }
    
    [super reset];
    grenadeState = kGrenadeNone;
}

- (void) dealloc {
    CCLOG(@"------------------------------ Grenade Launcher being dealloced");
    
    // REMEMBER TO CLEAN UP GRENADES ONCE THEY DESTROY ENEMY!
    [super dealloc];
}

@end
