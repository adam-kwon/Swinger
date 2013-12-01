//
//  Loop.h
//  Swinger
//
//  Created by Isonguyo Udoka on 8/13/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//
//  Inspriation: http://www.youtube.com/watch?v=vqTtoAZdOSc
//               http://www.youtube.com/watch?feature=endscreen&NR=1&v=7PgVFwsrrYk 
//               http://www.youtube.com/watch?v=1zMHaHPXqqg
//

#import "BaseCatcherObject.h"
#import "Player.h"

typedef enum {
    kLoopNone,
    kLoopPlayerLoaded,
    kLoopLooping,
    kLoopFinished
} LoopState;

@interface Loop : BaseCatcherObject {
    
    LoopState state;
    
    CCSprite  *loopSprite;
    
    float     radius;
    float     speed;
    
    b2Body          *carBody;
    b2Fixture       *carFixture;
    b2Body          *anchor;
    b2Fixture       *loopFixture;
    b2WeldJoint     *playerJoint;
    b2WeldJoint     *carJoint;
    b2RevoluteJoint *loopJoint;
    
    Player    *player;
}

+ (id) make: (float) theRadius speed: (float) theSpeed;
- (void) loop: (Player *) thePlayer;

@property (nonatomic, readwrite, assign) float radius;
@property (nonatomic, readwrite, assign) float speed;

@end
