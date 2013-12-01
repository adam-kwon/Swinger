//
//  WorldData.h
//  Swinger
//
//  Created by Isonguyo Udoka on 11/4/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorldData : NSObject {
    
    NSString       *name;
    NSString       *description;
    NSString       *spriteName;
    float          price;
    int            level; // level needed to unlock it
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* spriteName;
@property (nonatomic, readwrite, assign) float price;
@property (nonatomic, readwrite, assign) int level;

@end
