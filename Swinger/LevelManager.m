//
//  LevelManager.m
//  Swinger
//
//  Created by James Sandoz on 5/1/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "LevelManager.h"
#import "LevelItem.h"
#import "Macros.h"


@interface LevelManager(Private)
-(void) initLevels;
@end


@implementation LevelManager

-(id) init {
    if ((self = [super init])) {
        [self initLevels];
    }
    
    return self;
}

-(void) initLevels {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    
    plistPath = [[NSBundle mainBundle] pathForResource:@"GameLevels" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *plist = (NSDictionary*)
    [NSPropertyListSerialization propertyListFromData:plistXML 
                                     mutabilityOption:NSPropertyListMutableContainersAndLeaves 
                                               format:&format 
                                     errorDescription:&errorDesc];
    if (!plist) {
        NSLog(@"**** Error reading GameLevels.plist: %@, format: %d", errorDesc, format);
    }
    
    // sort the keys so the levels will be stored in the array in the proper order
    NSArray *worldList = [[plist allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // Allocate the worlds array
    NSMutableArray *tmpWorlds = [NSMutableArray arrayWithCapacity:[worldList count]];
    
    for (NSString *world in worldList) {
        NSMutableArray *tmpLevels = [[NSMutableArray alloc] init];
        
        // add an empty list at index 0
        [tmpLevels insertObject:[NSMutableArray array] atIndex:0];
    
        // sort the keys so the levels will be stored in the array in the proper order
        NSDictionary *worldDict = [plist objectForKey:world];
        NSArray *worldLevels = [[worldDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        for (NSString *level in worldLevels) {
            
            int levelNum = [[level substringFromIndex:5] intValue];
            NSArray *items = (NSArray *)[worldDict objectForKey:level];
            CCLOG(@"Adding level %d\n", levelNum);

            //CCLOG(@"  Loading level %d\n", levelNum);
            NSMutableArray *levelItems = [NSMutableArray array];
            for (NSDictionary *item in items) {
                LevelItem *level = [[LevelItem alloc] init];

                NSString *type = (NSString *)[item objectForKey:@"Type"];
                level.typeName = [NSString stringWithString:type];
                if ([@"Catcher" isEqualToString:type]) {
                    level.type = kGameObjectCatcher;
                    level.period = [((NSNumber *)[item objectForKey:@"Period"]) floatValue]; 
                    level.swingAngle = CC_DEGREES_TO_RADIANS([((NSNumber *)[item objectForKey:@"SwingAngle"]) floatValue]);
                    level.ropeLength = [((NSNumber *)[item objectForKey:@"RopeLength"]) floatValue] * ssipad(2.0, 1.0);
                    level.grip = [((NSNumber *)[item objectForKey:@"Grip"]) floatValue];
                    level.poleScale = [((NSNumber *)[item objectForKey:@"PoleScale"]) floatValue];
                } else if ([@"FinalPlatform" isEqualToString:type]) {
                    level.type = kGameObjectFinalPlatform;
                    level.speed = 0;
                } else if ([@"Cannon" isEqualToString:type]) {
                    level.type = kGameObjectCannon;
                    level.speed = [((NSNumber *)[item objectForKey:@"Speed"]) floatValue];
                    level.force = [((NSNumber *)[item objectForKey:@"Force"]) floatValue];
                    level.swingAngle = /*CC_DEGREES_TO_RADIANS(*/[((NSNumber *)[item objectForKey:@"RotationAngle"]) floatValue];//);
                    level.grip = [((NSNumber *)[item objectForKey:@"Grip"]) floatValue];
                } else if ([@"Elephant" isEqualToString:type]) {
                    level.type = kGameObjectElephant;
                    level.walkVelocity = [((NSNumber *)[item objectForKey:@"WalkVelocity"]) floatValue];
                    level.leftEdge = [((NSNumber *)[item objectForKey:@"LeftEdge"]) floatValue] * ssipadauto(1);
                    level.rightEdge = [((NSNumber *)[item objectForKey:@"RightEdge"]) floatValue] * ssipadauto(1);
                    level.grip = [((NSNumber *)[item objectForKey:@"Grip"]) floatValue];
                } else if ([@"Spring" isEqualToString:type]) {
                    level.type = kGameObjectSpring;
                    level.bounce = [((NSNumber *)[item objectForKey:@"Bounce"]) floatValue];
                    level.grip = [((NSNumber *)[item objectForKey:@"Grip"]) floatValue];
                } else if ([@"Wheel" isEqualToString:type]) {
                    level.type = kGameObjectWheel;
                    level.speed = [((NSNumber *)[item objectForKey:@"SpinRate"]) floatValue];
                    level.grip = [((NSNumber *)[item objectForKey:@"Grip"]) floatValue];
                } else if ([@"StrongMan" isEqualToString:type]) {
                    level.type = kGameObjectStrongMan;
                } else if ([@"FloatingPlatform" isEqualToString: type]) {
                    level.type = kGameObjectFloatingPlatform;
                    level.width = ssipad(1,0.5)*[((NSNumber *)[item objectForKey:@"Width"]) floatValue];
                    level.elevatorDistance = [(NSNumber *)[item objectForKey:@"ElevatorDistance"] floatValue];
                    level.elevatorSpeed = [(NSNumber *)[item objectForKey:@"ElevatorSpeed"] floatValue];
                } else if ([@"CurvedPlatform" isEqualToString: type]) {
                    level.type = kGameObjectCurvedPlatform;
                    level.baseName = [NSString stringWithString:(NSString *) [item objectForKey: @"BaseName"]];
                } else if ([@"FallingPlatform" isEqualToString: type]) {
                    level.type = kGameObjectFallingPlatform;
                    level.width = ssipad(1,0.5)*[((NSNumber *)[item objectForKey:@"Width"]) floatValue];
                } else if ([@"Block" isEqualToString: type]) {
                    level.type = kGameObjectBlock;
                    level.width = ssipad(1,0.5)*[((NSNumber *)[item objectForKey:@"Width"]) floatValue];
                } else if ([@"Dummy" isEqualToString:type]) {
                    level.type = kGameObjectDummy;
                } else if ([@"Magnet" isEqualToString:type]) {
                    level.type = kGameObjectMagnet;
                } else if ([@"Shield" isEqualToString:type]) {
                    level.type = kGameObjectShield;
                } else if ([@"SpeedBoost" isEqualToString:type]) {
                    level.type = kGameObjectSpeedBoost;
                } else if ([@"JetPack" isEqualToString:type]) {
                    level.type = kGameObjectJetPack;
                } else if ([@"AngerPotion" isEqualToString:type]) {
                    level.type = kGameObjectAngerPotion;
                } else if ([@"CoinDoubler" isEqualToString:type]) {
                    level.type = kGameObjectCoinDoubler;
                } else if ([@"MissileLauncher" isEqualToString:type]) {
                    level.type = kGameObjectMissileLauncher;
                } else if ([@"GrenadeLauncher" isEqualToString:type]) {
                    level.type = kGameObjectGrenadeLauncher;
                }
                else if ([@"Hunter" isEqualToString:type]) {
                    level.type = kGameObjectHunter;
                    level.width = ssipad(1,0.5)*[((NSNumber *)[item objectForKey:@"WalkDistance"]) floatValue];
                    level.speed = [((NSNumber *)[item objectForKey:@"WalkSpeed"]) floatValue];
                }
                else if ([@"Insect" isEqualToString:type]) {
                    level.type = kGameObjectInsect;
                    level.width = ssipad(1,0.5)*[((NSNumber *)[item objectForKey:@"FlyDistance"]) floatValue];
                    level.speed = [((NSNumber *)[item objectForKey:@"FlySpeed"]) floatValue];
                }
                else if ([@"Saw" isEqualToString:type]) {
                    level.type = kGameObjectSaw;
                    level.width = ssipad(1,0.5)*[((NSNumber *)[item objectForKey:@"FlyDistance"]) floatValue];
                    level.speed = [((NSNumber *)[item objectForKey:@"FlySpeed"]) floatValue];
                }
                else if ([@"Barrel" isEqualToString:type]) {
                    level.type = kGameObjectOilBarrel;
                }
                else if ([@"Star" isEqualToString:type]) {
                    level.type = kGameObjectStar;
                } else if ([@"Coin" isEqualToString:type]) {
                    level.type = kGameObjectCoin;
                } else if ([@"Coin5" isEqualToString:type]) {
                    level.type = kGameObjectCoin5;
                }  else if ([@"Coin10" isEqualToString:type]) {
                    level.type = kGameObjectCoin10;
                } else if ([@"L1a_Tent1.png" isEqualToString:type]) {
                    level.type = kGameObjectTent1;
                } else if ([@"L1a_Tent2.png" isEqualToString:type]) {
                    level.type = kGameObjectTent2;                
                } else if ([@"L1a_BalloonCart.png" isEqualToString:type]) {
                    level.type = kGameObjectBalloonCart;
                } else if ([@"L1a_PopcornCart.png" isEqualToString:type]) {
                    level.type = kGameObjectPopcornCart;                
                } else if ([@"L1aTreeClump1.png" isEqualToString:type] || 
                           [@"L2a_TreeClump1.png" isEqualToString:type]) {
                    level.type = kGameObjectTreeClump1;                
                } else if ([@"L1aTreeClump2.png" isEqualToString:type] ||
                           [@"L2a_TreeClump2.png" isEqualToString:type]) {
                    level.type = kGameObjectTreeClump2;                
                } else if ([@"L1aTreeClump3.png" isEqualToString:type] ||
                           [@"L2a_TreeClump3.png" isEqualToString:type]) {
                    level.type = kGameObjectTreeClump3;                
                } else if ([@"L1a_Boxes1.png" isEqualToString:type]) {
                    level.type = kGameObjectBoxes;
                } else if ([@"L2a_Tree1.png" isEqualToString:type]) {
                    level.type = kGameObjectTree1;
                } else if ([@"L2a_Tree2.png" isEqualToString:type]) {
                    level.type = kGameObjectTree2;
                } else if ([@"L2a_Tree3.png" isEqualToString:type]) {
                    level.type = kGameObjectTree3;
                } else if ([@"L2a_Tree4.png" isEqualToString:type]) {
                    level.type = kGameObjectTree4;
                } else if ([@"L2a_Torch.png" isEqualToString:type]) {
                    level.type = kGameObjectTorch;
                } else if ([@"StrongMan" isEqualToString:type]) {
                    level.type = kGameObjectStrongMan;
                }
                
                if([item objectForKey:@"WindSpeed"] != nil && [item objectForKey:@"WindDirection"] != nil) {
                    level.windSpeed = [((NSNumber *)[item objectForKey:@"WindSpeed"]) floatValue];
                    level.windDirection = [NSString stringWithString:(NSString *) [item objectForKey: @"WindDirection"]];
                    
                    //if(level.windSpeed > 0) {
                        //CCLOG(@"SETTING WIND TO %f for object of type %@", level.windSpeed, [item objectForKey:@"Type"]);
                    //}
                }
                else {
                    level.windSpeed = 0;
                }
                
                level.position = ccp([((NSNumber *)[item objectForKey:@"XPosition"]) floatValue] * ssipadauto(1.0),
                                     [((NSNumber *)[item objectForKey:@"YPosition"]) floatValue] * ssipadauto(1.0));
                
                //CCLOG(@"    Added item: type=%@(%d), pos=%f, speed=%f\n", type, level.type, level.position, level.speed);
                [levelItems addObject:level];
            }
            //CCLOG(@"adding %d items for level %d\n", [levelItems count], levelNum);
            [tmpLevels insertObject:levelItems atIndex:levelNum];
        }
        [tmpWorlds addObject:tmpLevels];
    }
    
    worlds = [NSArray arrayWithArray:tmpWorlds];
    [worlds retain];
}

- (NSArray *) getItemsForLevel:(int)level inWorld:(int)world {
    NSAssert(world >= 0 && world < [worlds count], @"Error: Attempting to load unknown world.");
    
    NSArray *levels = [worlds objectAtIndex:world];
    return [levels objectAtIndex:level];
}

- (void) dealloc {
    [worlds release];
    
    [super dealloc];
}



@end
