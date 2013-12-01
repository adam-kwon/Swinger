//
//  SkyLayer.m
//  Swinger
//
//  Created by Min Kwon on 6/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "SkyLayer.h"
#import "MainGameScene.h"
#import "GPUtil.h"
#import "TextureTypes.h"
#import "Cloud.h"
#import "AudioEngine.h"
#import "StarsFirework.h"
#import "Macros.h"

@interface SkyLayer(Private) 
- (void) initSun;
- (void) initClouds;
- (void) checkClouds;
@end

static const float cloudSpeed = 0.1;

@implementation SkyLayer

static SkyLayer* instanceOfLayer;

+ (SkyLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"SkyLayer instance not yet initialized!");
	return instanceOfLayer;
}

- (id) init {    
    if ((self = [super init])) {
        instanceOfLayer = self;
        self.anchorPoint = ccp(0.f, 0.5f);
        self.scale = 1.f;
        screenSize = [[CCDirector sharedDirector] winSize];
        speedFactor = 1;
        
        // init streaks
        streaks = [NSMutableArray array];
        [streaks retain];
        
        batchNode = [CCSpriteBatchNode batchNodeWithFile:[GPUtil getAtlasImageName:CHARACTER_ATLAS]];
        batchNode.anchorPoint = CGPointZero;
        [self addChild:batchNode z:1];
        
        if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_GRASS_KNOLLS]) {
            [self initSun];
            [self initClouds];
            
            // We'll be looping through an array. No need to do this 60 time a sec.
            [self schedule:@selector(checkClouds) interval:0.25];
        } else if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
            [self initMoon];
        }
        [self scheduleUpdate];
        
        fireWork = [StarsFirework particleWithFile:@"starsExplode.plist"];
        fireWork.visible = NO;
        [self addChild:fireWork z:10];

    }
    
    return self;
}

- (void) initMoon {
    
    celestialBody = [CCSprite spriteWithSpriteFrameName:@"Moon1.png"];
    celestialBody.anchorPoint = ccp(0.5f, 0.5f);
    [celestialBody retain];
    
    celestialBodyHolder = [CCNode node];
    celestialBodyHolder.scale = 1.f;
    celestialBodyHolder.position = ccp(30*ssipad(4, 1), screenSize.height - 50*ssipad(3, 1));
    celestialBodyHolder.anchorPoint = ccp(0.f, 0.5f);
    [self addChild:celestialBodyHolder z:0];
    [celestialBodyHolder addChild:celestialBody z:0];
    
    [self runMoonActions];
}

- (void) runMoonActions {
    
    /*CCTintBy * tint = [CCTintBy actionWithDuration:5 red:0 green:0 blue:0.1];
    CCTintBy * tint2 = [CCTintBy actionWithDuration:5 red:0 green:0 blue:-1]; // 254, 252, 215
    
    CCSequence * seq = [CCSequence actions: tint, tint2, nil];
    [celestialBody stopAllActions];
    [celestialBody runAction:seq];
    float duration = 2.0f;
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration: duration];
    CCScaleTo *shrink = [CCScaleTo actionWithDuration:0.7f scale:0.95f*celestialBody.scale];
    CCScaleTo *expand = [CCScaleTo actionWithDuration:0.7f scale:1.0f*celestialBody.scale];
    
    //CCMoveBy *shakeUp = [CCMoveBy actionWithDuration:0.1f position: ccp(0.3,0.3)];
    //CCMoveBy *shakeDown = [CCMoveBy actionWithDuration:0.1f position: ccp(-0.3,-0.3)];
    
    CCTintTo *tint1 = [CCTintTo actionWithDuration:0.5 red:0 green:0 blue:255];
    CCTintTo *tint2 = [CCTintTo actionWithDuration:0.5 red:0 green:0 blue:255];
    
    //CCSequence *floatSeq = [CCSequence actions: shakeUp, shakeDown, nil];
    CCSequence *scaleSeq = [CCSequence actions: delay, shrink, expand, nil];
    CCDelayTime * wait = [CCDelayTime actionWithDuration: 10];
    CCSequence *tintSeq = [CCSequence actions: wait, tint1, tint2, nil];
    
    //id shakeAction = [CCRepeatForever actionWithAction: floatSeq];
    id expandAction = [CCRepeatForever actionWithAction: scaleSeq];
    id tintAction = [CCRepeatForever actionWithAction: tintSeq];
    
    [celestialBody stopAllActions];
    //[celestialBody runAction: shakeAction];
    [celestialBody runAction: expandAction];
    [celestialBody runAction: tintAction];*/
}

- (void) initSun {
    
    celestialBody = [CCSprite spriteWithSpriteFrameName:@"Sun1.png"];
    celestialBody.anchorPoint = ccp(0.5f, 0.5f);
    [celestialBody retain];

    celestialBodyHolder = [CCNode node];
    celestialBodyHolder.position = ccp(30*ssipad(4, 1), screenSize.height - 30*ssipad(4, 1));
    celestialBodyHolder.anchorPoint = ccp(0.f, 0.5f);
    [self addChild:celestialBodyHolder z:0];
    [celestialBodyHolder addChild:celestialBody z:0];
        
    [self runSunActions];
}

- (void) runSunActions {
    
    float duration = 5.0f;
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration: duration];
    CCScaleTo *shrink = [CCScaleTo actionWithDuration:0.7f scale:0.98f*celestialBody.scale];
    CCScaleTo *expand = [CCScaleTo actionWithDuration:0.7f scale:1.0f*celestialBody.scale];
    
    //CCMoveBy *shakeUp = [CCMoveBy actionWithDuration:0.1f position: ccp(0.3,0.3)];
    //CCMoveBy *shakeDown = [CCMoveBy actionWithDuration:0.1f position: ccp(-0.3,-0.3)];
    
    CCTintTo *tint1 = [CCTintTo actionWithDuration:0.95 red:255 green:225 blue:0];
    CCTintTo *tint2 = [CCTintTo actionWithDuration:0.95 red:255 green:255 blue:0];
    //CCRotateBy *rotate1 = [CCRotateBy actionWithDuration:0.5 angle: 0.2];
    //CCRotateBy *rotate2 = [CCRotateBy actionWithDuration:0.5 angle: -0.2];
    
    //CCSequence *floatSeq = [CCSequence actions: shakeUp, shakeDown, nil];
    CCSequence *scaleSeq = [CCSequence actions: delay, shrink, expand, nil];
    CCDelayTime * wait = [CCDelayTime actionWithDuration: 10];
    CCSequence *tintSeq = [CCSequence actions: wait, /*rotate1,*/ tint1, tint2, /*rotate2,*/ nil];
    
    //id shakeAction = [CCRepeatForever actionWithAction: floatSeq];
    id expandAction = [CCRepeatForever actionWithAction: scaleSeq];
    id tintAction = [CCRepeatForever actionWithAction: tintSeq];
    
    [celestialBody stopAllActions];
    //[celestialBody runAction: shakeAction];
    [celestialBody runAction: expandAction];
    [celestialBody runAction: tintAction];
}

- (void) runCelestialBodyActions {
    // stop all actions and select the right action to run depending on the current world
    [celestialBody stopAllActions];
    
    if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_GRASS_KNOLLS]) {
        [self runSunActions];
    } else if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
        [self runMoonActions];
    }
}

- (void) initClouds {
    clouds = [NSMutableArray array];
    [clouds retain];
    
    int availWidth = screenSize.width;
    int numClouds = [GPUtil randomFrom:4 to: 8];
    
    // create clouds
    for(int i = 1; i <= numClouds; i++)
    {
        int cloudNum = i%3;
        
        if(cloudNum == 0)
            cloudNum = 1;
        
        NSString *file = [NSString stringWithFormat:@"Cloud%d.png", cloudNum];
        Cloud *cloud = [Cloud spriteWithSpriteFrameName: file];
        cloud.anchorPoint = ccp(0, 0);
        cloud.speed = 0.1; // [GPUtil randomFrom: 0.06 to: 0.30];
        
        if (arc4random() % 100 < 30) {
            cloud.scale = 0.5;
        }
        
        int zVal = 0;
        
            
        float xFrom = 0;
        float xTo = availWidth/numClouds;
        
        if(i > 1)
        {
            xFrom = ((i-1)*availWidth)/numClouds + 50;
            xTo = (i*xTo);
        }
        
        float x = [GPUtil randomFrom: xFrom to: xTo];
        float y = [GPUtil randomFrom: (screenSize.height - [cloud boundingBox].size.height*0) to: (screenSize.height - [cloud boundingBox].size.height*2)];
        
        cloud.position = ccp(x, y);
        
        //float duration = 2 * ((i%3) + 2);        
        //CCDelayTime * longWait = [CCDelayTime actionWithDuration: duration + 1];        
        //CCTintTo *tint1 = [CCTintTo actionWithDuration:0.5 red:248 green:248 blue:255];
        //CCTintTo *tint2 = [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255];
        //CCSequence * tintSeq = [CCSequence actions: longWait, tint1, tint2, nil];

        //[self addChild: cloud z: zVal];
        [batchNode addChild:cloud z:zVal];
        
        //id tintAction = [CCRepeatForever actionWithAction: tintSeq];
        
        //[cloud stopAllActions];
        //[cloud runAction: tintAction];
        
        [clouds addObject: cloud];
    }
}

- (void) scaleBy: (float)scaleAmount duration:(ccTime)duration {
    if (scaleAmount == 0.0f)
        return;
    
    //CCLOG(@"SCALE BY: %f", scaleAmount);
    float newScale = self.scale - (scaleAmount*.5f);
    
    CCScaleTo *scale = [CCScaleTo actionWithDuration:duration scale:newScale];
    CCSequence *scaleSeq = [CCSequence actions: scale/*, [CCCallFunc actionWithTarget:self selector:@selector(runCelestialBodyActions)]*/, nil];
    
    [celestialBody stopAllActions];
    [self stopAllActions];
    [self runAction:scaleSeq];
}

// scale is the change in scale of GamePlayLayer. scale the layers at the same rate
// as the parallax scrolling
- (void) zoomBy: (float) scaleAmount {
    if (fabsf(scaleAmount) != 0.0f) {
        //CCLOG(@"ZOOM BY %f", scaleAmount);
        self.scale -= scaleAmount*.5f;
        //[self runCelestialBodyActions];
    }
}

- (void) startSpeedStreaks:(float)factor {
    //speedFactor = factor;
    
    // Speed up the clouds
    /*Cloud *cloud;
    for (int i = [clouds count]-1; i >= 0; i--) {
        cloud = [clouds objectAtIndex:i];
        cloud.speed = speedFactor*cloudSpeed;
    }*/
    
    // create the streaks
    //[self schedule:@selector(createStreak) interval:0.25]; // factor in speed factor into the interval
    //[self schedule:@selector(moveStreaks) interval:0.01];
}

- (void) stopSpeedStreaks {
    //[self startSpeedStreaks:1];
    
    // stop creating streaks
    //[self unschedule:@selector(createStreak)];
    //[self unschedule:@selector(moveStreaks)];
    
    /*Cloud *cloud;
    
    for (int i = [streaks count]-1; i >= 0; i--) {
        cloud = [streaks objectAtIndex:i];
        cloud.visible = NO;
        [cloud removeFromParentAndCleanup: YES];
    }*/
}

- (void) createStreak {
    //
    
    Cloud *cloud = [Cloud spriteWithFile: @"leaf.png"];
    [self addChild:cloud z:100];
    [streaks addObject: cloud];
    
    float x = screenSize.width - ssipadauto(10);
    float y = [GPUtil randomFrom: 0 to: (screenSize.height - [cloud boundingBox].size.height*1)];
    cloud.position = ccp(x, y);
    
    cloud.speed = speedFactor*0.5;
}

- (void) moveStreaks {
    //
    //float scaledScreenWidth = screenSize.width/self.scale;
    Cloud *cloud;
    
    for (int i = [streaks count]-1; i >= 0; i--) {
        cloud = [streaks objectAtIndex:i];
        /*if (normalizeToScreenCoord(batchNode.position.x, cloud.position.x-[cloud boundingBox].size.width, self.scale)  > scaledScreenWidth) {
            cloud.visible = NO;
            //CCLOG(@"************* Cloud visible set to NO");
        } else {*/
            //cloud.visible = YES;
            CGPoint pos = ccp(cloud.position.x - cloud.speed, cloud.position.y);
            cloud.position = pos;
            
            /*float rightEdge = normalizeToScreenCoord(batchNode.position.x, pos.x + [cloud boundingBox].size.width, self.scale);
            
            if(rightEdge <= 0.0) {
                // gone off screen, move it to other end of the screen
                // let's reposition y and randomize size and speed again
                
                //CCLOG(@"************* Cloud being moved to right of screen");
                if (arc4random() % 100 < 30) {
                    cloud.scale = 0.5;
                }
                
                pos.x = fabs(batchNode.position.x) + scaledScreenWidth;
                pos.y = [GPUtil randomFrom: (screenSize.height - [cloud boundingBox].size.height*0) to: (screenSize.height - [cloud boundingBox].size.height*3)];
                cloud.speed = speedFactor*cloudSpeed; //[GPUtil randomFrom: 0.06 to: 0.30];
                cloud.position = pos;
            }*/
        //}
    }
}

- (void) checkClouds {
    float scaledScreenWidth = screenSize.width/self.scale;
    Cloud *cloud;
    
    // Check to see if we need to create more clouds
    Cloud  *lastCloud = [clouds lastObject];
    if (normalizeToScreenCoord(batchNode.position.x, lastCloud.position.x, self.scale) < scaledScreenWidth) {
        Cloud *cloud = [Cloud spriteWithSpriteFrameName:[NSString stringWithFormat:@"Cloud%d.png", 1+arc4random()%3]];
        if (arc4random() % 100 < 30) {
            cloud.scale = 0.5;
        }
        float x = fabsf(batchNode.position.x) + lastCloud.position.x + [lastCloud boundingBox].size.width;
        float y = [GPUtil randomFrom: (screenSize.height - [cloud boundingBox].size.height*0) to: (screenSize.height - [cloud boundingBox].size.height*2)];
        cloud.position = ccp(x, y);
        cloud.speed =  speedFactor*cloudSpeed; // [GPUtil randomFrom: 0.06 to: 0.30];
        [batchNode addChild:cloud];
        [clouds addObject:cloud];
    }
    
    for (int i = [clouds count]-1; i >= 0; i--) {
        cloud = [clouds objectAtIndex:i];
        if (normalizeToScreenCoord(batchNode.position.x, cloud.position.x-[cloud boundingBox].size.width, self.scale)  > scaledScreenWidth) {
            cloud.visible = NO;
            //CCLOG(@"************* Cloud visible set to NO");
        } else {
            cloud.visible = YES;
            CGPoint pos = ccp(cloud.position.x - cloud.speed, cloud.position.y);
            cloud.position = pos;
            
            float rightEdge = normalizeToScreenCoord(batchNode.position.x, pos.x + [cloud boundingBox].size.width, self.scale);
            
            if(rightEdge <= 0.0) { 
                // gone off screen, move it to other end of the screen
                // let's reposition y and randomize size and speed again
                
                //CCLOG(@"************* Cloud being moved to right of screen");
                if (arc4random() % 100 < 30) {
                    cloud.scale = 0.5;
                }
                
                pos.x = fabs(batchNode.position.x) + scaledScreenWidth;
                pos.y = [GPUtil randomFrom: (screenSize.height - [cloud boundingBox].size.height*0) to: (screenSize.height - [cloud boundingBox].size.height*3)];
                cloud.speed = speedFactor*cloudSpeed; //[GPUtil randomFrom: 0.06 to: 0.30];
                cloud.position = pos;               
            }                        
        }
    }    
}

- (void) update:(ccTime)dt {    
    batchNode.position = ccp(batchNode.position.x - 0.1, batchNode.position.y);
}


- (void) playFireWork {
    if (fireWorkCount < numFireWorksToPlay) {
        fireWork.visible = YES;
        fireWork.sourcePosition = ccp([GPUtil randomFrom:0 to:screenSize.width/self.scale], [GPUtil randomFrom:screenSize.height/2 to:screenSize.height/self.scale]);
        [fireWork resetSystem];
        fireWorkCount++;
    } else {
        fireWork.visible = NO;
        [self unschedule:@selector(playFireWork)];
    }
}

- (void) showFireWork {
    [[AudioEngine sharedEngine] playEffect:SND_CHEER gain:32];
    fireWorkCount = 0;
    numFireWorksToPlay = 7;
    [self schedule:@selector(playFireWork) interval:0.6];
}


- (void) setScale:(float)scale {
    if(scale == 0.0f)
        return;
    
    //CCLOG(@"SETTING SKY SCALE TO %f", scale);
    [super setScale:scale];
    
    /*if (self.scale < 1 && self.scale != 0)
        celestialBodyHolder.scale = 1/self.scale;*/
}

- (void) scrollUp:(float)dy {
    self.position = CGPointMake(self.position.x, dy * 0.1);
//    self.position = CGPointMake(self.position.x, self.position.y - (dy * 0.1));
}

- (void) cleanupLayer {
    [self stopAllActions];
    [self unscheduleAllSelectors];  
    
    [self removeAllChildrenWithCleanup:YES];
    [clouds removeAllObjects];
    [clouds release];
    [streaks removeAllObjects];
    [streaks release];
    
    clouds = nil;
}

- (void) dealloc {
    CCLOG(@"----------------------------- SkyLayer dealloc");
    [self cleanupLayer];
    [super dealloc];
}

@end
