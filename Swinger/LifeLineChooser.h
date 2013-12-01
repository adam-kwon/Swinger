//
//  LifeLineChooser.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/3/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StoreChooser.h"
#import "UserData.h"
#import "StoreManager.h"

@interface LifeLineChooser : StoreChooser {
    
    //UserData *userData;
    StoreManager *storeData;
    float currentHeight;
}

+ (id) make: (CGSize) theSize store: (StoreScene*) theStore;

@end
