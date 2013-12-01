//
//  LevelCompleteScoreCard.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/22/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelCompleteScoreCard : CCNode {

    CGSize         screenSize;
    CCSprite      *card;
    CCLabelBMFont *score;
}

+ (id) nodeWithScore: (double) theScore;

- (void) moveTo: (CGPoint) pos;

@end
