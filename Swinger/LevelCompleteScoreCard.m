//
//  LevelCompleteScoreCard.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/22/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "LevelCompleteScoreCard.h"
#import "Constants.h"
#import "AudioEngine.h"

@implementation LevelCompleteScoreCard

+ (id) nodeWithScore:(double)theScore {
    return [[[self alloc] initWithScore: theScore] autorelease];
}

- (id) initWithScore: (double) theScore {
    self = [super init];
    if (self) {
        screenSize = [[CCDirector sharedDirector] winSize];
        card = [CCSprite spriteWithFile:@"Level2SelectThumb.png"];
        card.scale = 0.70;
        [self addChild: card z:0];
        
        score = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%1.1f", theScore] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        //score.position = ccp([card boundingBox].size.width/2, [card boundingBox].size.height/2);
        [self addChild: score z:1];
    }
    
    return self;
}

- (void) moveTo: (CGPoint) pos {
    
    self.position = ccp(pos.x, screenSize.height + [card boundingBox].size.height/2);
    
    CCMoveBy *move1 = [CCMoveBy actionWithDuration:0.1f position:ccp(0, -ssipadauto(5))];
    CCDelayTime * wait = [CCDelayTime actionWithDuration:0.1];
    CCMoveTo *move2 = [CCMoveTo actionWithDuration:0.15 position:pos];
    CCCallFunc *blop = [CCCallFunc actionWithTarget:self selector:@selector(playBlop)];
    CCSequence * seq = [CCSequence actions:move1, wait, move1, move1, wait, move2, blop, nil];
    
    [self stopAllActions];
    [self runAction: [CCEaseInOut actionWithAction:seq rate:2.0f]];
}

- (void) playBlop {
    [[AudioEngine sharedEngine] playEffect:SND_BLOP];
}

@end
