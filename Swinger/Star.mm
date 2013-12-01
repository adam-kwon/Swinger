//
//  Star.m
//  Swinger
//
//  Created by Min Kwon on 6/14/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Star.h"
#import "GamePlayLayer.h"
#import "AudioEngine.h"
#import "HUDLayer.h"
#import "Player.h"

@implementation Star

@synthesize gameObjectId;


- (id) initStar {
    self = [super init];
    if (self) {
        screenSize = [[CCDirector sharedDirector] winSize];
        state = kStarStateNone;
        star = [CCSprite spriteWithSpriteFrameName:@"Star1.png"];
        [self addChild:star];
        explosion = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"stars_version2.plist"];
        explosion.visible = NO;
        [explosion stopSystem];
        [self addChild:explosion];        
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"starAnimation"] restoreOriginalFrame:NO];
        CCRepeatForever *animAction = [CCRepeatForever actionWithAction:action];
        [star runAction:animAction];
        
        startingPosition = ccp(0,0);
    }
    return self;
}

+ (id) make {
    return [[[self alloc] initStar] autorelease];
}


//- (void) destroy {
//    [self unschedule:@selector(destroy)];
//    explosion.visible = NO;
//    [explosion removeFromParentAndCleanup:YES];
//    [star removeFromParentAndCleanup:YES];
//    [self safeToDelete];
//    [[GamePlayLayer sharedLayer] addToDeleteList:self];
//}

- (void) collect {
    // Don't collect if the player is dead
    if (state == kStarStateNone /*&& [[GamePlayLayer sharedLayer] getPlayer].state != kSwingerFalling*/) {
        state = kStarStateCollecting;
        
        [[HUDLayer sharedLayer] collectStar:self];
    }
}

- (void) explode {
    if (state == kStarStateNone || state == kStarStateCollecting) {
        state = kStarStateExploding;
        [[AudioEngine sharedEngine] playEffect:SND_BLOP];
        star.visible = NO;
        explosion.visible = YES;
        [explosion resetSystem];
        [self schedule:@selector(hide) interval:0.7];
        
        [[HUDLayer sharedLayer] addLife];
    }
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    //explosion.position = pos;
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    startingPosition = pos;
    [self moveTo:pos];
    [self show];
}

- (CGRect) boundingBox {
    CGRect r = CGRectMake(self.position.x, self.position.y, [star boundingBox].size.width, [star boundingBox].size.height);
    return r;
}

#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(0/PTM_RATIO, 0/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    
    b2CircleShape shape;
    shape.m_radius = ([star boundingBox].size.width/2)/PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.f;
    fixtureDef.friction = 5.3f;
    fixtureDef.isSensor = YES;
    fixtureDef.filter.categoryBits = CATEGORY_STAR;
    fixtureDef.filter.maskBits = CATEGORY_JUMPER;
    body->CreateFixture(&fixtureDef);
}

- (void) destroyPhysicsObject {
    if (world != NULL && body != NULL) {
        world->DestroyBody(body);
        body = NULL;
    }
}

- (b2Body*) getPhysicsBody {
    return body;
}


#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return kGameObjectStar;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, self.position.x, scale), 
                           normalizeToScreenCoord(gamePlayPosition.y, self.position.y, scale));
    
    CGRect box = [self boundingBox];
    if (star.visible) {
        if ((worldPos.x < -box.size.width || worldPos.x > screenSize.width)
            || (worldPos.y < -box.size.height || worldPos.y > screenSize.height)) 
        {
            [self hide];
        }
    } else if (!star.visible && state == kStarStateHidden) { 
        if ((worldPos.x >= -box.size.width && worldPos.x <= screenSize.width)
            && (worldPos.y >= -box.size.height && worldPos.y <= screenSize.height))
        {
            [self show];
        }
    }
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
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


- (void) show {
    star.visible = YES;
}

- (void) hide {
    [self unschedule:@selector(hide)];
    state = kStarStateHidden;
    explosion.visible = NO;
    star.visible = NO;
}

- (void) reset {
    state = kStarStateNone;
    explosion.visible = NO;
    [self showAt:startingPosition];
}

- (void) dealloc {
    CCLOG(@"------------------------------ Star being dealloced");
    [super dealloc];
}

@end
