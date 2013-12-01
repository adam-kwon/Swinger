//
//  GPDummyControl.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/17/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPDummyControl.h"

// Strictly used to control touch priority
@implementation GPDummyControl

- (id) initWithTouchPriority:(int)priority swallow:(BOOL)swallowIt {
    self = [super init];
    if (self) {
        touchPriority = priority;
        swallow = swallowIt;
    }
    return self;
}

+ (id) nodeWithTouchPriority:(int)priority swallow:(BOOL)swallowIt {
    return [[[self alloc] initWithTouchPriority:priority swallow:swallowIt] autorelease];
}


- (void) onEnter {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:touchPriority swallowsTouches:swallow];
	[super onEnter];
}

- (void) onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCLOG(@"**** GPDUMMY CONTROL TOUCH BEGAN");
	return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
}

@end
