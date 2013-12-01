//
//  StoreChooser.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@class StoreItem;
@class StoreScene;
@class UserData;

@interface StoreChooser : CCNode<CCTargetedTouchDelegate> {
    
    StoreScene * store;
    int currentlyVisibleItemIndex;
    CCArray  *items;
    
    CGPoint touchStart;
    CGPoint lastMoved;
    
    UserData * userData;
    StoreItem *currItem;
}

- (id) initWithSize: (CGSize) theSize store: (StoreScene*) theStore;

- (BOOL) select: (StoreItem*)item;
- (BOOL) buy: (StoreItem*)item;
- (void) refresh;

@end
