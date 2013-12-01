//
//  ObjectivesScreen.h
//  Swinger
//
//  Created by James Sandoz on 9/14/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "cocos2d.h"

#import "Objective.h"

@interface ObjectivesScreen : CCNode {
    
    CGSize screenSize;
    
    Objective *currentObjectives[3];
    
    id backTarget;
    SEL backAction;
    
    NSArray *allObjectives;
}

+ (id) node;

- (void) setBackTarget:(id)target action:(SEL)sel;
- (void) updateObjectives;


@end
