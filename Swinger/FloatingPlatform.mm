//
//  FloatingPlatform.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/3/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FloatingPlatform.h"
#import "GamePlayLayer.h"
#import "Player.h"

static const BOOL THIN_BODY = NO;

@implementation FloatingPlatform

@synthesize width;
@synthesize elevatorDistance;
@synthesize elevatorSpeed;


- (id) initPlatform: (float) theWidth left: (CCSprite *) theLeft center: (CCSprite*) theCenter right: (CCSprite *) theRight {
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        
        width = theWidth;
        
        left = theLeft;
        left.anchorPoint = ccp(0,0.5);
        middle = theCenter;
        middle.anchorPoint = ccp(0,0.5);
        right = theRight;
        right.anchorPoint = ccp(0,0.5);
    }
    return self;
}

- (BOOL) isOneSided {
    return YES;
}

- (void) reset {
    //
}

+ (id) make: (float) theWidth {

    return [self make: theWidth left: [CCSprite spriteWithSpriteFrameName:@"Tile_Left.png"]
                              center: [CCSprite spriteWithSpriteFrameName:@"Tile_Middle.png"]
                               right: [CCSprite spriteWithSpriteFrameName:@"Tile_Right.png"]];
}

+ (id) make: (float) theWidth left:(CCSprite *)left center:(CCSprite *)center right:(CCSprite *)right {
    return [[[self alloc] initPlatform: theWidth left: left center: center right: right] autorelease];
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    [self moveTo:pos];
    [self show];
    
    if (elevatorSpeed > 0) {
        // Set the relative elevator positions based on this position
        elevatorMinHeight = pos.y - elevatorDistance/2;
        elevatorMaxHeight = pos.y + elevatorDistance/2;
        
        // start the elevator
        body->SetLinearVelocity(b2Vec2(0, elevatorSpeed));
    }
}

#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return kGameObjectFloatingPlatform;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    // Update position
    self.position = CGPointMake( body->GetPosition().x * PTM_RATIO, (body->GetPosition().y * PTM_RATIO));
    self.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
        
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, self.position.x, scale), 
                           normalizeToScreenCoord(gamePlayPosition.y, self.position.y, scale));
    
    if (platform.visible) {
        if ((worldPos.x < -width || worldPos.x > screenSize.width)
            || (worldPos.y < -height || worldPos.y > screenSize.height)) 
        {
            [self hide];
        }
    }
    else {
        if ((worldPos.x >= -width && worldPos.x <= screenSize.width) 
            && (worldPos.y >= -height && worldPos.y <= screenSize.height)) 
        {
            [self show];
        }
    }
    
    // if this platform should move up and down, handle that now
    if (elevatorSpeed != 0) {
        if (self.position.y > elevatorMaxHeight) {
            body->SetLinearVelocity(b2Vec2(0, -elevatorSpeed));
        } else if (self.position.y < elevatorMinHeight) {
            body->SetLinearVelocity(b2Vec2(0, elevatorSpeed));            
        }
    }
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (void) show {
    [platform setVisible: YES];
    
    body->SetActive(true);
}

- (void) hide {
    [platform setVisible: NO];
    
    //body->SetActive(false);
}

#pragma mark - physics object methods

- (void) createPhysicsObject:(b2World *)theWorld {
    
    height = 0;
    platform = [CCNode node];
    [self addChild:platform];
    self.anchorPoint = ccp(0,1);
    
    height = [middle boundingBox].size.height - ssipadauto(5);
    
    if ([self isOneSided]) {
        
        float remainingWidth = width - [left boundingBox].size.width - [right boundingBox].size.width;
        
        int numMiddle = 1;
        
        if (remainingWidth > 0) {
            numMiddle = ceil(remainingWidth/[middle boundingBox].size.width);
            
            if (numMiddle < 1) {
                numMiddle = 1;
            }
        }
        
        [platform addChild:left];
        
        int xSize = [left boundingBox].size.width - 1;
        
        middle.position = ccp(xSize,0);
        [platform addChild: middle];
        
        xSize += [middle boundingBox].size.width - 1;
        for (int i=1; i < numMiddle; i++) {
            
            CCSprite *middle2 = [self createMiddleSprite];
            middle2.anchorPoint = ccp(0,0.5);
            middle2.position = ccp(xSize,0);
            [platform addChild: middle2];
            
            xSize += [middle2 boundingBox].size.width - 1;
        }
        
        right.position = ccp(xSize, 0);
        [platform addChild: right];
        
        bodyWidth = (xSize + [right boundingBox].size.width + ssipadauto(10))/PTM_RATIO/2;
    } else {
        
        int numBlocks = ceil(width/[middle boundingBox].size.width);
        
        if (numBlocks < 1) {
            numBlocks = 1;
        }
        
        int xSize = 0; //[middle boundingBox].size.width - 1;
        
        /*middle.position = ccp(xSize,0);
        [platform addChild: middle];
        
        xSize += [middle boundingBox].size.width - 1;*/
        for (int i=0; i < numBlocks; i++) {
            
            CCSprite *middle2 = [self createMiddleSprite];
            middle2.anchorPoint = ccp(0,0.5);
            middle2.position = ccp(xSize,0);
            [platform addChild: middle2];
            
            xSize += [middle2 boundingBox].size.width - 1;
        }
        
        bodyWidth = (xSize + ssipadauto(10))/PTM_RATIO/2;
    }
    
    world = theWorld;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.fixedRotation = true;
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    bodyHeight = height/PTM_RATIO/2;
    
    [self createPhysicsObject];
    [self initPlatform];
}

- (void) createPhysicsObject {
    
    if (fixture != nil || bounceSensor != nil) {
        return;
    }
    
    float heightFactor = [self isOneSided] ? (THIN_BODY ? 15 : 1.15) : 1.15;
    float yPos = bodyHeight - ssipadauto(([self isOneSided] ? (THIN_BODY ? 7.5 : 15):15)/PTM_RATIO);
    
    b2PolygonShape shape;
    shape.SetAsBox(bodyWidth, bodyHeight/heightFactor, b2Vec2(bodyWidth - ssipadauto(5)/PTM_RATIO, yPos), CC_DEGREES_TO_RADIANS(0));
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
#ifdef USE_CONSISTENT_PTM_RATIO
    fixtureDef.density = 500.f;
#else
    fixtureDef.density = 500.f/ssipad(4.f, 1.f);
#endif
    fixtureDef.friction = 0.1f;//3.f;
    
    fixtureDef.filter.categoryBits = CATEGORY_FLOATING_PLATFORM;
    fixtureDef.filter.maskBits = CATEGORY_JUMPER | CATEGORY_ENEMY | CATEGORY_LOOP;
    fixture = body->CreateFixture(&fixtureDef);
    
    if (![self isOneSided]) {
        //shape.SetAsBox(0.3f, (height/PTM_RATIO/2), b2Vec2(0, 0), 0);
        b2CircleShape circShape;
        //b2PolygonShape circShape;
        //circShape.SetAsBox(0.3f, (height*0.9/PTM_RATIO/2), b2Vec2(0, 0), 0);
        circShape.m_radius = height/PTM_RATIO/2;
        //circShape.m_p = b2Vec2(-(height/PTM_RATIO/8), 0);
        fixtureDef.shape = &circShape;
        fixtureDef.friction = 0;
        fixtureDef.isSensor = true;
        fixtureDef.filter.categoryBits = CATEGORY_FLOATING_PLATFORM;
        fixtureDef.filter.maskBits = CATEGORY_JUMPER;
        bounceSensor = body->CreateFixture(&fixtureDef);
    }
}

- (CCSprite *) createMiddleSprite {
    return [CCSprite spriteWithSpriteFrameName:@"Tile_Middle.png"];
}

- (BOOL) bounceRequired {
    
    BOOL req = NO;
    
    return req;
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

// Do not override unless absolutely necessary
- (b2Vec2) previousPosition {
    return previousPosition;
}

// Do not override unless absolutely necessary
- (b2Vec2) smoothedPosition {
    return smoothedPosition;
}

// Do not override unless absolutely necessary
- (void) setPreviousPosition:(b2Vec2)p {
    previousPosition = p;
}

// Do not override unless absolutely necessary
- (void) setSmoothedPosition:(b2Vec2)p {
    smoothedPosition = p;
}

// Do not override unless absolutely necessary
- (float) previousAngle {
    return previousAngle;
}

// Do not override unless absolutely necessary
- (float) smoothedAngle {
    return smoothedAngle;
}

// Do not override unless absolutely necessary
- (void) setPreviousAngle:(float)a {
    previousAngle = a;
}

// Do not override unless absolutely necessary
- (void) setSmoothedAngle:(float)a {
    smoothedAngle = a;
}

- (b2Body*) getPhysicsBody {
    return body;
}

- (float) getHeight {
    return self.position.y + height/2 - ssipadauto(5);// + [[[GamePlayLayer sharedLayer] getPlayer] boundingBox].size.height*2;
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    //
}

- (void) setSwingerVisible:(BOOL)visible {
    //
}

- (CGPoint) getCatchPoint {
    //CCLOG(@"FP CATCH POINT %f, %f", self.position.x, self.position.y);
    return ccp(self.position.x, self.position.y + height/2);
}

- (void) initPlatform {
    //
}

- (void) breakApart {
    //
}

- (void) dealloc {
    CCLOG(@"------------------------------ Floating platform being dealloced");
    
    [platform removeAllChildrenWithCleanup:YES];
    [platform removeFromParentAndCleanup: YES];
    
    [super dealloc];
}


@end
