//
//  PowerUpChooser.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/1/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StoreChooser.h"
#import "UserData.h"
#import "StoreManager.h"

@interface PowerUpChooser : StoreChooser {
    
    //UserData *userData;
    StoreManager *storeData;
    float currentHeight;
    
    //StoreItem * currItem;
}

+ (id) make: (CGSize) size store: (StoreScene*) theStore;

@end
