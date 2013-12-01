//
//  Coin.m
//  Swinger
//
//  Created by Min Kwon on 6/19/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Coin.h"
#import "GamePlayLayer.h"
#import "AudioManager.h"
#import "GamePlayLayer.h"
#import "HUDLayer.h"
#import "GPUtil.h"
#import "Player.h"
#import "Magnet.h"
#import "CoinDoubler.h"
#import "Notifications.h"

@implementation Coin

@synthesize gameObjectId;

- (id) initCoin: (GameObjectType) theType {
    self = [super init];
    if (self) {
        state = kCoinStateNone;
        type = theType;
        screenSize = [[CCDirector sharedDirector] winSize];
        NSString * spriteFile = @"Coin1.png";
        NSString * animName = @"coinAnimation";
        
        if (type == kGameObjectCoin5) {
            spriteFile = @"Coin5_1.png";
            animName = @"coin5Animation";
        } else if (type == kGameObjectCoin10) {
            spriteFile = @"Coin10_1.png";
            animName = @"coin10Animation";
        }
        
        coin = [CCSprite spriteWithSpriteFrameName:spriteFile];
        [self addChild:coin];
        explosion = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"stars_version2.plist"];
        explosion.position = self.position; 
        explosion.visible = NO;    
        [explosion stopSystem];
        [self addChild:explosion];
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:animName] restoreOriginalFrame:NO];
        CCRepeatForever *animAction = [CCRepeatForever actionWithAction:action];
        [coin runAction:animAction];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(powerupActivated:) 
                                                     name:NOTIFICATION_POWERUP_ACTIVATED 
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(powerupDeactivated:) 
                                                     name:NOTIFICATION_POWERUP_DEACTIVATED 
                                                   object:nil];

        startingPosition = ccp(0,0);
        startedMoving = NO;
    }
    return self;
}

+ (id) make {
    return [self make: kGameObjectCoin];
}

+ (id) make: (GameObjectType) type {
    return [[[self alloc] initCoin: type] autorelease];
}


//- (void) destroy {
//    [self unschedule:@selector(destroy)];
//    explosion.visible = NO;
//    [explosion removeFromParentAndCleanup:YES];
//    [coin removeFromParentAndCleanup:YES];
//    [self safeToDelete];
//    [[GamePlayLayer sharedLayer] addToDeleteList:self];
//}

- (void) collect {
    // Don't collect if the player is dead
    if (state == kCoinStateNone /*&& [[GamePlayLayer sharedLayer] getPlayer].state != kSwingerFalling*/
        || state == kCoinStateMagnetized)
    {
        state = kCoinStateCollecting;
        
        //CCLOG(@"In coin.collect(), player state=%d\n", [[GamePlayLayer sharedLayer] getPlayer].state);

        [[HUDLayer sharedLayer] collectCoin:self];
    }
}

- (void) explode {
    if (state == kCoinStateNone || state == kCoinStateCollecting) {
        state = kCoinStateExploding;
        [[AudioManager sharedManager] playCoinObtained];
        coin.visible = NO;
        explosion.visible = YES;
        [explosion resetSystem];
        [self schedule:@selector(hide) interval:0.7];
        [[HUDLayer sharedLayer] addCoin: [self getValue]];
    }
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    //CGPoint newPos = [coin.parent convertToWorldSpace:coin.position];
    //explosion.position = ccp(newPos.x + [coin boundingBox].size.width/2, newPos.y + [coin boundingBox].size.height/2);
    //explosion.position = newPos;
    //explosion.position = pos;
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    startingPosition = pos;
    [self moveTo:pos];
    [self show];
}


#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    
    b2CircleShape shape;
    shape.m_radius = ([self boundingBox].size.width/2)/PTM_RATIO;
    
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
- (GameObjectType) gameObjectType {
    return type;
}

- (int) getValue {
    int value = 1;
    
    if (type == kGameObjectCoin5) {
        value = 5;
    } else if (type == kGameObjectCoin10) {
        value = 10;
    }
    
    int factor = 1;
    
    PowerUp * currentPower = [[GamePlayLayer sharedLayer] getPlayer].currentPower;
    
    if (currentPower != nil && [currentPower gameObjectType] == kGameObjectCoinDoubler) {
        factor = [(CoinDoubler *) currentPower getCoinFactor];
    }
    
    return value * factor;
}

- (void)powerupActivated:(NSNotification *)notification {
    
    switch ([(GameObject *)notification.object gameObjectType]) {
        case kGameObjectMagnet:
            [self magnetActivated];
            break;
        case kGameObjectCoinDoubler:
            [self doublerActivated];
            break;
        default:
            break;
    }
}

- (void)magnetActivated {
    if (!hitPlayer) {
        state = kCoinStateMagnetized;
        currentMagnetRange = [(Magnet *)[[[GamePlayLayer sharedLayer] getPlayer] currentPower] getRange];
    }
}

- (void) doublerActivated {
    if (!hitPlayer)
        state = kCoinStateDoubled;
}

- (void)powerupDeactivated:(NSNotification *)notification {
    
    switch ([(GameObject *)notification.object gameObjectType]) {
        case kGameObjectMagnet:
            [self magnetDeactivated];
            break;
        case kGameObjectCoinDoubler:
            [self doublerDeactivated];
            break;
        default:
            break;
    }
}

- (void)magnetDeactivated {
    if (!hitPlayer)
        state = kCoinStateNone;
}

- (void) doublerDeactivated {
    if (!hitPlayer)
        state = kCoinStateNone;
}

- (CGRect) boundingBox {
    CGRect r = CGRectMake(self.position.x, self.position.y, [coin boundingBox].size.width, [coin boundingBox].size.height);
    return r;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, self.position.x, scale), 
                           normalizeToScreenCoord(gamePlayPosition.y, self.position.y, scale));
    
    CGRect box = [self boundingBox];
    if (coin.visible) {
        if ((worldPos.x < -box.size.width || worldPos.x > screenSize.width)
            || (worldPos.y < -box.size.height || worldPos.y > screenSize.height)) 
        {
            [self hide];
        }
    } else if (!coin.visible) { 
        if ((worldPos.x >= -box.size.width && worldPos.x <= screenSize.width)
            && (worldPos.y >= -box.size.height && worldPos.y <= screenSize.height))
        {
            [self show];
        }
    }
    
    if (!coin.visible) return;
    
    Player *player = [[GamePlayLayer sharedLayer] getPlayer];

    if (!hitPlayer) {
        
        if(state == kCoinStateMagnetized || startedMoving) {
            
            float xDist = fabs(self.position.x - player.position.x);
            float xDiff = powf(fabs(self.position.x - player.position.x), 2);
            float yDiff = powf(fabs(self.position.y - player.position.y), 2);
            float distance = sqrtf(xDiff+yDiff);
            //CCLOG(@"------- distance = %f xDiff=%f yDiff=%f xDist=%f", distance, xDiff, yDiff, xDist);
            const float radius = currentMagnetRange;
            if (distance <= radius || startedMoving) {
                float slope;
                /*
                 if (player.isFlying) {
                 slope = (self.position.y - player.position.y) / (self.position.x - player.position.x);            
                 } else {
                 // If standing, player is veritcal, so modify slope so that energy goes towards player's mid section
                 slope = (self.position.y - player.position.y) / (self.position.x - player.position.x);
                 }
                 */
                
                slope = (self.position.y - player.position.y) / (self.position.x - player.position.x);
                
                // Calculated delta x. Delta x is based on the delta time.
                float dx = (-500);
                if (player.position.x < self.position.x)  {
                    dx = (-500) * dt;
                }
                else if (player.position.x > self.position.x) {
                    float dxSpeed = [player getPhysicsBody]->GetLinearVelocity().x / 2;
                    // If player has passed energy, chase in the opposite direction. It must also be faster because player is now running away.
                    dx = (xDist*(dxSpeed > 10 ? dxSpeed : 10))*dt;
                }
                
                // Calculate delta y
                float playerHeight = [player boundingBox].size.height;
                int sign = fast_sign(slope);
                float dy = slope*dx;
                
                sign = fast_sign(dy);
                dy = fabs(dy) > playerHeight ? sign*playerHeight : dy;
                
                self.position = ccp(self.position.x + dx, self.position.y + dy);          
                
                startedMoving = YES;
                // Will just use rectangle intersection for collission
                /*
                 b2Vec2 pos = b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
                 body->SetActive(NO);
                 body->SetTransform(pos, 0);
                 body->SetActive(YES);
                 */
            }
        } else if (state == kCoinStateDoubled) {
            
            float xDiff = powf(fabs(self.position.x - player.position.x), 2);
            float yDiff = powf(fabs(self.position.y - player.position.y), 2);
            float distance = sqrtf(xDiff+yDiff);
            
            const float radius = screenSize.width/4;
            if (distance <= radius) {
                // do some nice animation or action
                
                CCMoveBy * moveUp = [CCMoveBy actionWithDuration:0.1 position:ccp(0,ssipadauto(30))];
                CCMoveBy * moveDown = [CCMoveBy actionWithDuration:0.1 position:ccp(0, ssipadauto(-30))];
                
                [self runAction: [CCSequence actions: moveUp, moveDown, nil]];
                
                state = kCoinStateNone;
            }
        }
    }
    
    
    // Ensure that contact with player is processed only once
    if (!hitPlayer) 
    {
        CGRect playerRect = [player boundingBox];
        CGRect myRect = [self boundingBox];
        
        if (CGRectIntersectsRect(playerRect, myRect)) {
            hitPlayer = YES;
            [self collect];
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
    if (!hitPlayer) {
        coin.visible = YES;
        if (state != kCoinStateMagnetized &&
            state != kCoinStateDoubled) 
            state = kCoinStateNone;
    }
}

- (void) hide {
    [self unschedule:@selector(hide)];
    if (!hitPlayer) {
        state = kCoinStateHidden;
        explosion.visible = NO;
        coin.visible = NO;
    }
}

- (void) reset {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    state = kCoinStateNone;
    hitPlayer = NO;
    startedMoving = NO;
    explosion.visible = NO;
    [self showAt:startingPosition];
}

- (void) dealloc {
    CCLOG(@"------------------------------ Coin being dealloced");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_ACTIVATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_POWERUP_DEACTIVATED object:nil];

    [super dealloc];
}



@end
