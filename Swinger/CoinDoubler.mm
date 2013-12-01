//
//  CoinDoubler.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/25/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CoinDoubler.h"
#import "GamePlayLayer.h"

@implementation CoinDoubler

- (id) init {
    self = [super init];
    if (self) {
        state = kPowerUpNone;
        comboType = kPowerUpCombo;
        sprite = [CCSprite spriteWithFile:@"coinDoubler.png"];
        [self addChild:sprite];
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
        sprite.visible = NO;
        [super activationNotificationHelper]; // send out the notification
        int duration = [self getDuration]; 
        [[CCScheduler sharedScheduler] scheduleSelector : @selector(deactivate) forTarget:self interval:duration paused:NO];
    }
}*/

- (int) getCoinFactor {
    int factor = 2;
    PowerUpType type = [self getType];
    
    if (type == kPowerUpTypeMedium) {
        factor = 2;
    } else if (type == kPowerUpTypeLong) {
        factor = 3;
    } else if (type == kPowerUpTypeExtended) {
        factor = 5;
    }
    
    return factor;
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
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    
    b2CircleShape shape;
    shape.m_radius = ([sprite boundingBox].size.width/2)/PTM_RATIO;
    
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
}

- (GameObjectType) gameObjectType {
    return kGameObjectCoinDoubler;
}

- (CCSprite *) getSprite {
    return [CCSprite spriteWithFile:@"coinDoubler.png"];
}

- (void) show {
    sprite.visible = YES;
}

- (void) hide {
    sprite.visible = NO;
}

/*- (void) reset {
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(deactivate) forTarget:self];
    state = kPowerUpNone;
    sprite.visible = YES;
    [self showAt:startingPosition];
}*/

- (void) dealloc {
    CCLOG(@"------------------------------ Coin Doubler being dealloced");
    [super dealloc];
}

@end
