//
//  Objective.h
//  Swinger
//
//  Created by James Sandoz on 9/15/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "ObjectiveData.h"

@interface Objective : CCNode {
    
    // Holds the actual objective data values from the plist
    ObjectiveData *objectiveData;
    
    // UI elements
    CCLayerColor *background;
    CCSprite *icon;
    CCLabelBMFont *descriptionLabel;
    CCLabelBMFont *rewardLabel;
    NSArray *borders;
}

+ (id) nodeWithObj:(ObjectiveData *)objData;
- (id) initWithObj:(ObjectiveData *)objData;

- (void) showCompleted;

@end
