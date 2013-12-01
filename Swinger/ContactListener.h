//
//  ContactListener.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Box2D.h"
#import "GameObject.h"

class ContactListener : public b2ContactListener {
    
public:

	ContactListener();
	~ContactListener();
    
    // Game play objects
    void handleJumperRopeCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location, b2Body *cBody);
    void handleJumperCannonCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperElephantCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperFinalPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperGroundCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperSpringCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperWheelCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    void handleJumperFloatingPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    void handleJumperLoopCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    
    // Collectibles
    void handleJumperStarCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperMagnetCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperShieldCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperSpeedBoostCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperJetPackCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperAngerPotionCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperCoinDoublerCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperMissileLauncherCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleMissileEnemyCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperGrenadeLauncherCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    
    // Enemies
    void handleJumperBoulderCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    void handleJumperHunterCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    void handleJumperInsectCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    void handleJumperSawCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    void handleJumperBarrelCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    
	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
    
private:
    
    bool allowPlatformCollision(b2Contact *contact);
};

