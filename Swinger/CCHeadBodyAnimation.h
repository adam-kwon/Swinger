//
//  CCHeadBodyAnimation.h
//  Swinger
//
//  Created by Min Kwon on 6/26/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//
//  Custom CCAnimation to support separate head and body animation system.

@interface CCHeadBodyAnimation : CCAnimation
{
    NSMutableArray *bodyFrames_;
    CGPoint bodyPosition;
    CGPoint flippedBodyPosition;
    CCArray *bodyPositions;
    //XXX Should probably add support for flipped body position array for consistency
}

@property (nonatomic, readwrite, retain) NSMutableArray *bodyFrames;
@property (nonatomic, readwrite, retain) CCArray *bodyPositions;
@property (nonatomic, readwrite, assign) CGPoint bodyPosition;
@property (nonatomic, readwrite, assign) CGPoint flippedBodyPosition;

+ (id) animationWithHeadFrames:(NSArray*)frames bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionRelativeToHead:(CGPoint)pos flippedBodyPositionRelativeToHead:(CGPoint)flipPos;
- (id) initWithHeadFrames:(NSArray *)frames bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionRelativeToHead:(CGPoint)pos flippedBodyPositionRelativeToHead:(CGPoint)flipPos;

+ (id) animationWithHeadFrames:(NSArray*)frames bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionsRelativeToHead:(CCArray*)pos;
- (id) initWithHeadFrames:(NSArray *)frames bodyFrames:(NSArray*)bodyFrames delay:(float)delay bodyPositionsRelativeToHead:(CCArray*)pos;


@end