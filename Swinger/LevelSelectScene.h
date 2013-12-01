//
//  LevelSelectScene.h
//  Swinger
//
//  Created by Min Kwon on 6/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCScene.h"

@interface LevelSelectScene : CCScene<CCTargetedTouchDelegate>  {
    CGSize screenSize;
    CCNode *background;
    
    CGPoint touchStart;
    CGPoint lastMoved;
    
    int startX;
    int spriteIndex;
    CCArray *levels;
    
    NSString *world;
    
    CCNode *dots;
}

+ (id) nodeWithWorld:(NSString*)worldName;

@end
