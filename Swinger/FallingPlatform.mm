//
//  FallingPlatform.m
//  Swinger
//
//  Created by Isonguyo Udoka on 8/21/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FallingPlatform.h"

@implementation FallingPlatform

@synthesize fell;

- (void) fall {
    
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(doFall) forTarget:self interval:0.25f paused:NO];
    fell = YES;
}

- (void) doFall {
    [[CCScheduler sharedScheduler] unscheduleSelector : @selector(doFall) forTarget:self];
    body->SetLinearVelocity(b2Vec2(0,-3));
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    startPosition = pos;
    
    [self moveTo:pos];
    [self show];
}

- (void) reset {
    fell = NO;
    [[CCScheduler sharedScheduler] unscheduleSelector : @selector(doFall) forTarget:self];
    body->SetLinearVelocity(b2Vec2(0,0));
    [self showAt: startPosition];
}

#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return kGameObjectFloatingPlatform;// kGameObjectFallingPlatform;
}

@end
