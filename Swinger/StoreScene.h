//
//  StoreScene.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/27/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GPImageButton.h"
#import "UserData.h"
#import "StoreItem.h"
#import "StoreManager.h"

@interface StoreScene : CCScene<CCTargetedTouchDelegate> {
 
    CGPoint touchStart;
    CGPoint lastMoved;
    CGSize screenSize;
    
    CCArray *items;
    int     currentlyVisibleItemIndex;
    
    GPImageButton *player;
    StoreChooser  *playerScreen;
    GPImageButton *powerUps;
    StoreChooser  *powerUpScreen;
    GPImageButton *lives;
    StoreChooser  *livesScreen;
    GPImageButton *bank;
    StoreChooser  *bankScreen;
    
    CCNode        *contentArea;
    StoreManager  *storeData;
    UserData      *userData;
    
    // mutable values
    CCLabelBMFont * coins;
    CCLabelBMFont * lifeLines;
    CCLabelBMFont * level;
    
}

- (void) pickPlayer;
- (void) buyPowerups;
- (void) buyLifeLines;
- (void) goToBank;
- (void) refresh;

+ (id) node;
+ (id) nodeWithScreen: (StoreItemType) screen;

@end
