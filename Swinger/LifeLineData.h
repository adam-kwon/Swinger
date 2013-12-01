//
//  LifeLineData.h
//  Swinger
//
//  Created by Isonguyo Udoka on 9/2/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LifeLineData : NSObject {
    
    int       numLives;
    NSString  *description;
    NSString  *spriteName;
    float      price;
    int       level; // for bonus lives, the level which they are awarded to the player
}

@property (nonatomic, readwrite, assign) int numLives;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* spriteName;
@property (nonatomic, readwrite, assign) float price;
@property (nonatomic, readwrite, assign) int level;

@end
