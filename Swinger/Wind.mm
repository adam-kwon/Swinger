//
//  Wind.m
//  Swinger
//
//  Created by Isonguyo Udoka on 5/28/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Wind.h"
#import "Constants.h"
#import "Notifications.h"
#import "AudioEngine.h"

@interface Wind(Private)
-(void) moveTo:(CGPoint)pos;
@end

@implementation Wind

@synthesize speed;
@synthesize direction;
@synthesize gameObjectId;

- (id) initWithValues: (float) mySpeed direction: (NSString*) myDirection {
    
    if ((self = [super init])) {
        safeToDelete = NO;
        
        speed = mySpeed;
        
        if([myDirection isEqualToString:@"N"]) {
            direction = kDirectionN;
        } else if([myDirection isEqualToString:@"S"]) {
            direction = kDirectionS;
        } else if([myDirection isEqualToString:@"E"]) {
            direction = kDirectionE;
        } else if([myDirection isEqualToString:@"W"]) {
            direction = kDirectionW;
        } else if([myDirection isEqualToString:@"NE"]) {
            direction = kDirectionNE;
        } else if([myDirection isEqualToString:@"SE"]) {
            direction = kDirectionSE;
        } else if([myDirection isEqualToString:@"NW"]) {
            direction = kDirectionNW;
        } else if([myDirection isEqualToString:@"SW"]) {
            direction = kDirectionSW;
        }
    }
    
    return self;
}

- (id) init {
    
    if ((self = [super init])) {
        safeToDelete = NO;
    }
    
    return self;
}

- (GameObjectType) gameObjectType {
    return kGameObjectWind;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    // Move wind at specified speed 
    
    if(![self visible])
        return;
}

- (void) blow : (b2Body*) player {
    
    b2Vec2 impVec = [self getWindForce: player->GetMass()];
    player->ApplyLinearImpulse(impVec, player->GetPosition());
}

- (b2Vec2) getWindForce: (float) mass {
    b2Vec2 impVec = b2Vec2(0,0);
    float impulse = speed * mass;
    
    if(direction == kDirectionN) {
        impVec = b2Vec2(0, impulse);
    } else if(direction == kDirectionS) {
        impVec = b2Vec2(0, -impulse);
    } else if(direction == kDirectionE) {
        impVec = b2Vec2(impulse, 0);
    } else if(direction == kDirectionW) {
        impVec = b2Vec2(-impulse, 0);
    } else if(direction == kDirectionNE) {
        impVec = b2Vec2(impulse, impulse);
    } else if(direction == kDirectionNW) {
        impVec = b2Vec2(-impulse, impulse);
    } else if(direction == kDirectionSE) {
        impVec = b2Vec2(impulse, -impulse);
    } else if(direction == kDirectionSW) {
        impVec = b2Vec2(-impulse, -impulse);
    }
    
    return impVec;
}

- (BOOL) isSafeToDelete {
    return safeToDelete;
}

- (void) safeToDelete {
    safeToDelete = YES;
}

- (void) show {
    [self setVisible:YES];
    body->SetActive(YES);
}

- (void) hide {
    body->SetActive(NO);
    [self setVisible:NO];
}

-(void) showAt:(CGPoint)pos {
    [self moveTo:pos];
    [self show];
}

-(void) moveTo:(CGPoint)pos {
    
    self.position = pos;
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) reset {
    //
}

- (void) createPhysicsObject:(b2World *)theWorld {
    
    CGPoint p = ccp(0,0);
    
    world = theWorld;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    b2PolygonShape shape;
    //shape.SetAsBox(self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/2, b2Vec2(0, 0), 0);
    shape.SetAsBox(0.2f/PTM_RATIO/2, 0.2f/PTM_RATIO/2, b2Vec2(0, 0), 0);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.isSensor = YES;
    //fixtureDef.filter.categoryBits = CATEGORY_WIND;
    //fixtureDef.filter.maskBits = CATEGORY_JUMPER;
    body->CreateFixture(&fixtureDef);
}

- (void) destroyPhysicsObject {
    world->DestroyBody(body);
    body = NULL;
}

@end
