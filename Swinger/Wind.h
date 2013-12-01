//
//  Wind.h
//  Swinger
//
//  Created by Isonguyo Udoka on 5/28/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "box2d.h"
#import "GameObject.h"

typedef enum {
    kDirectionN,
    kDirectionS,
    kDirectionE,
    kDirectionW,
    kDirectionNE,
    kDirectionNW,
    kDirectionSE,
    kDirectionSW
} Direction;

@interface Wind : CCSprite<GameObject>
{
    int gameObjectId;

    b2World   *world;
    b2Body    *body;
    
    Direction direction;
    float     speed; // MPH
    
    BOOL      safeToDelete;
}

- (id) initWithValues: (float) mySpeed direction: (NSString*) myDirection;
- (b2Vec2) getWindForce: (float) mass;
- (void) blow: (b2Body *) player;

@property (nonatomic, readwrite, assign) float speed;
@property (nonatomic, readwrite, assign) Direction direction;

@end
