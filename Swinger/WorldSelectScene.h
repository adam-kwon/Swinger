//
//  WorldSelectScene.h
//  Swinger
//
//  Created by Min Kwon on 6/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCScene.h"

@interface WorldSelectScene : CCScene<CCTargetedTouchDelegate> {
    CGPoint touchStart;
    CGPoint lastMoved;
    CGSize screenSize;
    CCNode *background;
    int currentlyVisibleWorldIndex;
    CCArray *worlds;
    CCNode *dots;
}

@end
