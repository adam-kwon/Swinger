//
//  GPDummyControl.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 12/17/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "GPControl.h"

@interface GPDummyControl: CCNode<CCTargetedTouchDelegate> {
    int touchPriority;
    BOOL swallow;
}

+ (id) nodeWithTouchPriority:(int)priority swallow:(BOOL)swallowIt;

@end
