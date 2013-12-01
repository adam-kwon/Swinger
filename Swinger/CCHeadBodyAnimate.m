//
//  CCHeadBodyAnimate.m
//  Swinger
//
//  Created by Min Kwon on 6/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCHeadBodyAnimate.h"
#import "CCHeadBodyAnimation.h"
#import "Constants.h"

@implementation CCHeadBodyAnimate

@synthesize headBodyAnimation = headBodyAnimation_;


+(id) actionWithHeadBodyAnimation:(CCAnimation*)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithHeadBodyAnimation:anim restoreOriginalFrame:b] autorelease];
}

-(id) initWithHeadBodyAnimation:(CCAnimation*)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
    
	if( (self=[super initWithDuration: [[anim frames] count] * [anim delay]]) ) {
        
		restoreOriginalFrame_ = b;
        self.headBodyAnimation = (CCHeadBodyAnimation*) anim;
		origFrame_ = nil;
        origBodyFrame_ = nil;
	}
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCSprite *sprite = target_;
    bodySprite = (CCSprite*)[sprite getChildByTag:PLAYER_BODY_SPRITE_TAG];
    positions = [headBodyAnimation_ bodyPositions];
    
    if (positions != nil) {
        NSValue *val = [positions objectAtIndex:0];
        bodySprite.position = [val CGPointValue];
    } else if (bodySprite.flipX == NO) {
        bodySprite.position = [headBodyAnimation_ bodyPosition];
    } else if (bodySprite.flipX == YES) {
        bodySprite.position = [headBodyAnimation_ flippedBodyPosition];
    }
    
	[origFrame_ release];
    [origBodyFrame_ release];
    
	if( restoreOriginalFrame_ ) {
		origFrame_ = [[sprite displayedFrame] retain];
        
        origBodyFrame_ = [[bodySprite displayedFrame] retain];
    }
}

-(void) stop
{
	if( restoreOriginalFrame_ ) {
        [bodySprite setDisplayFrame:origBodyFrame_];
	}
	
	[super stop];
}

- (void) update:(ccTime)t {
	NSArray *frames = [headBodyAnimation_ frames];
    NSArray *bodyFrames = [headBodyAnimation_ bodyFrames];
	NSUInteger numberOfFrames = [frames count];
	
	NSUInteger idx = t * numberOfFrames;
    
	if( idx >= numberOfFrames )
		idx = numberOfFrames -1;
	
	CCSprite *sprite = target_;
	if (! [sprite isFrameDisplayed: [frames objectAtIndex: idx]] ) {
		[sprite setDisplayFrame: [frames objectAtIndex:idx]];
        
        if (positions != nil) {
            NSValue *val = [positions objectAtIndex:idx];
            bodySprite.position = [val CGPointValue];
        }
        [bodySprite setDisplayFrame:[bodyFrames objectAtIndex:idx]];
    }
}

- (void) dealloc {
    [headBodyAnimation_ release];
    [origBodyFrame_ release];
    [super dealloc];
}
@end