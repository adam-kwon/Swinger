//
//  PhysicsSystem.m
//  Swinger
//
//  Created by Min Kwon on 6/16/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PhysicsSystem.h"
#import "GameObject.h"
#import "PhysicsObject.h"

PhysicsSystem *PhysicsSystem::m_pInstance = NULL;

PhysicsSystem::PhysicsSystem (): fixedTimestepAccumulator(0), fixedTimestepAccumulatorRatio(0), velocityIterations(8), positionIterations(8) {
	b2Vec2 gravity;
	gravity.Set(0.0f, -30.0f);
    
	world = new b2World(gravity);

//    world->SetContinuousPhysics(true);
    world->SetAllowSleeping(true);
	world->SetAutoClearForces (false);    

#if DEBUG
    m_debugDraw = new GLESDebugDraw(PTM_RATIO);
    world->SetDebugDraw(m_debugDraw);
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    m_debugDraw->SetFlags(flags);	
#endif

    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
}

PhysicsSystem* PhysicsSystem::Instance() {
    if (!m_pInstance) {
        m_pInstance = new PhysicsSystem();
    }
    
    return m_pInstance;
}

b2World *PhysicsSystem::getWorld(void) {
	return world;
}

PhysicsSystem::~PhysicsSystem(void) {
	CCLOG(@"DESTRUCTING PHYSICS...");
	delete world;
}

void PhysicsSystem::drawDebug() {
    world->DrawDebugData();
}

void PhysicsSystem::update(float dt) {
	// Maximum number of steps, to avoid degrading to an halt.
	const int MAX_STEPS = 5;
    
	fixedTimestepAccumulator += dt;
	const int nSteps = static_cast<int> (std::floor (fixedTimestepAccumulator / FIXED_TIME_STEP));

	// To avoid rounding errors, touches fixedTimestepAccumulator only if needed.
	if (nSteps > 0) {
		fixedTimestepAccumulator -= nSteps * FIXED_TIME_STEP;
	}
    
	//NSAssert(fixedTimestepAccumulator < (FIXED_TIME_STEP + FLT_EPSILON), @"Accumulator must have a value lesser than the fixed time step");
    
	fixedTimestepAccumulatorRatio = fixedTimestepAccumulator / FIXED_TIME_STEP;
    
	// This is similar to clamp "dt":
	// dt = std::min (dt, MAX_STEPS * FIXED_TIMESTEP)
	// but it allows above calculations of fixedTimestepAccumulator and
	// fixedTimestepAccumulatorRatio to remain unchanged.
	const int nStepsClamped = std::min(nSteps, MAX_STEPS);
	for (int i = 0; i < nStepsClamped; ++ i)
	{
		// In singleStep_() the CollisionManager could fire custom
		// callbacks that uses the smoothed states. So we must be sure
		// to reset them correctly before firing the callbacks.
		resetSmoothStates();
		singleStep(FIXED_TIME_STEP);
	}
    
	world->ClearForces ();
    
	// We "smooth" positions and orientations using
	// fixedTimestepAccumulatorRatio_ (alpha).
	smoothStates();
}

void PhysicsSystem::singleStep(float dt) {
   
	//updateControllers_ (dt);
	world->Step(dt, velocityIterations, positionIterations);
	//consumeContacts_ ();
}

void PhysicsSystem::smoothStates() {
	b2Vec2 newSmoothedPosition;
    
	const float oneMinusRatio = 1.f - fixedTimestepAccumulatorRatio;
    
	for (b2Body * b = world->GetBodyList (); b != NULL; b = b->GetNext ()) {
		if (b->GetType() == b2_staticBody || b->GetType() == b2_kinematicBody) {
			continue;
		}
        
        CCNode<GameObject, PhysicsObject> *c = (CCNode<GameObject, PhysicsObject>*)b->GetUserData();
        
		newSmoothedPosition = fixedTimestepAccumulatorRatio * b->GetPosition () + oneMinusRatio * [c previousPosition];
        
		[c setSmoothedPosition:newSmoothedPosition];
        
        [c setSmoothedAngle: fixedTimestepAccumulatorRatio * b->GetAngle () + oneMinusRatio * [c previousAngle]];
	}
}

void PhysicsSystem::resetSmoothStates() {
	b2Vec2 newSmoothedPosition;
    
	for (b2Body * b = world->GetBodyList (); b != NULL; b = b->GetNext ()) {
		if (b->GetType () == b2_staticBody || b->GetType() == b2_kinematicBody) {
			continue;
		}
        
		CCNode<GameObject, PhysicsObject> *c = (CCNode<GameObject, PhysicsObject>*)b->GetUserData();
        
		newSmoothedPosition = b->GetPosition ();
        
        [c setSmoothedPosition:newSmoothedPosition];
        [c setPreviousPosition:newSmoothedPosition];
        [c setSmoothedAngle:b->GetAngle()];
        [c setPreviousAngle:b->GetAngle()];
	}
}

