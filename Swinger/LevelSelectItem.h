//
//  LevelSelectItem.h
//  Swinger
//
//  Created by Min Kwon on 7/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "CCSprite.h"
#import "CCTouchDelegateProtocol.h"

@interface LevelSelectItem : CCNode<CCTargetedTouchDelegate>  {
    NSString *worldName;
    int level;
    BOOL locked;
    
    CGPoint touchStart;
    CGPoint lastMoved;

    CCSprite *thumbNailSprite;
}

+ (id) nodeWithWorldName:(NSString*)worldName level:(int)levelNumber;

@property (nonatomic, readonly) NSString *worldName;
@property (nonatomic, readonly) int level;

@end
