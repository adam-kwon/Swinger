//
//  PhysicsSystem.h
//  Swinger
//
//  Created by Min Kwon on 6/16/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"

#define FIXED_TIME_STEP (1.f/60.f)

class PhysicsSystem {
protected:
	float velocityIterations;
    float positionIterations;
	b2World* world;
    GLESDebugDraw *m_debugDraw;
    ContactListener *contactListener;
public:
    static PhysicsSystem *Instance();
    float fixedTimestepAccumulator;
	float fixedTimestepAccumulatorRatio;
    
	b2World *getWorld(void);
	void update(float dt);
	void singleStep(float dt);
	void smoothStates();
	void resetSmoothStates();
    void drawDebug();
    
private:
	PhysicsSystem(void);
	~PhysicsSystem(void);
    static PhysicsSystem *m_pInstance;
};
