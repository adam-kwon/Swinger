//
//  ContactListener.m
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "ContactListener.h"
#import "Constants.h"

#import "CatcherGameObject.h"
#import "RopeSwinger.h"
#import "Player.h"
#import "Cannon.h"
#import "Spring.h"
#import "Star.h"
#import "Coin.h"
#import "AudioEngine.h"
#import "GamePlayLayer.h"
#import "MainGameScene.h"
#import "Elephant.h"
#import "Wheel.h"
#import "FinalPlatform.h"
#import "FloatingPlatform.h"
#import "Magnet.h"
#import "CurvedPlatform.h"
#import "Loop.h"
#import "Insect.h"
#import "Hunter.h"
#import "Boulder.h"
#import "Shield.h"
#import "SpeedBoost.h"
#import "JetPack.h"
#import "AngerPotion.h"
#import "CoinDoubler.h"
#import "Saw.h"
#import "MissileLauncher.h"
#import "GrenadeLauncher.h"
#import "Missile.h"
#import "Enemy.h"
#import "Barrel.h"

#define IS_CATCHER(x,y)                     ([x gameObjectType] == kGameObjectCatcher || [y gameObjectType] == kGameObjectCatcher)
#define IS_JUMPER(x,y)                      ([x gameObjectType] == kGameObjectJumper || [y gameObjectType] == kGameObjectJumper)
#define IS_GROUND(x,y)                      ([x gameObjectType] == kGameObjectGround || [y gameObjectType] == kGameObjectGround)
#define IS_FINAL_PLATFORM(x,y)              ([x gameObjectType] == kGameObjectFinalPlatform || [y gameObjectType] == kGameObjectFinalPlatform)
#define IS_FLOATING_PLATFORM(x,y)           ([x gameObjectType] == kGameObjectFloatingPlatform || [y gameObjectType] == kGameObjectFloatingPlatform)
#define IS_CURVED_PLATFORM(x,y)             ([x gameObjectType] == kGameObjectCurvedPlatform || [y gameObjectType] == kGameObjectCurvedPlatform)
#define IS_FALLING_PLATFORM(x,y)            ([x gameObjectType] == kGameObjectFallingPlatform || [y gameObjectType] == kGameObjectFallingPlatform)
#define IS_CANNON(x,y)                      ([x gameObjectType] == kGameObjectCannon || [y gameObjectType] == kGameObjectCannon)
#define IS_SPRING(x,y)                      ([x gameObjectType] == kGameObjectSpring || [y gameObjectType] == kGameObjectSpring)
#define IS_ELEPHANT(x,y)                    ([x gameObjectType] == kGameObjectElephant || [y gameObjectType] == kGameObjectElephant)
#define IS_WHEEL(x,y)                       ([x gameObjectType] == kGameObjectWheel || [y gameObjectType] == kGameObjectWheel)
#define IS_LOOP(x,y)                        ([x gameObjectType] == kGameObjectLoop || [y gameObjectType] == kGameObjectLoop)

// Collectibles
#define IS_STAR(x,y)                        ([x gameObjectType] == kGameObjectStar || [y gameObjectType] == kGameObjectStar)
#define IS_COIN(x,y)                        (([x gameObjectType] == kGameObjectCoin || [y gameObjectType] == kGameObjectCoin) \
                                            || ([x gameObjectType] == kGameObjectCoin5 || [y gameObjectType] == kGameObjectCoin5) \
                                            || ([x gameObjectType] == kGameObjectCoin10 || [y gameObjectType] == kGameObjectCoin10))
#define IS_MAGNET(x,y)                      ([x gameObjectType] == kGameObjectMagnet || [y gameObjectType] == kGameObjectMagnet)
#define IS_SHIELD(x,y)                      ([x gameObjectType] == kGameObjectShield || [y gameObjectType] == kGameObjectShield)
#define IS_SPEED_BOOST(x,y)                 ([x gameObjectType] == kGameObjectSpeedBoost || [y gameObjectType] == kGameObjectSpeedBoost)
#define IS_JET_PACK(x,y)                    ([x gameObjectType] == kGameObjectJetPack || [y gameObjectType] == kGameObjectJetPack)
#define IS_ANGER_POTION(x,y)                ([x gameObjectType] == kGameObjectAngerPotion || [y gameObjectType] == kGameObjectAngerPotion)
#define IS_COIN_DOUBLER(x,y)                ([x gameObjectType] == kGameObjectCoinDoubler || [y gameObjectType] == kGameObjectCoinDoubler)
#define IS_MISSILE_LAUNCHER(x,y)            ([x gameObjectType] == kGameObjectMissileLauncher || [y gameObjectType] == kGameObjectMissileLauncher)
#define IS_GRENADE_LAUNCHER(x,y)            ([x gameObjectType] == kGameObjectGrenadeLauncher || [y gameObjectType] == kGameObjectGrenadeLauncher)
#define IS_MISSILE(x,y)                     ([x gameObjectType] == kGameObjectMissile || [y gameObjectType] == kGameObjectMissile)

// Enemies
#define IS_BOULDER(x,y)                     ([x gameObjectType] == kGameObjectBoulder || [y gameObjectType] == kGameObjectBoulder)
#define IS_HUNTER(x,y)                      ([x gameObjectType] == kGameObjectHunter || [y gameObjectType] == kGameObjectHunter)
#define IS_INSECT(x,y)                      ([x gameObjectType] == kGameObjectInsect || [y gameObjectType] == kGameObjectInsect)
#define IS_SAW(x,y)                         ([x gameObjectType] == kGameObjectSaw || [y gameObjectType] == kGameObjectSaw)
#define IS_BARREL(x,y)                      ([x gameObjectType] == kGameObjectOilBarrel || [y gameObjectType] == kGameObjectOilBarrel)

#define GAMEOBJECT_OF_TYPE(class, type, o1, o2)    (class*)([o1 gameObjectType] == type ? o1 : o2)


ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}

void ContactListener::handleJumperMagnetCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Magnet *magnet = GAMEOBJECT_OF_TYPE(Magnet, kGameObjectMagnet, o1, o2);
    [magnet activate];
}

void ContactListener::handleJumperStarCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Star *star = GAMEOBJECT_OF_TYPE(Star, kGameObjectStar, o1, o2);
    [star collect];
}

void ContactListener::handleJumperShieldCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Shield *shield = GAMEOBJECT_OF_TYPE(Shield, kGameObjectShield, o1, o2);
    [shield activate];
}

void ContactListener::handleJumperSpeedBoostCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    SpeedBoost *boost = GAMEOBJECT_OF_TYPE(SpeedBoost, kGameObjectSpeedBoost, o1, o2);
    [boost activate];
}

void ContactListener::handleJumperJetPackCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    JetPack *jet = GAMEOBJECT_OF_TYPE(JetPack, kGameObjectJetPack, o1, o2);
    [jet activate];
}

void ContactListener::handleJumperAngerPotionCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    AngerPotion *potion = GAMEOBJECT_OF_TYPE(AngerPotion, kGameObjectAngerPotion, o1, o2);
    [potion activate];
}

void ContactListener::handleJumperCoinDoublerCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    CoinDoubler *doubler = GAMEOBJECT_OF_TYPE(CoinDoubler, kGameObjectCoinDoubler, o1, o2);
    [doubler activate];
}

void ContactListener::handleJumperMissileLauncherCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    MissileLauncher *launcher = GAMEOBJECT_OF_TYPE(MissileLauncher, kGameObjectMissileLauncher, o1, o2);
    [launcher activate];
}

void ContactListener::handleJumperGrenadeLauncherCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    GrenadeLauncher *launcher = GAMEOBJECT_OF_TYPE(GrenadeLauncher, kGameObjectGrenadeLauncher, o1, o2);
    [launcher activate];
}

void ContactListener::handleMissileEnemyCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Missile *missile = GAMEOBJECT_OF_TYPE(Missile, kGameObjectMissile, o1, o2);
    Enemy *enemy = nil;
    
    if ([(GameObject*)o1 gameObjectType] == kGameObjectMissile) {
        enemy = (Enemy *) o2;
    } else {
        enemy = (Enemy *) o1;
    }
    
    [missile destroyTarget: enemy];
}

void ContactListener::handleJumperRopeCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location, b2Body *cBody) {

    RopeSwinger *catcher = GAMEOBJECT_OF_TYPE(RopeSwinger, kGameObjectCatcher, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
//    ContactLocation where = kContactTop;
//    if (userData != NULL) {
//        where = *((ContactLocation *)userData);
//    }
    
    if (![catcher caughtPlayer]) {
        [catcher setCatchBody:cBody];
        [jumper catchCatcher:catcher at:location];
    }
}

void ContactListener::handleJumperSpringCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Spring *spring = GAMEOBJECT_OF_TYPE(Spring, kGameObjectSpring, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:spring];
}

void ContactListener::handleJumperWheelCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    Wheel *wheel = GAMEOBJECT_OF_TYPE(Wheel, kGameObjectWheel, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:wheel at: location];
}

void ContactListener::handleJumperFinalPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    FinalPlatform *fp = GAMEOBJECT_OF_TYPE(FinalPlatform, kGameObjectFinalPlatform, o1, o2);
    
    [jumper catchCatcher:fp];
}

void ContactListener::handleJumperGroundCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {    
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    // Only die when player has started jumping, else game will prematurely end
    // because the physics body will hit the ground before the mouse joint has
    // time to bring the bodies to their proper positions
    if (/*[jumper receivedFirstJumpInput] &&*/ jumper.state != kSwingerFell /*&& jumper.state != kSwingerDizzy*/) {
        //jumper.state = kSwingerFell;
    }
}

void ContactListener::handleJumperCannonCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    Cannon *cannon = GAMEOBJECT_OF_TYPE(Cannon, kGameObjectCannon, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:cannon];
}

void ContactListener::handleJumperElephantCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    Elephant *elephant = GAMEOBJECT_OF_TYPE(Elephant, kGameObjectElephant, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:elephant];
}

void ContactListener::handleJumperFloatingPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    FloatingPlatform *platform = jumper == o1 ? (FloatingPlatform *) o2 : (FloatingPlatform *) o1;//GAMEOBJECT_OF_TYPE(FloatingPlatform, kGameObjectFloatingPlatform, o1, o2);
    
    jumper.lastPlatform = platform; // setting this here because presolve gets called multiple times before the next time step so this might not be set in time
    [jumper catchCatcher:platform at: location];    
}

void ContactListener::handleJumperLoopCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    Loop *loop = GAMEOBJECT_OF_TYPE(Loop, kGameObjectLoop, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:loop];
}

// Enemies
void ContactListener::handleJumperBoulderCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    Boulder *boulder = GAMEOBJECT_OF_TYPE(Boulder, kGameObjectBoulder, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    if ([boulder canKill: jumper] && [boulder willKill: jumper]) {
        jumper.fallThrough = YES;
    }
    
    [jumper catchCatcher:boulder at: location];
}

void ContactListener::handleJumperHunterCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    
    Hunter *hunter = GAMEOBJECT_OF_TYPE(Hunter, kGameObjectHunter, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    if ([hunter canKill: jumper] && [hunter willKill: jumper]) {
        jumper.fallThrough = YES;
    }
    
    [jumper catchCatcher:hunter];
}

void ContactListener::handleJumperInsectCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    
    Insect *insect = GAMEOBJECT_OF_TYPE(Insect, kGameObjectInsect, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    if ([insect canKill: jumper] && [insect willKill: jumper]) {
        jumper.fallThrough = YES;
    }
    
    [jumper catchCatcher:insect];
}

void ContactListener::handleJumperSawCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    
    Saw *saw = GAMEOBJECT_OF_TYPE(Saw, kGameObjectSaw, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    if ([saw canKill: jumper] && [saw willKill: jumper]) {
        jumper.fallThrough = YES;
    }
    
    [jumper catchCatcher:saw];
}

void ContactListener::handleJumperBarrelCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    
    Barrel *barrel = GAMEOBJECT_OF_TYPE(Barrel, kGameObjectOilBarrel, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    if ([barrel canKill: jumper] && [barrel willKill: jumper]) {
        jumper.fallThrough = YES;
    }
    
    [jumper catchCatcher:barrel];
}

BOOL canEnemyKillPlayer(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Player *player = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    Enemy * enemy = (Enemy *) (player == o1 ? o2 : o1);
    
    return [enemy canKill: player];
}

void ContactListener::BeginContact(b2Contact *contact) {
    
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    //CCLOG(@"BeginContact:  %@(%d)  %@(%d)\n", o1, [o1 gameObjectType] , o2, [o2 gameObjectType]);
    
    b2Manifold* manifold = contact->GetManifold();
    //b2Vec2 contactPoint = manifold->localPoint;
    
    //CCLOG(@"CONTACT POINT: %f, %f", contactPoint.x*PTM_RATIO, contactPoint.y*PTM_RATIO);

    if (IS_JUMPER(o1, o2)) {
        Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
        
        if (jumper.fallThrough) {
            
            if (IS_FLOATING_PLATFORM(o1, o2) ||
                IS_CURVED_PLATFORM(o1, o2) ||
                IS_FALLING_PLATFORM(o1, o2)) {
                
                if (!allowPlatformCollision(contact)) {
                    //CCLOG(@"FALLING THROUGH PLATFORM!");
                    return;
                }
            } else if (IS_HUNTER(o1, o2))  {
                //CCLOG(@"IS HUNTER IN COLLISSION");
                //jumper.lastPlatform = nil; // force the floating platform colission to be 
                this->handleJumperHunterCollision(o1,o2,CGPointZero);
            } else if (IS_INSECT(o1, o2))  {
                //CCLOG(@"IS HUNTER IN COLLISSION");
                //jumper.lastPlatform = nil; // force the floating platform colission to be 
                this->handleJumperInsectCollision(o1,o2,CGPointZero);
            } else if (IS_SAW(o1, o2))  {
                //CCLOG(@"IS HUNTER IN COLLISSION");
                //jumper.lastPlatform = nil; // force the floating platform colission to be 
                this->handleJumperSawCollision(o1,o2,CGPointZero);
            } else if (IS_BARREL(o1, o2)) {
                CGPoint loc = CGPointZero;
                
                if (contact->GetFixtureA()->IsSensor() || contact->GetFixtureB()->IsSensor()) {
                    //Barrel *barrel = GAMEOBJECT_OF_TYPE(Barrel, kGameObjectOilBarrel, o1, o2);
                    //[barrel skid];
                    loc = ccp(-1,-1);
                } else {
                    
                }
                
                this->handleJumperBarrelCollision(o1,o2,loc);
            }else if (IS_MAGNET(o1, o2)) {
                this->handleJumperMagnetCollision(o1, o2);
            } else if (IS_SHIELD(o1, o2)) {
                this->handleJumperShieldCollision(o1, o2);
            } else if (IS_SPEED_BOOST(o1, o2)) {
                this->handleJumperSpeedBoostCollision(o1, o2);
            } else if (IS_JET_PACK(o1, o2)) {
                this->handleJumperJetPackCollision(o1, o2);
            } else if (IS_ANGER_POTION(o1, o2)) {
                this->handleJumperAngerPotionCollision(o1, o2);
            } else if (IS_COIN_DOUBLER(o1, o2)) {
                this->handleJumperCoinDoublerCollision(o1, o2);
            } else if (IS_MISSILE_LAUNCHER(o1, o2)) {
                this->handleJumperMissileLauncherCollision(o1, o2);
            } else if (IS_GRENADE_LAUNCHER(o1, o2)) {
                this->handleJumperGrenadeLauncherCollision(o1, o2);
            } else {
                
                bool catchPlayer = false;
                
                if (IS_CANNON(o1,o2) || IS_CATCHER(o1,o2)) {
                    catchPlayer = true;
                    jumper.fallThrough = NO;
                }
                
                contact->SetEnabled(catchPlayer);
                
                if (!catchPlayer)
                    return;
            }
            
            //contact->SetEnabled(true);
            //return;
        }
        
        if (IS_CATCHER(o1, o2)) {
            
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
            
            // get the rope body with which the collision occurred
            b2Body *cBody;
            if ([o1 gameObjectType] == kGameObjectCatcher) {
                cBody = contact->GetFixtureA()->GetBody();
            } else {
                cBody = contact->GetFixtureB()->GetBody();
            }
            this->handleJumperRopeCollision(o1, o2, cPoint, cBody);
        } else if (IS_GROUND(o1, o2)) {
            this->handleJumperGroundCollision(o1, o2);            
        } else if (IS_FINAL_PLATFORM(o1, o2)) {
            
            if (!allowPlatformCollision(contact)) {
                return;
            }
            
            b2WorldManifold worldManifold;
            contact->GetWorldManifold(&worldManifold);
            b2Vec2 worldNormal = worldManifold.normal;
            CCLOG(@"*********************************************Worldnormalx greater 0 x=%f y=%f", worldNormal.x, worldNormal.y);
            
            if (worldNormal.y >= 0.9999) {
                CCLOG(@"Worldnormalx greater 0");
                this->handleJumperFinalPlatformCollision(o1, o2);
            }            
        } else if (IS_CANNON(o1, o2)) {
            this->handleJumperCannonCollision(o1, o2);            
        } else if (IS_LOOP(o1, o2)) {
            this->handleJumperLoopCollision(o1, o2);
        } else if (IS_SPRING(o1, o2)) {
            this->handleJumperSpringCollision(o1, o2);            
        } else if (IS_WHEEL(o1, o2)) {
            // get world location of collision                
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            
            this->handleJumperWheelCollision(o1, o2, ccp(location.x*PTM_RATIO, location.y*PTM_RATIO));
        } else if (IS_STAR(o1, o2)) {
            this->handleJumperStarCollision(o1, o2);
        }
        else if (IS_MAGNET(o1, o2)) {
            this->handleJumperMagnetCollision(o1, o2);
        }
        else if (IS_SHIELD(o1, o2)) {
            this->handleJumperShieldCollision(o1, o2);
        }
        else if (IS_SPEED_BOOST(o1, o2)) {
            this->handleJumperSpeedBoostCollision(o1, o2);
        }
        else if (IS_JET_PACK(o1, o2)) {
            this->handleJumperJetPackCollision(o1, o2);
        }
        else if (IS_ANGER_POTION(o1, o2)) {
            this->handleJumperAngerPotionCollision(o1, o2);
        }
        else if (IS_COIN_DOUBLER(o1, o2)) {
            this->handleJumperCoinDoublerCollision(o1, o2);
        }
        else if (IS_MISSILE_LAUNCHER(o1, o2)) {
            this->handleJumperMissileLauncherCollision(o1, o2);
        }
        else if (IS_GRENADE_LAUNCHER(o1, o2)) {
            this->handleJumperGrenadeLauncherCollision(o1, o2);
        }
        else if (IS_ELEPHANT(o1, o2)) {
            this->handleJumperElephantCollision(o1, o2);
        }
        else if (IS_FLOATING_PLATFORM(o1, o2) ||
                 IS_CURVED_PLATFORM(o1, o2)) {
            CGPoint cPoint = ccp(-1,-1);
            
            if (contact->GetFixtureA()->IsSensor() || contact->GetFixtureB()->IsSensor()) {
                [[MainGameScene sharedScene] shake:2 duration:0.2];
            } else {
                b2WorldManifold * worldManifold = new b2WorldManifold();
                contact->GetWorldManifold(worldManifold);
                b2Vec2 location = worldManifold->points[0];
                cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
                
                if (!allowPlatformCollision(contact)) {
                    //CCLOG(@"FALLIGN THROUGH PLATFORM!");
                    return;
                }
            }
            
            this->handleJumperFloatingPlatformCollision(o1, o2, cPoint);
        } else if (IS_BOULDER(o1, o2)) {
            // get world location of collision                
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
            
            this->handleJumperBoulderCollision(o1, o2, ccp(location.x*PTM_RATIO, location.y*PTM_RATIO));
        } else if (IS_HUNTER(o1, o2))  {
            
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
            //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
            
            this->handleJumperHunterCollision(o1,o2,cPoint);
        } else if (IS_INSECT(o1, o2)) {
            // get world location of collision                
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
            //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
            
            this->handleJumperInsectCollision(o1, o2, cPoint);
        } else if (IS_SAW(o1, o2)) {
            // get world location of collision                
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
            //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
            
            this->handleJumperSawCollision(o1, o2, cPoint);
        } else if (IS_BARREL(o1, o2)) {
            if (contact->GetFixtureA()->IsSensor() || contact->GetFixtureB()->IsSensor()) {
                Barrel *barrel = GAMEOBJECT_OF_TYPE(Barrel, kGameObjectOilBarrel, o1, o2);
                [barrel skid];
            } else {
                // get world location of collision
                b2WorldManifold * worldManifold = new b2WorldManifold();
                contact->GetWorldManifold(worldManifold);
                b2Vec2 location = worldManifold->points[0];
                CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
                //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
                
                this->handleJumperBarrelCollision(o1, o2, cPoint);
            }
        }
    } else if (IS_FLOATING_PLATFORM(o1, o2) || IS_CURVED_PLATFORM(o1, o2) || IS_FALLING_PLATFORM(o1, o2)) {
        
        if (IS_BOULDER(o1, o2)) {
            // shake screen when boulder collides with platform
            [[GamePlayLayer sharedLayer] shake: 0.05f];
        }  else if (IS_HUNTER(o1, o2)) {
            //
            Hunter * b = GAMEOBJECT_OF_TYPE(Hunter, kGameObjectHunter, o1, o2);
            
            if (b.state == kEnemyStateDead) {
               // contact->SetEnabled(false);
                [b collideWithNothing];
            }
        }
    } else if (IS_MISSILE(o1,o2)) {
        
        if ([(GameObject*)o1 gameObjectType] == kGameObjectMissile &&
            [(GameObject*)o2 gameObjectType] == kGameObjectMissile) {
            
        } else {
            this->handleMissileEnemyCollision(o1, o2);
        }
    } else if ([(GameObject*)o1 gameObjectType] == kGameObjectHunter &&
               [(GameObject*)o2 gameObjectType] == kGameObjectHunter) {
        // MAKE ENEMIES FALL LIKE DOMINOS!!!
        Hunter * a = (Hunter*) o1;
        Hunter * b = (Hunter*) o2;
        
        if (a.state != kEnemyStateDead) {
            [a die];
            [b collideWithNothing];
        } else if (b.state != kEnemyStateDead) {
            [b die];
            [a collideWithNothing];
        }
    }
}

void ContactListener::EndContact(b2Contact *contact) {
//  CCNode *o1 = (CCNode*)contact->GetFixtureA()->GetBody()->GetUserData();
//	CCNode *o2 = (CCNode*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    //CCLOG(@"EndContact:  %@  %@\n", o1, o2);

}

bool ContactListener::allowPlatformCollision(b2Contact *contact/*, Player *jumper, FloatingPlatform * platform*/) {
    
    if (!contact->GetFixtureA()->IsSensor() && !contact->GetFixtureB()->IsSensor()) {
        
        CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
        CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
        
        //CCLOG(@"AllowPlatformContact:  %@(%d)  %@(%d)\n", o1, [o1 gameObjectType] , o2, [o2 gameObjectType]);
        
        Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
        FloatingPlatform *platform = jumper == o1 ? (FloatingPlatform *) o2 : (FloatingPlatform *) o1;//GAMEOBJECT_OF_TYPE(FloatingPlatform, kGameObjectFloatingPlatform, o1, o2);
        
        // 1) Allow the player to jump up onto a platform above him - if the platform is one sided
        // 2) Allow the player to fall through if he's been knocked off - only falls through one platform at a time
        if ([platform isOneSided] && [jumper getPhysicsBody]->GetLinearVelocity().y > 0) {
            jumper.lastPlatform = platform;
            contact->SetEnabled(false);
            //CCLOG(@"NOT ALLOWED 1");
            return false;
        } else if (jumper.fallThrough) {
            
            if (jumper.lastPlatform != platform) {
                
                if (jumper.lastPlatform == nil) {
                    jumper.fallThrough = NO;
                    //CCLOG(@"ALLOWED 1");
                    return true;
                }
                
                float currPlatformHeight = [jumper.lastPlatform getPhysicsBody]->GetPosition().y*PTM_RATIO;
                float newPlatformHeight = [platform getPhysicsBody]->GetPosition().y*PTM_RATIO;
                float playerHeight = [jumper boundingBox].size.height;
                
                if (currPlatformHeight - newPlatformHeight >= playerHeight) {
                    jumper.fallThrough = NO;
                    //CCLOG(@"ALLOWED 2");
                    return true;
                } else {
                    contact->SetEnabled(false);
                    //CCLOG(@"NOT ALLOWED 2");
                    jumper.lastPlatform = platform;
                    return false;
                }
            } else {
                // allow to fall thru
                contact->SetEnabled(false);
                //CCLOG(@"NOT ALLOWED 3");
                return false;
            }
        } else {
            // player is falling down and is not falling thru
            // allow contact only if he's high enough to land on platform
            
            //float padding = ssipadauto(20);
            float currPlatformHeight = [platform getHeight];//[platform getPhysicsBody]->GetPosition().y*PTM_RATIO + platform.height;
            float playerHeight = ([jumper getPhysicsBody]->GetPosition().y*PTM_RATIO - (jumper.bodyWidth/2*PTM_RATIO));// - (jumper.bodyWidth/4*PTM_RATIO)) + padding;
            
            if (playerHeight - currPlatformHeight > 0) {
                // player is above the platform
                if ([jumper getPhysicsBody]->GetLinearVelocity().y > 0) {
                    contact->SetEnabled(false); // do not allow contact when player is trying to jump
                    return false;
                }
                else {
                    // make sure player is far enough on the platform before allowing the contact
                    BOOL allow = true;
                    
                    float platformXPos = [platform getPhysicsBody]->GetPosition().x;
                    float playerXPos = [jumper getPhysicsBody]->GetPosition().x;
                    
                    if (platformXPos - playerXPos > jumper.bodyWidth/2.5) {
                        allow = false;
                    }
                    
                    contact->SetEnabled(allow);
                    return allow;
                }
            } else {
                //CCLOG(@"CURR PLAT HEIGHT: %f", currPlatformHeight);
                //CCLOG(@"PLAYER HEIGHT: %f", playerHeight);
                // player is below the platform
                if (![platform isOneSided]) {
                    // do not allow player to jump thru a block platform
                    
                    BOOL enable = true;
                    
                    if ([jumper willKill]) {
                        
                        enable = false;
                        [platform breakApart];
                    } else if ([jumper getPhysicsBody]->GetLinearVelocity().y > 0) {
                        enable = true;
                    }
                    
                    contact->SetEnabled(enable);
                    return enable;
                }
                
                contact->SetEnabled(false);
                return false;
            }
        }
    }
    
    CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
    CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    //CCLOG(@"AllowPlatformContact:  %@(%d)  %@(%d)\n", o1, [o1 gameObjectType] , o2, [o2 gameObjectType]);
    
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    CCLOG(@"ALLOWED 3");
    jumper.fallThrough = NO;
    contact->SetEnabled(true);
    return true;
}


void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
    
    CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    //CCLOG(@"PreSolve:  %@(%d)  %@(%d)\n", o1, [o1 gameObjectType] , o2, [o2 gameObjectType]);
    
    b2Manifold* manifold = contact->GetManifold();
    b2Vec2 contactPoint = manifold->localPoint;
    
    if (IS_JUMPER(o1, o2)) {
        
        Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
        
        // one sided contact
        if (IS_FLOATING_PLATFORM(o1, o2) || IS_CURVED_PLATFORM(o1, o2) || IS_FALLING_PLATFORM(o1, o2) || IS_FINAL_PLATFORM(o1, o2)) {
            
            if (allowPlatformCollision(contact)) {
                
                if (!jumper.fallThrough) {
                    // force handling collision here, with multiple collisions
                    // begin contact was only called once, so player state was incorrect
                    // need to call this here to make sure running state starts back up
                    // once jump completes
                    if (jumper.state == kSwingerJumping || jumper.state == kSwingerInAir || jumper.state == kSwingerReviving) {
                        this->handleJumperFloatingPlatformCollision(o1, o2, CGPointZero);
                    }
                }
            } else {
                //CCLOG(@"FALLING THROUGH PLATFORM!");
            }
        }  else if (jumper.fallThrough) {
            // disable all contacts till player falls thru
            bool catchPlayer = false;
            
            if (IS_CANNON(o1,o2) || IS_CATCHER(o1,o2)) {
                catchPlayer = true;
            }
            
            contact->SetEnabled(catchPlayer);
        } else if (!jumper.fallThrough) {
            // Ignore enemy contacts when enemy can't kill the player so player doesn't bounce back
            
            if (IS_BOULDER(o1, o2) || IS_HUNTER(o1, o2) || IS_INSECT(o1, o2) || IS_SAW(o1, o2) || IS_BARREL(o1, o2)) {
                //
                Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
                Enemy * enemy = (Enemy *) (jumper == o1 ? o2 : o1);
                
                if (![enemy canKill: jumper]) {
                    contact->SetEnabled(false);
                } else {
                    // allow the contact
                    
                    if (IS_BOULDER(o1, o2)) {
                        // get world location of collision
                        b2WorldManifold * worldManifold = new b2WorldManifold();
                        contact->GetWorldManifold(worldManifold);
                        b2Vec2 location = worldManifold->points[0];
                        //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
                        
                        this->handleJumperBoulderCollision(o1, o2, ccp(location.x*PTM_RATIO, location.y*PTM_RATIO));
                    } else if (IS_HUNTER(o1, o2))  {
                        
                        b2WorldManifold * worldManifold = new b2WorldManifold();
                        contact->GetWorldManifold(worldManifold);
                        b2Vec2 location = worldManifold->points[0];
                        CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
                        //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
                        
                        this->handleJumperHunterCollision(o1,o2,cPoint);
                    } else if (IS_INSECT(o1, o2)) {
                        // get world location of collision
                        b2WorldManifold * worldManifold = new b2WorldManifold();
                        contact->GetWorldManifold(worldManifold);
                        b2Vec2 location = worldManifold->points[0];
                        CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
                        //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
                        
                        this->handleJumperInsectCollision(o1, o2, cPoint);
                    } else if (IS_SAW(o1, o2)) {
                        // get world location of collision
                        b2WorldManifold * worldManifold = new b2WorldManifold();
                        contact->GetWorldManifold(worldManifold);
                        b2Vec2 location = worldManifold->points[0];
                        CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
                        //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
                        
                        this->handleJumperSawCollision(o1, o2, cPoint);
                    } else if (IS_BARREL(o1, o2)) {
                        if (contact->GetFixtureA()->IsSensor() || contact->GetFixtureB()->IsSensor()) {
                            Barrel *barrel = GAMEOBJECT_OF_TYPE(Barrel, kGameObjectOilBarrel, o1, o2);
                            [barrel skid];
                        } else {
                            // get world location of collision
                            b2WorldManifold * worldManifold = new b2WorldManifold();
                            contact->GetWorldManifold(worldManifold);
                            b2Vec2 location = worldManifold->points[0];
                            CGPoint cPoint = ccp(location.x*PTM_RATIO, location.y*PTM_RATIO);
                            //contact->SetEnabled(canEnemyKillPlayer(o1,o2));
                            
                            this->handleJumperBarrelCollision(o1, o2, cPoint);
                        }
                    }
                }
            }       
        } else {
            /*if (IS_CANNON(o1, o2)) {
                CCLOG(@"PRESOLVING CONTACT WITH CANNON");
            }*/
        }
    }
    
//    b2WorldManifold worldManifold;
//    contact->GetWorldManifold(&worldManifold);
//    b2PointState state1[2], state2[2];
//    
//    b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
//    
//    if(state2[0] == b2_addState)
//    {
//        const b2Body* bodyA = contact->GetFixtureA()->GetBody();
//        const b2Body* bodyB = contact->GetFixtureB()->GetBody();
//        
//        b2Vec2 point = worldManifold.points[0];
//        b2Vec2 vA = bodyA->GetLinearVelocityFromWorldPoint(point);
//        b2Vec2 vB = bodyB->GetLinearVelocityFromWorldPoint(point);
//        
//        float32 approachVelocity = b2Dot(vB - vA, worldManifold.normal);
//        
//        CCLOG(@"VELOCITY A (%f,%f), VELOCITY B (%f,%f), APPROACH VELOCITY ON COLLISSION IS: %f", vA.x, vA.y, vB.x, vB.y, approachVelocity);
//    }
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}
