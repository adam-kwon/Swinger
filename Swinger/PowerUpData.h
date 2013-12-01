//
//  PowerUpData.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/1/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Constants.h"
#import "PowerUp.h"

@interface PowerUpData : NSObject {
    
    GameObjectType category; // magnet, shield etc..
    PowerUpType    type; // short, medium, long etc..
    NSString       *name;
    NSString       *description;
    NSString       *spriteName;
    float          price;
    int            level; // level needed to unlock it
}

@property (nonatomic, readwrite, assign) GameObjectType category;
@property (nonatomic, readwrite, assign) PowerUpType type;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* spriteName;
@property (nonatomic, readwrite, assign) float price;
@property (nonatomic, readwrite, assign) int level;

@end
