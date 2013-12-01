//
//  Crow.m
//
//  Created by min on 3/14/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "Crow.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "UserData.h"
#import "Player.h"
#import "AudioEngine.h"

@implementation Crow
@synthesize state;
@synthesize gameObjectId;

static BOOL animationLoaded = NO;

+(void) resetAnimations {
    animationLoaded = NO;
}

-(void) setupAnimations {
    if (NO == animationLoaded) {
        animationLoaded = YES;
        NSMutableArray *animFrames = [NSMutableArray array];
        for (int i = 1; i <= 6; i++) {
			NSString *file = [NSString stringWithFormat:@"Crow%d.png", i];
    		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[animFrames addObject:frame];            
        }
        
        CCAnimation *flying = [CCAnimation animationWithFrames:animFrames delay:0.035];        
		[[CCAnimationCache sharedAnimationCache] addAnimation:flying name:@"birdFlyingAnimation"];
    }
}

- (GameObjectType) gameObjectType {
    return kGameObjectCrow;
}

-(id) generateBirdPath {
    float v = CCRANDOM_0_1();
    float d = v * 600;
    if (v < 0) {
        d = v * 500;
    }
    if (self.flipX == NO) {
        d = -d;
    }
    float time = 3.5+CCRANDOM_0_1()*1;
    float scale = [[CCDirector sharedDirector] winSize].height/640;
    id action = [CCMoveTo actionWithDuration:time position:ccp(self.position.x + d, scale*1000)];
    id zoom = [CCScaleTo actionWithDuration:time/2 scale:2.1];
    id spawn = [CCSpawn actions:action, zoom, nil];
    return spawn;
}

- (b2Body*) getPhysicsBody {
    return body;
}

- (BOOL) isSafeToDelete {
    return safeToDelete;
}

- (void) safeToDelete {
    safeToDelete = YES;
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
    [self setVisible:YES];
    //body->SetActive(YES);
}

- (void) hide {
    //body->SetActive(NO);
    [self setVisible:NO];
}

-(id) init {
    if ((self = [super init])) {
        state = kBirdSitting;
        [self setupAnimations];
    }
    return self;
}

-(void) destroyMe {
    state = kBirdDestroy;
}

-(void) fly {
    if (state != kBirdFlying) {
        state = kBirdFlying;
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"birdFlyingAnimation"] restoreOriginalFrame:NO];
        CCRepeatForever *flyAction = [CCRepeatForever actionWithAction:action];
        id fly = [self generateBirdPath];
        id callback = [CCCallFunc actionWithTarget:self selector:@selector(destroyMe)];
        id sequence = [CCSequence actions:fly, callback, nil];
        [self runAction:sequence];
        [self runAction:flyAction];
        
        [[AudioEngine sharedEngine] playEffect:SND_FLAP sourceGroupId:CGROUP2_4VOICE gain:1<<8];
    }
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
	b2BodyDef playerBodyDef;
	playerBodyDef.type = b2_kinematicBody;
	playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	playerBodyDef.userData = self;
	playerBodyDef.fixedRotation = false;
	
	body = theWorld->CreateBody(&playerBodyDef);
	
	b2CircleShape circleShape;
	circleShape.m_radius = 0.5f;
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circleShape;
	fixtureDef.density = 5000.0f;
	fixtureDef.friction = 3.0f;
	fixtureDef.restitution =  0.18f;
	fixtureDef.isSensor = true;
	body->CreateFixture(&fixtureDef);	
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    if (state == kBirdDestroyed) {
        return;
    }
    
    Player *player = [[GamePlayLayer sharedLayer] getPlayer];
    // From GamePlayLayer's update method. If we're using this, then implement as below
    if (self.state == kBirdSitting) {
        //float g_xScale = 1.0f;
        //if (self.position.x - player.position.x < (5*g_xScale)) {
        if(player.state == kSwingerInAir && [self parent].visible == YES)
        {
            //CCLOG(@"I AM FLYING AWAY!");
            //[self show];
            [self fly];
        }
    } else if (self.state == kBirdDestroy) {
        //CCLOG(@"------------------------------------------- DESTROY CROW");
        state = kBirdDestroyed;
        [self hide];
        [self safeToDelete];
        //[[GamePlayLayer sharedLayer] addToDeleteList:self];
    }
}

- (void) reset {
    //
}

- (void) updateObjectOnParallax
{
    if (state == kBirdDestroyed) {
        return;
    }
    
    CGSize screenSize  = [[CCDirector sharedDirector] winSize];
    CGPoint parentPos = [self parent].position;
    
    CGPoint absPos = ccp(parentPos.x + self.position.x, self.position.y);
    
    Player *player = [[GamePlayLayer sharedLayer] getPlayer];    
    
    if (self.state == kBirdSitting &&
        [self parent].visible == YES && 
        absPos.x >= 0.0 && absPos.x < screenSize.width - 3 &&
        player.state == kSwingerInAir) 
    {
        [self fly];
    } else if (self.state == kBirdDestroy) {
        //CCLOG(@"------------------------------------------- DESTROY CROW");
        state = kBirdDestroyed;
        [self hide];
        [self safeToDelete];
    }
}

- (void) destroyPhysicsObject 
{
    if(world != NULL)
        world->DestroyBody(body);
}

- (void) dealloc {
    CCLOG(@"-------------------- Crow being deallocated");
    [super dealloc];
}

@end
