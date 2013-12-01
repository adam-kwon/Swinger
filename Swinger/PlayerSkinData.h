//
//  PlayerHeadBodyData.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "UserData.h"

@interface PlayerSkinData : NSObject {
    
    PlayerType type;
    NSString  *name;
    NSString  *description;
    NSString  *spriteName;
    float      price;
    int        level;
}

@property (nonatomic, readwrite, assign) PlayerType type;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* spriteName;
@property (nonatomic, readwrite, assign) float price;
@property (nonatomic, readwrite, assign) int level;

@end
