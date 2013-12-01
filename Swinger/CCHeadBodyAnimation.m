//
//  CCHeadBodyAnimation.m
//  Swinger
//
//  Created by Min Kwon on 6/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCHeadBodyAnimation.h"

@implementation CCHeadBodyAnimation
@synthesize bodyFrames = bodyFrames_;
@synthesize bodyPosition;
@synthesize bodyPositions;
@synthesize flippedBodyPosition;

+ (id) animationWithHeadFrames:(NSArray*)frames bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionRelativeToHead:(CGPoint)pos flippedBodyPositionRelativeToHead:(CGPoint)flipPos
{
	return [[[self alloc] initWithHeadFrames:frames bodyFrames:bodyFrames delay:delay bodyPositionRelativeToHead:pos flippedBodyPositionRelativeToHead:flipPos] autorelease];
}

- (id) initWithHeadFrames:(NSArray *)headFramesArray bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionRelativeToHead:(CGPoint)pos  flippedBodyPositionRelativeToHead:(CGPoint)flipPos
{
	if( (self=[super initWithFrames:headFramesArray delay:delay]) ) {		
        self.bodyFrames = [NSMutableArray arrayWithArray:bodyFrames];
        bodyPosition = pos;
        flippedBodyPosition = flipPos;
	}
	return self;
}

+ (id) animationWithHeadFrames:(NSArray*)frames bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionsRelativeToHead:(CCArray*)pos  {
	return [[[self alloc] initWithHeadFrames:frames bodyFrames:bodyFrames delay:delay bodyPositionsRelativeToHead:pos] autorelease];    
}

- (id) initWithHeadFrames:(NSArray *)headFramesArray bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionsRelativeToHead:(CCArray*)pos {
	if( (self=[super initWithFrames:headFramesArray delay:delay]) ) {		
        self.bodyFrames = [NSMutableArray arrayWithArray:bodyFrames];
        self.bodyPositions = pos;
	}
    return self;
}

-(void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
    [bodyPositions release];
    [bodyFrames_ release];
	[super dealloc];
}

@end