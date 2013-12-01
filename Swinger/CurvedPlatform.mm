//
//  CurvedPlatform.m
//  Swinger
//
//  Created by James Sandoz on 8/6/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CurvedPlatform.h"


@implementation CurvedPlatform

+ (id) make:(NSString *)name {  
    return [[[self alloc] initForName:name] autorelease];
}


// the baseName should be the base name of the png and plist.  The current test platform
// has the following files:
//    curved-ground-tmp.png
//    curved-ground-tmp.plist
- (id) initForName:(NSString *)baseName {
    if ((self = [super init])) {
        name = baseName;
        
        // Load the sprite
        //XXX change to load from plist once they're created
        sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", name]];
        width = 1000; // XXX HARD CODED TO MAKE REVIVE WORK!
        [self addChild:sprite];
    }
    
    return self;
}


#pragma mark - BaseCatcherObject abstract methods
- (GameObjectType) gameObjectType {
//    return kGameObjectCurvedPlatform;
    return kGameObjectFloatingPlatform;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {

    //XXX TODO: hide/show based on gameNode position
}

- (void) createPhysicsObject:(b2World *)theWorld {
    
    world = theWorld;
    
    // Create the body
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.fixedRotation = true;
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    // Load the fixtures from the plist
    NSString *plist = [NSString stringWithFormat:@"%@.plist", name];
    [self createFixtures:plist];
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    // No-op
}

- (void) setSwingerVisible:(BOOL)visible {
    // No-op
}

- (float) getHeight {
    //XXX this could be tricky
    //return self.position.y + ssipadauto(100); // hardcoded value for now
    return body->GetPosition().y * PTM_RATIO;// + ssipadauto(100);
}



#pragma mark - helper methods
// This method is almost directly copied from GB2ShapeCache.mm from 
// Ray Wenderlich.  Taken from this tutorial:
//   http://www.raywenderlich.com/2012/02/01/monkey-jump/
//
// Loads the polygon vertices and physics object properties from the
// plist
- (void) createFixtures:(NSString *)plist {
    CCLOG(@"\n\n\n#####   In createFixtures:%@  #####\n\n\n", plist);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:plist
                                                     ofType:nil
                                                inDirectory:nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSDictionary *metadataDict = [dictionary objectForKey:@"metadata"];
    int format = [[metadataDict objectForKey:@"format"] intValue];
    float ptmRatio =  [[metadataDict objectForKey:@"ptm_ratio"] floatValue];
    
    NSAssert(format == 1, @"Format not supported");
    
    NSDictionary *bodyDict = [dictionary objectForKey:@"bodies"];
    
    b2Vec2 vertices[b2_maxPolygonVertices];
    
    for(NSString *bodyName in bodyDict)
    {
        CCLOG(@"Loading body %@\n", bodyName);
        // get the body data
        NSDictionary *bodyData = [bodyDict objectForKey:bodyName];
        
        sprite.anchorPoint = CGPointFromString_([bodyData objectForKey:@"anchorpoint"]);
        
        // iterate through the fixtures
        NSArray *fixtureList = [bodyData objectForKey:@"fixtures"];
        
        for(NSDictionary *fixtureData in fixtureList) {
            b2FixtureDef basicData;
            
//            basicData.filter.categoryBits = [[fixtureData objectForKey:@"filter_categoryBits"] intValue];
//            basicData.filter.maskBits = [[fixtureData objectForKey:@"filter_maskBits"] intValue];
//            basicData.filter.groupIndex = [[fixtureData objectForKey:@"filter_groupIndex"] intValue];
            
            //XXX hard code the collision masks
            basicData.filter.categoryBits = CATEGORY_FLOATING_PLATFORM;
            basicData.filter.maskBits = CATEGORY_JUMPER | CATEGORY_ENEMY;
            
            basicData.friction = [[fixtureData objectForKey:@"friction"] floatValue];
            basicData.density = [[fixtureData objectForKey:@"density"] floatValue];
            basicData.restitution = [[fixtureData objectForKey:@"restitution"] floatValue];
            basicData.isSensor = [[fixtureData objectForKey:@"isSensor"] boolValue];
//            basicData.userData = [[fixtureData objectForKey:@"id"] retain];
            //XXX think callbackData is something Ray adds manually for his engine, don't see it in PhysicsEditor
//            int callbackData = [[fixtureData objectForKey:@"userdataCbValue"] intValue];
            
            NSString *fixtureType = [fixtureData objectForKey:@"fixture_type"];
            
            CCLOG(@"  Fixture props: friction=%f, density=%f, restitution=%f, isSensor=%d\n", basicData.friction, basicData.density, basicData.restitution, basicData.isSensor);
            
            // read polygon fixtures. One convave fixture may consist of several convex polygons
            if([fixtureType isEqual:@"POLYGON"]) {
                NSArray *polygonsArray = [fixtureData objectForKey:@"polygons"];
                
                CCLOG(@"  Shape is POLYGON, loading vertices\n");
                for(NSArray *polygonArray in polygonsArray) {
                    
                    b2PolygonShape *polyshape = new b2PolygonShape();
                    int vindex = 0;
                    
                    assert([polygonArray count] <= b2_maxPolygonVertices);
                    for(NSString *pointString in polygonArray) {
                        CGPoint offset = CGPointFromString_(pointString);
                        vertices[vindex].x = (offset.x / ptmRatio) ;
                        vertices[vindex].y = (offset.y / ptmRatio) ;
                        
                        CCLOG(@"    offset=(%f,%f), adjusted=(%f,%f)\n", offset.x, offset.y, vertices[vindex].x, vertices[vindex].y);
                        vindex++;
                    }
                    
                    polyshape->Set(vertices, vindex);
                    basicData.shape = polyshape;
                    
                    // create the fixture
                    body->CreateFixture(&basicData);
                }
            } else if([fixtureType isEqual:@"CIRCLE"]) {
                CCLOG(@"  Shape is CIRCLE!\n");
                NSDictionary *circleData = [fixtureData objectForKey:@"circle"];
                
                b2CircleShape *circleShape = new b2CircleShape();
                circleShape->m_radius = [[circleData objectForKey:@"radius"] floatValue]  / ptmRatio;
                CGPoint p = CGPointFromString_([circleData objectForKey:@"position"]);
                circleShape->m_p = b2Vec2(p.x / ptmRatio, p.y / ptmRatio);
                basicData.shape = circleShape;
                
                // create the fixture
                body->CreateFixture(&basicData);                
            }
            else {
                // unknown type
                assert(0);
            }

            
            CCLOG(@"Fixture created.\n\n\n################\n\n\n");
        }
    }
}


// From GB2ShapeCache.mm
static CGPoint CGPointFromString_(NSString* str) {           
    NSString* theString = str;
    theString = [theString stringByReplacingOccurrencesOfString:@"{ " withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@" }" withString:@""];
    NSArray *array = [theString componentsSeparatedByString:@","];
    return CGPointMake([[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue]);
}       

@end
