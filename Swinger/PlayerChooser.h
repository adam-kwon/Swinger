//
//  PlayerChooser.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"
#import "StoreChooser.h"
#import "UserData.h"
#import "StoreManager.h"

@interface PlayerChooser : StoreChooser {
    
    //UserData *userData;
    StoreManager *storeData;
    float currentHeight;
    
    //StoreItem * currItem;
}

+ (id) make: (CGSize) theSize store: (StoreScene*) theStore;

@end
