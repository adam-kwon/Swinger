//
//  CurvedPlatform.h
//  Swinger
//
//  Created by James Sandoz on 8/6/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

#import "BaseCatcherObject.h"
#import "FloatingPlatform.h"

@interface CurvedPlatform : FloatingPlatform {
    NSString *name;
    
    CCSprite *sprite;
}

+(id) make:(NSString *)name;

@end
