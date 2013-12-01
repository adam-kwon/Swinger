//
//  WorldSelectItem.h
//  Swinger
//
//  Created by Min Kwon on 7/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "GPImageButton.h"

@interface WorldSelectItem : CCNode<CCTargetedTouchDelegate> {
    NSString *worldName;
    CCSprite *thumbNailSprite;
        
    CGPoint touchStart;
    CGPoint lastMoved;
    
    CCSprite *lock;
    BOOL locked;
    
    GPImageButton * unlock;
}

+ (id) nodeWithWorldName:(NSString*)world;

@property (nonatomic, readonly) NSString *worldName;

@end
