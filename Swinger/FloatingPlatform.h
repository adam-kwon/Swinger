//
//  FloatingPlatform.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/3/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "BaseCatcherObject.h"
#import "Player.h"
#import "CCSprite.h"

@interface FloatingPlatform : BaseCatcherObject {
    
    CCNode    *platform;
    float     width;
    float     height;
    b2Fixture *bounceSensor;
    b2Fixture *fixture;
    
    float32 bodyWidth;
    float32 bodyHeight;
    
    CCSprite * left;
    CCSprite * middle;
    CCSprite * right;
    
    float elevatorSpeed;
    float elevatorDistance;
    float elevatorMinHeight;
    float elevatorMaxHeight;
}

- (void) initPlatform;
- (BOOL) bounceRequired;
- (void) showAt:(CGPoint)pos;
- (void) destroyPhysicsObject;
- (BOOL) isOneSided;
- (void) reset;
- (CCSprite *) createMiddleSprite;
- (void) breakApart;
- (void) createPhysicsObject;

+ (id) make: (float) theWidth;
+ (id) make: (float) theWidth left: (CCSprite *) left center: (CCSprite *) center right: (CCSprite *) right;

@property (nonatomic, readwrite, assign) float width;
@property (nonatomic, readwrite, assign) float elevatorDistance;
@property (nonatomic, readwrite, assign) float elevatorSpeed;

@end
