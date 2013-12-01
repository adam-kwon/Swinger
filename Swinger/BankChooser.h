//
//  BankChooser.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/4/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StoreChooser.h"
#import "StoreManager.h"
#import "UserData.h"

@interface BankChooser : StoreChooser {
    
    //UserData *userData;
    StoreManager *storeData;
    float currentHeight;
}

+ (id) make: (CGSize) theSize store: (StoreScene*) theStore;

@end
