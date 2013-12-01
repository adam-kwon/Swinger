//
//  PhysicsWorld.h
//  apocalypsemmxii
//
//  Created by Min Kwon on 6/3/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "cocos2d.h"

@class GameObject;

@interface PhysicsWorld : NSObject {
    b2World             *world;         // weak reference        
    b2Body              *groundBody;
	ContactListener     *contactListener;
    GameObject          *platform;
#if DEBUG
    GLESDebugDraw       *m_debugDraw;    
#endif    
}

+ (PhysicsWorld*) sharedWorld;
+ (void) createInstance;
- (void) setupPhysicsWorld;
- (void) setGravity:(float)gravity;
- (void) step:(ccTime)dt;
- (void) drawDebug;
- (b2World*) getWorld;

@end
