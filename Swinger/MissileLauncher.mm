//
//  MissileLauncher.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "MissileLauncher.h"
#import "Missile.h"
#import "GamePlayLayer.h"

@implementation MissileLauncher

- (id) init {
    self = [super init];
    if (self) {
        comboType = kPowerUpCombo;
        sprite = [CCSprite spriteWithFile:@"missile.png"];
        [self addChild: sprite];
    }
    return self;
}

+ (id) make {
    return [[[self alloc] init] autorelease];
}

/*- (void) deactivate {
    
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
    [self deactivationNotificationHelper];
    [[GamePlayLayer sharedLayer] collect:self];
}

- (void) activate {
    
    if (state == kPowerUpNone) {
        state = kPowerUpActivated;
        [super activationNotificationHelper]; // send out the notification
        sprite.visible = NO;
        int duration =[self getDuration];
        
        [[CCScheduler sharedScheduler] scheduleSelector : @selector(deactivate) forTarget:self interval:duration paused:NO];
    }
}*/

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

- (void) launchAt: (Enemy*) enemy {
    
    if (enemy.state != kEnemyStateMissileLocked && enemy.state != kEnemyStateDead && enemy.state != kEnemyStateNone) {
        //CCLOG(@"---------missile launched at enemy %d-------", enemy.gameObjectId);
        Missile *missile = [Missile make: enemy];
        missile.gameObjectId = [GamePlayLayer sharedLayer].goId++;
        [missile createPhysicsObject: world];
    }
}

- (int) getDuration {
    
    int duration = 6;
    PowerUpType type = [self getType];
    
    if (type == kPowerUpTypeMedium) {
        duration = 8;
    } else if (type == kPowerUpTypeLong) {
        duration = 10;
    } else if (type == kPowerUpTypeExtended) {
        duration = 12;
    }
    
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
    return kGameObjectMissileLauncher;
}

- (CCSprite *) getSprite {
    return [CCSprite spriteWithFile:@"missile.png"];
}

- (void) show {
    self.visible = YES;
    sprite.visible = YES;
}

- (void) hide {
    sprite.visible = NO;
}

/*- (void) reset {
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
    state = kPowerUpNone;
    self.visible = YES;
    sprite.visible = YES;
    [self showAt:startingPosition];
}*/

- (void) dealloc {
    CCLOG(@"------------------------------ Missile Launcher being dealloced");
    
     // REMEMBER TO CLEAN UP MISSILES ONCE THEY DESTROY ENEMY!
    [super dealloc];
}

@end
