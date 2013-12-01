//
//  Block.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FloatingBlock.h"
#import "Notifications.h"

// struct used to hold physics body data for a single rope segment
typedef struct {
    b2Body *body;
    b2Fixture *fixture;
} BlockSegment;

@implementation FloatingBlock

+ (id)make:(float)theWidth {
    
    CCSprite * left = [CCSprite spriteWithFile:@"block.png"];
    CCSprite * middle = [CCSprite spriteWithFile:@"block.png"];
    CCSprite * right = [CCSprite spriteWithFile:@"block.png"];
    
    return [self make:theWidth left:left center:middle right:right];
}

- (BOOL) isOneSided {
    return NO;
}

- (CCSprite *) createMiddleSprite {
    return [CCSprite spriteWithFile:@"block.png"];
}

- (void) breakApart {
    
    breakApart = YES;
}

- (void) showParticles {
    
    if (particles == nil) {
        particles = [[NSMutableArray alloc] init];
    }
    
    CCNode * theParticles = [CCNode node];
    [self addChild: theParticles z: 1];
    
    float yPos = 0;
    for (int i = 0; i < 3; i++) {
        float xPos = 0;
        int blockNum = i*2 + 1;
        float theHeight = 0;
        
        while (xPos < width) {
            // tile particles on
            CCSprite *block1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"block%d.png", blockNum]];
            block1.anchorPoint = ccp(0,0.5);
            [particles addObject:block1];
            CCSprite *block2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"block%d.png", blockNum+1]];
            block2.anchorPoint = ccp(0,0.5);
            [particles addObject:block2];
            
            block1.position = ccp(xPos, yPos);
            xPos += [block1 boundingBox].size.width;
            [theParticles addChild: block1];
            block2.position = ccp(xPos, yPos);
            xPos += [block2 boundingBox].size.width;
            [theParticles addChild: block2];
            
            theHeight = [block1 boundingBox].size.height/2;
            
            CCMoveBy *moveLeft = [CCMoveBy actionWithDuration:0.2 position:ccp(ssipadauto(-(40 + (arc4random() % 30))), ssipadauto(25 + (arc4random() % 50)))];
            CCMoveBy *moveRight = [CCMoveBy actionWithDuration:0.2 position:ccp(ssipadauto(40 + (arc4random() % 30)), ssipadauto(25 + (arc4random() % 50)))];
            CCFadeOut *fadeOut1 = [CCFadeOut actionWithDuration:0.25];
            CCFadeOut *fadeOut2 = [CCFadeOut actionWithDuration:0.25];
            
            [block1 stopAllActions];
            [block1 runAction: [CCSpawn actions: moveLeft, fadeOut1, nil]];
            [block2 stopAllActions];
            [block2 runAction: [CCSpawn actions: moveRight, fadeOut2, nil]];
        }
        
        yPos += theHeight;
    }
}

- (void) doBreakApart {
    //
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BLOCK_BROKEN object:nil];
    [[AudioEngine sharedEngine] playEffect: SND_BLOCK];
    [self showParticles];
    if (fixture != nil) {
        body->DestroyFixture(fixture);
        fixture = nil;
    }
    
    if (bounceSensor != nil) {
        body->DestroyFixture(bounceSensor);
        bounceSensor = nil;
    }
    
    [platform setVisible: NO];
    breakApart = NO;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    [super updateObject: dt scale: scale];
    
    if (breakApart) {
        [self doBreakApart];
    }
}

- (void) show {
    
    BOOL show = fixture != nil;
    
    [platform setVisible: show];
    body->SetActive(true);
}

- (void) reset {
    
    if (particles != nil && [particles count] > 0) {
     
        for (CCSprite *sprite in particles) {
            [sprite removeFromParentAndCleanup:YES];
        }
    }
    
    [particles removeAllObjects];
    
    self.visible = YES;
    breakApart = NO;
    [self createPhysicsObject];
    [self show];
    [super reset];
}

@end
