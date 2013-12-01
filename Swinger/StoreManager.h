//
//  StoreManager.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "WorldData.h"
#import "PowerUp.h"

@interface StoreManager : NSObject {
    
    CCArray *worldData;
    CCArray *playerSkinData;
    CCArray *powerUpData;
    CCArray *lifeLineData;
    CCArray *bankData;
    
    BOOL newItemUnlocked;
}

- (PowerUpType) getPowerUpType: (GameObjectType) powerUpCategory;
- (WorldData *) getWorldData: (NSString *) worldName;

+ (StoreManager*) sharedInstance;

@property (nonatomic, readonly) CCArray *worldData;
@property (nonatomic, readonly) CCArray *playerSkinData;
@property (nonatomic, readonly) CCArray *powerUpData;
@property (nonatomic, readonly) CCArray *lifeLineData;
@property (nonatomic, readonly) CCArray *bankData;
@property (nonatomic, readwrite, assign) BOOL newItemUnlocked;

@end
