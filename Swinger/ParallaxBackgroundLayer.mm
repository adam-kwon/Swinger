//
//  ParallaxBackgroundLayer.m
//  Swinger
//
//  Created by Isonguyo Udoka on 5/28/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "ParallaxBackgroundLayer.h"
#import "Crow.h"
#import "GamePlayLayer.h"
#import "TextureTypes.h"
#import "LevelItem.h"
#import "GPUtil.h"
#import "MainGameScene.h"
#import "TorchFire.h"
#import "Notifications.h"
#import "Wind.h"

@interface ParallaxBackgroundLayer(Private) 
- (void) createCrows: (int) amount in: (CCNode*) parent at : (CGPoint) location;
- (void) cleanupCrows: (BOOL) deleteAll;
@end

@implementation ParallaxBackgroundLayer

static ParallaxBackgroundLayer *instanceOfLayer;
static const int flagActionTag = 111;
static const int flagSpeedUpActionTag = 112;
static const int maxYPos = -1;

+ (ParallaxBackgroundLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"ParallaxBackgroundLayer instance not yet initialized!");
	return instanceOfLayer;
}

- (id) init {
    if ((self = [super init])) {
        [self setIsTouchEnabled:NO];
        instanceOfLayer = self;
        
        screenSize  = [[CCDirector sharedDirector] winSize];
        
        [self initArrays];
        gamePlayHeight = 0;
        //[self initLayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(windBlowing:) 
                                                     name:NOTIFICATION_WIND_BLOWING 
                                                   object:nil];
    }
    
    return self;
}

- (void) initParallaxLayers {
    [self setVisibleBackgrounds];   
}

- (void) initArrays {
    
    if (foregroundObjects == nil) {
        foregroundObjects = [[CCArray alloc] init];
    }
    
    if (flags == nil) {
        flags = [[CCArray alloc] init];
    }
    
    if (crows == nil) {
        crows = [[CCArray alloc] init];
    }
    
    if (balloons == nil) {
        balloons = [[CCArray alloc] init];
    }
    
    if (torchFires == nil) {
        torchFires = [[CCArray alloc] init];
    }
}

- (void) initLayer {
    CCLOG(@"===  ParallaxBackgroundLayer.initLayer  ===\n");
    
    frontScale = 1.f;
    hillScale = 1.f;
    backScale = 1.f;
    
    NSString * backgroundAtlas = [self getBackgroundAtlasName];
    
    // will dynamically lay out enough parallax to cover the stage length
    float stageLength = [GamePlayLayer sharedLayer].finalPlatformRightEdge + screenSize.width; 

    // Background Hill parallax
    backParallax = [CCSpriteBatchNode batchNodeWithFile:[GPUtil getAtlasImageName:backgroundAtlas]];
    backParallax.anchorPoint = ccp(0,0);
    [self addChild:backParallax z:1];
    [self createHillBackground: backParallax length: stageLength startOffset: -(screenSize.width/2)];
    
    // Background Hill parallax
    hillParallax = [CCSpriteBatchNode batchNodeWithFile:[GPUtil getAtlasImageName:backgroundAtlas]];
    hillParallax.anchorPoint = ccp(0,0);
    [self addChild:hillParallax z:2];
    [self createHillForeground : hillParallax length: stageLength startOffset: -(screenSize.width/2)];
    
    // Foreground parallax
    frontParallax = [CCSpriteBatchNode batchNodeWithFile:[GPUtil getAtlasImageName:backgroundAtlas]];
    frontParallax.anchorPoint = ccp(0,0);
    [self addChild:frontParallax z:3];
    
    frontAccent = [[CCNode alloc] init];
    frontAccent.anchorPoint = ccp(0,0);
    [self addChild:frontAccent z:4];
    
    // Set up the ground node
    groundHolder = [CCNode node];
    // set the content size
    CGSize size = [self generateBoundingBox : groundHolder];
    [groundHolder setContentSize: size];
    [self addChild: groundHolder z:5]; // should be the furthest forward
    
    // Initialize the ground body
    [self initGround];
    
    // Set up level specific items
    for(LevelItem * level in foregroundObjects) {
        [self addLevelItem : level to: frontParallax];
    }
    
    [self initParallaxLayers];
    [self scheduleUpdate];
}

- (NSString *) getBackgroundAtlasName {
    NSString * atlasName = BACKGROUND_ATLAS;
    NSString * world = [[MainGameScene sharedScene] world];
    
   if ([world isEqualToString: WORLD_FOREST_RETREAT]) {
        atlasName = FOREST_RETREAT_ATLAS;
    }
    
    return atlasName;
}

- (void) initGround {
    NSString * prefix = @"L1a";
    NSString * world = [[MainGameScene sharedScene] world];
    
    if ([world isEqualToString: WORLD_GRASS_KNOLLS]) {
        prefix = @"L1a_Ground.png";//1.png"; //
    } else if ([world isEqualToString: WORLD_FOREST_RETREAT]) {
        prefix = @"L2a_Ground.png";
    } else {
        prefix = @"L3a_Ground.png";
    }
    
    ground = [CCSprite spriteWithSpriteFrameName:prefix]; //[self getSpriteName:@"_Ground.png"]];
    ground.scaleX = 1.3;
    ground.anchorPoint = ccp(0,0);
    ground.position = ccp(0,0);
    ground.visible = NO;
    
    /*if ([world isEqualToString: WORLD_GRASS_KNOLLS]) {
        
        id anim = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"groundAnimation"] restoreOriginalFrame:NO];
        id wait = [CCDelayTime actionWithDuration:5.f];
        id seq = [CCSequence actions: anim, anim, anim, wait, nil];
        id repeat = [CCRepeatForever actionWithAction: seq];
        
        [ground stopAllActions];
        [ground runAction: repeat];
    }*/
    
    [groundHolder addChild:ground]; // should be the furthest forward
    [self stretchGround];
}

- (NSString *) getSpriteName: (NSString *) name {
    NSString * prefix = @"L1a";
    NSString * world = [[MainGameScene sharedScene] world];
    
    if ([world isEqualToString: WORLD_GRASS_KNOLLS]) {
        prefix = @"L1a";
    } else if ([world isEqualToString: WORLD_FOREST_RETREAT]) {
        prefix = @"L2a";
    } else {
        prefix = @"L3a";
    }
    
    return [NSString stringWithFormat:@"%@%@", prefix, name];
}

- (void) windBlowing:(NSNotification *)notification {
    
    Wind * wind = nil;
    
    [self finishWindBlowing];
    if (notification.object != nil) {
        wind = (Wind *)notification.object;
    } else {
        //[self finishWindBlowing];
        return;
    }
    
    float delay = 1.5f;
    BOOL movingBackwards = (wind.direction == kDirectionW ||
                            wind.direction == kDirectionNW ||
                            wind.direction == kDirectionSW);
    
    if (balloons != nil && [balloons count] > 0) {
        for (CCSprite * balloon in balloons) {
            
            if (balloon.visible) {
                float angle = wind.speed * 10;
                
                if (angle > 45) {
                    angle = 45;
                }
                
                if (movingBackwards) {
                    angle *= -1;
                }
                
                CCDelayTime * wait = [CCDelayTime actionWithDuration:delay/6];
                CCRotateBy *rotate1 = [CCRotateBy actionWithDuration:delay/6 angle:angle];
                CCRotateBy *rotate2 = [CCRotateBy actionWithDuration:delay/6 angle:-(angle/3)];
                CCRotateBy *rotate3 = [CCRotateBy actionWithDuration:delay/6 angle:(angle/3)];
                CCRotateBy *rotate4 = [CCRotateBy actionWithDuration:delay/6 angle:-(angle/3)];
                CCRotateBy *rotate5 = [CCRotateBy actionWithDuration:delay/6 angle:(angle/3)];
                CCRotateBy *rotate6 = [CCRotateBy actionWithDuration:delay/6 angle:-angle];
                CCSequence *seq = [CCSequence actions:rotate1,rotate2, rotate3, rotate4, rotate5, rotate6, wait, nil];
                CCSequence *seq2 = [CCSequence actions:seq, [seq reverse], nil];
                
                [balloon runAction: [CCRepeatForever actionWithAction: seq2]];
            }
        }
    }
    
    if (flags != nil && [flags count] > 0) {
        for (CCSprite * flag in flags) {
            
            if (flag.visible) {
                CCActionInterval * flagAction = (CCActionInterval*)[flag getActionByTag:flagActionTag];
                CCSpeed *speedUp = [CCSpeed actionWithAction:flagAction speed:wind.speed];
                speedUp.tag = flagSpeedUpActionTag;
                
                [flag runAction: speedUp];
            }
        }
    }
    
    /*if (torchFires != nil && [torchFires count] > 0) {
        
        for (TorchFire * torch in torchFires) {
            
            if (torch.visible) {
                torch.positionType = kCCPositionTypeFree;
            }
        }
    }*/
    
    //for (CCNode * node in [frontParallax children]) {
        
        //if (node.visible 
        /*&& (node.tag == kGameObjectTreeClump1 || node.tag == kGameObjectTreeClump2 || node.tag == kGameObjectTreeClump3 ||
                             node.tag == kGameObjectTree1 || node.tag == kGameObjectTree2 || node.tag == kGameObjectTree3 || node.tag == kGameObjectTree4 )) {
            
            float angle = (movingBackwards ? -1 : 1) * 0.6;
            
            CCRotateBy *rotate1 = [CCRotateBy actionWithDuration:delay/6 angle:angle];
            CCRotateBy *rotate2 = [CCRotateBy actionWithDuration:delay/6 angle:-(angle/3)];
            CCRotateBy *rotate3 = [CCRotateBy actionWithDuration:delay/6 angle:(angle/3)];
            CCRotateBy *rotate4 = [CCRotateBy actionWithDuration:delay/6 angle:-(angle/3)];
            CCRotateBy *rotate5 = [CCRotateBy actionWithDuration:delay/6 angle:(angle/3)];
            CCRotateBy *rotate6 = [CCRotateBy actionWithDuration:delay/6 angle:-angle];
            CCSequence *seq = [CCSequence actions:rotate1,rotate2, rotate3, rotate4, rotate5, rotate6, nil];
            
            [node runAction: [CCEaseSineIn actionWithAction: seq]];
        }*/
    //}
    // Wind will stop blowing based on the notification
    //[[CCScheduler sharedScheduler] scheduleSelector : @selector(finishWindBlowing) forTarget:self interval:delay paused:NO];
}

- (void) finishWindBlowing {
    // reset objects after wind blows
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(finishWindBlowing) forTarget:self];
    
    if (balloons != nil && [balloons count] > 0) {
        
        for (CCSprite * balloon in balloons) {
            [balloon stopAllActions];
            balloon.rotation = 0;
        }
    }
    
    if (flags != nil && [flags count] > 0) {
        
        for (CCSprite * flag in flags) {
            [flag stopActionByTag: flagSpeedUpActionTag];
        }
    }
    
    /*if (torchFires != nil && [torchFires count] > 0) {
        
        for (TorchFire * torch in torchFires) {
            torch.positionType = kCCPositionTypeGrouped;
        }
    }*/
    
    //for (CCNode * node in [frontParallax children]) {
        
        //if (node.rotation != 0 /*&& (node.tag == kGameObjectTreeClump1 || node.tag == kGameObjectTreeClump2 || node.tag == kGameObjectTreeClump3)*/) {
            
          //  node.rotation = 0;
        //}
    //}
}

- (void) addLevelItem: (LevelItem*)item to: (CCNode*) theParent {
    GameObjectType type = item.type;
    NSString * file = item.typeName;
    int zOrder = 0;
    BOOL createCrows = NO;
    int crowCount = 3;
    float crowHeightFactor = 0.93f;
    BOOL createBalloons = NO;
    BOOL createFlag = NO;
    BOOL createTorchLight = NO;
    float chance = arc4random() % 100;
    
    if (type == kGameObjectTent1) {
        zOrder = 1;
        createFlag = YES;
        if(chance < 70) {
            createCrows = YES;
            crowCount = 1;
            crowHeightFactor = 1.f;
        }
    } else if (type == kGameObjectTent2) {
        zOrder = 1;
        createFlag = YES;
        if(chance > 70) {
            createCrows = YES;
            crowCount = 1;
        }
    } else if (type == kGameObjectBalloonCart) {
        createBalloons = YES;
    } else if (type == kGameObjectPopcornCart) {
        
    } else if (type == kGameObjectTreeClump1) {
        zOrder = -1;
        
        if(chance > 45) {
            createCrows = YES;
        }
    } else if (type == kGameObjectTreeClump2) {
        zOrder = -1;
        
        if(chance > 80) {
            createCrows = YES;
            crowCount = 1;
        }
    } else if (type == kGameObjectTreeClump3) {
        zOrder = -1;
        
        if(chance < 20) {
            createCrows = YES;
            crowCount = 2;
        }
    } else if (type == kGameObjectBoxes) {
        
    } else if (type == kGameObjectTorch) {
        // set up torch fire
        createTorchLight = YES;
    }
    
    CCSprite *itemSprite = [CCSprite spriteWithSpriteFrameName: file];
    itemSprite.tag = type;
    itemSprite.visible = NO;
    float groundHeight = ([itemSprite boundingBox].size.height*itemSprite.anchorPoint.y) + [ground boundingBox].size.height*0.45f;//56
    float posY = item.position.y;
    
    if (posY < groundHeight) {
        posY = groundHeight;
    }
    
    itemSprite.position = ccp(item.position.x, posY);
    [theParent addChild: itemSprite z:zOrder];
    
    if(createCrows) {
        float crowXOffset = 15;
        float crowYOffset = 2;
        
        if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
            crowHeightFactor = .6f;
            crowXOffset = 0;
            crowYOffset = 0;
        }
        
        [self createCrows: crowCount in: theParent at: ccp(itemSprite.position.x + crowXOffset, crowHeightFactor*(itemSprite.position.y+ [itemSprite boundingBox].size.height/2) + crowYOffset)];
    }
    
    if(createBalloons) {
        [self createBalloons: theParent at: ccp(itemSprite.position.x, itemSprite.position.y + [itemSprite boundingBox].size.height/2)];
    }
    
    if(createFlag) {
        [self createFlag: theParent at: ccp(itemSprite.position.x + ssipadauto(17), itemSprite.position.y - ssipadauto(2) + [itemSprite boundingBox].size.height/2)];
    }
    
    if (createTorchLight) {
        
        TorchFire *torchFire = [TorchFire particleWithFile:@"torchParticle.plist"];
        torchFire.scale = ssipadauto(0.25);
        torchFire.anchorPoint = ccp(0.5,0);
        torchFire.position = ccp(item.position.x, (itemSprite.position.y + [itemSprite boundingBox].size.height/2) - ssipadauto(5));
        [frontAccent addChild:torchFire z:20];
        [torchFire resetSystem];
        torchFire.visible = YES;
        
        [torchFires addObject: torchFire];
    }
    
    CGSize size = [self generateBoundingBox : theParent];
    [theParent setContentSize: size];
    
    [self setVisibleFrontSprites];
}

- (void) stretchGround {
    // fill current screen size with ground sprite
    float scale = frontParallax.scale;
    //float maxWidth = screenSize.width/scale;
    
    // scale ground to fit entire content area
    //[ground setScaleX: maxWidth/ground.contentSize.width];
    [groundHolder setScaleY: scale];
}

- (void) addToForegroundObjectsList:(LevelItem*)node {
    CCLOG(@"===  ParallaxBackgroundLayer.addToForegroundObjectList  ===\n");
    
    [self initArrays];
    [foregroundObjects addObject:node];
    //[self addLevelItem:node to: frontParallax];
}

- (void) createCrows: (int) amount in: (CCNode*) parent at:(CGPoint) location {
    
    for(int i = 0; i < amount; i++)
    {
        Crow *crow = [Crow spriteWithSpriteFrameName:@"Crow6.png"];
        if (CCRANDOM_MINUS1_1() < 0) {
            crow.flipX = YES;
        }
        
        [parent addChild: crow z: 2];
        crow.scale = ssipadauto(0.5);
        crow.position = location;
        
        [crows addObject: crow];
    }
}

- (void) createFlag: (CCNode*) parent at:(CGPoint) location {
    CCSprite *flag = [CCSprite spriteWithSpriteFrameName:@"L1a_TentFlag1.png"];
    flag.anchorPoint = ccp(0.5, 0);
    [parent addChild: flag z:49];
    flag.position = location;
    
    CCAnimate *action = nil;
    
    if(CCRANDOM_0_1() == 0) {
        action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flagAnimation"] restoreOriginalFrame:NO];
    } else {
        action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flagAnimationSlow"] restoreOriginalFrame:NO];
    }
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration:[GPUtil randomFrom: 0 to: 0]];
    CCSequence *seq = [CCSequence actions: delay, action, nil];
    CCRepeatForever *animAction = [CCRepeatForever actionWithAction:seq];
    animAction.tag = flagActionTag;
    
    [flag runAction:animAction];
    [flags addObject: flag];
}

- (void) createBalloons: (CCNode*) parent at:(CGPoint) location {
    CCSprite *balloon = [CCSprite spriteWithSpriteFrameName:@"Balloons.png"];
    balloon.anchorPoint = ccp(0.5,0);
    [parent addChild: balloon z: 49];
    balloon.position = location;
    
    [balloons addObject: balloon];
}

- (void) createHillForeground : (CCNode *) background length : (float) length startOffset : (float) startXOffset {
    
    int xPos = startXOffset;
    
    //for(int i = 0; i < amount; i++) {
    while (true) {
        for(int j = 0; j < 8; j++) {
            NSString *file = [NSString stringWithFormat:[self getSpriteName: @"Hills1-%d.png"], j];
            CCSprite *hill = [CCSprite spriteWithSpriteFrameName:file];
            hill.anchorPoint = ccp(0,0);
            hill.position = ccp(xPos, 0);
            
            hill.visible = NO;
            [background addChild: hill];
            xPos += [hill boundingBox].size.width - 1; // overlapping the sprites ever so slightly to remove white line in between when scrolling
        }
        
        if (xPos > length) {
            break;
        }
    }
    
    // set the content size
    CGSize size = [self generateBoundingBox : background];
    [background setContentSize: size];
}

- (void) createHillBackground : (CCNode *) background length : (float) length startOffset : (float) startOffset {
    
    //int amount = 1;
    
    // determine the amount of hills needed based on the stage length
    
    int xPos = startOffset;
    
    //for(int i = 0; i < amount; i++) {
    while(true) {
        for(int j = 0; j < 8; j++) {
            NSString *file = [NSString stringWithFormat:[self getSpriteName: @"Hills2-%d.png"], j];
            CCSprite *hill = [CCSprite spriteWithSpriteFrameName:file];
            hill.anchorPoint = ccp(0,0);
            hill.position = ccp(xPos, 0);
            
            hill.visible = NO;
            [background addChild: hill];
            xPos += [hill boundingBox].size.width - 1; // overlapping the sprites ever so slightly to remove white line in between when scrolling
        }
        
        if (xPos > length) {
            break;
        }
    }
    //}
    
    // set the content size
    CGSize size = [self generateBoundingBox : background];
    [background setContentSize: size];
}

- (CGSize) generateBoundingBox: (CCNode *) sprite
{
    int width = 0;
    int height = 0;
    
    for(CCSprite * child in [sprite children])
    {
        CGRect rec = [child boundingBox];
        
        if(rec.size.width > width)
        {
            width = rec.size.width;
        }
        
        if(rec.size.height > height)
        {
            height = rec.size.height;
        }
    }
    
    return CGSizeMake(width, height);
}

- (void) update: (ccTime) dt
{    
    [self cleanupCrows : NO];
}

- (void) cleanupCrows : (BOOL) deleteAll
{   
    if (crows == nil || [crows count] <= 0) {
        return;
    }
    
    //CCNode<GameObject, PhysicsObject> *node;
    Crow *node;
    for (int crowIndex = [crows count]-1; crowIndex >= 0; crowIndex--) {
        node = (Crow*)[crows objectAtIndex:crowIndex];
        
        if (!deleteAll) {
            [node updateObjectOnParallax];
        }
        
        if (deleteAll || [node isSafeToDelete]) {
            //[node destroyPhysicsObject];
            [node stopAllActions];
            [node removeFromParentAndCleanup:YES];
            [crows removeObjectAtIndex:crowIndex];
        }
        else {
            //CCLOG(@"CROW POSITION %d IS: (%f,%f)", crowIndex, node.position.x, node.position.y);
        }
    }
}


-(void) setVisibleBackgrounds
{
    [self setVisibleBackSprites];
    [self setVisibleHillSprites];
    [self setVisibleFrontSprites];
    [self setVisibleFrontAccentSprites];
}

- (void) setVisibleBackSprites {
    
    //CCLOG(@"********SV BACK*******");
    [self setVisibleSprites: backParallax scale: backScale];
    //CCLOG(@"********SV BACK END****");
}

- (void) setVisibleHillSprites {
    
    //CCLOG(@"********SV HILL*******");
    [self setVisibleSprites: hillParallax scale: hillScale];
    //CCLOG(@"********SV HILL END****");
}

- (void) setVisibleFrontSprites {
    
    //CCLOG(@"********SV FRONT*******");
    [self setVisibleSprites: frontParallax scale: frontScale];
    //CCLOG(@"********SV FRONT END****");
    
    [self stretchGround];
}

- (void) setVisibleFrontAccentSprites {
    [self setVisibleSprites: frontAccent scale: frontScale];
}

-(void) syncFrontScale {
    frontScale = frontParallax.scale;
}

-(void) syncHillScale {
    hillScale = hillParallax.scale;
}

-(void) syncBackScale {
    backScale = backParallax.scale;
}

-(void) updateScales: (float) front hill: (float) hill back: (float) back {
    frontScale = front;
    hillScale = hill;
    backScale = back;
}

- (void) setVisibleSprites: (CCNode *) parallax scale: (float) scale
{
    for(CCSprite * sprite in [parallax children])
    {
        [self showSprite: sprite : scale];
    }
}

/**
 * Determines which sprites are on screen (set to visible) and which are off screen (set to invisible)
 */
- (void) showSprite: (CCNode *) sprite : (float) scale {
    
    if (scale == 0) {
        scale = 1;
    }
    
    float visibleScreenWidth = screenSize.width/scale;
    
    float leftWidth = 0;
    if(sprite.anchorPoint.x == 0.5) {
        leftWidth = [sprite boundingBox].size.width/2;
    }
    
    float leftEdge = sprite.position.x - leftWidth;
    float rightEdge = leftEdge + [sprite boundingBox].size.width;
    float widthPlusBuffer = (visibleScreenWidth + ssipadauto(100))/scale;
    
    //CCLOG(@"LEFT EDGE: %f, RIGHT EDGE: %f, SCREEN WIDTH BUFFER: %f", leftEdge, rightEdge, widthPlusBuffer);
    
    if((rightEdge >= 0.0 && leftEdge < widthPlusBuffer) || (leftEdge < widthPlusBuffer && leftEdge > 0.0))
    {
        float height = [sprite boundingBox].size.height/scale;
        
        if(sprite.anchorPoint.y == 0.5) {
            height /= 2;
        }
        
        float screenHeightScaled = (screenSize.height / scale);
        float bottomOfScreen = gamePlayHeight - screenHeightScaled;
        float topSpriteEdge = sprite.position.y + height;
        
        //if(bottomOfScreen > ((topSpriteEdge + 100)/scale)) {
        //    CCLOG(@"GAME PLAY HEIGHT %f, SCREEN HEIGHT %f, GAME HEIGHT %f, TOP EDGE %f", gamePlayHeight, screenHeightScaled, bottomOfScreen, topSpriteEdge);
        //}
        
        if (bottomOfScreen <= ((topSpriteEdge + ssipadauto(200))/scale)) {
            sprite.visible = YES;
        } else {
            sprite.visible = NO;
        }
    }
    else {
        sprite.visible = NO;
    }
    //CCLOG(@"I SET THIS TO %s", sprite.visible ? "VISIBLE" : "INVISIBLE");
}


// When GamePlayLayer creates a CCScaleTo action, it calls this as well.  Run equivalent,
// parallax-adjusted CCScaleTo actions on the parallax layers
- (void) scaleBy: (float)scaleAmount duration:(ccTime)duration {
    //CCLOG(@"CAME INTO SCALE BY: %f", scaleAmount);
    float backAmount = backParallax.scale - (scaleAmount*.35f);
    float hillAmount = hillParallax.scale - (scaleAmount*.55f);
    float frontAmount = frontParallax.scale - scaleAmount*0.95f;
    int  zoom = -1; // negative zooming in, positive zooming out
    //CCLOG(@"\n\n####  in Parallax.scaleBy:%f, dur=%f  curr values: back=%f, hill=%f, front=%f, new: back=%f, hill=%f, front=%f  ####\n\n", scaleAmount, duration, backParallax.scale, hillParallax.scale, frontParallax.scale, backAmount, hillAmount, frontAmount);
    
    if(scaleAmount > 0) {
        // zooming out
        zoom = 1;
    }
    
    //CCLOG(@"ZOOMING %@", zoom == -1 ? @"IN" : @"OUT");
    
    CCScaleTo *backScaleTo = [CCScaleTo actionWithDuration:duration scale:backAmount];
    CCScaleTo *hillScaleTo = [CCScaleTo actionWithDuration:duration scale:hillAmount];
    CCScaleTo *frontScaleTo = [CCScaleTo actionWithDuration:duration scale:frontAmount];
    CCScaleTo *frontAccentScaleTo = [CCScaleTo actionWithDuration:duration scale:frontAmount];
    CCScaleTo *groundScaleTo = [CCScaleTo actionWithDuration:duration scaleX:groundHolder.scaleX scaleY:frontAmount];
    
    if(zoom == 1) {
        // Zooming out - we want to show/hide sprites BEFORE we finish zooming out
        
        [self updateScales: frontAmount hill: hillAmount back: backAmount]; // update scale ahead of time
        [self setVisibleBackgrounds]; // we need to set the visible sprites AHEAD of time
        
        [backParallax runAction: backScaleTo];
        [hillParallax runAction: hillScaleTo];
        [frontParallax runAction: frontScaleTo];
        [frontAccent runAction: frontAccentScaleTo];
    }
    else {
        // Zooming in - we only want to show/hide sprites AFTER we finish zooming in
        CCSequence *backSeq = [CCSequence actions: backScaleTo, [CCCallFunc actionWithTarget:self selector:@selector(syncBackScale)], [CCCallFunc actionWithTarget:self selector:@selector(setVisibleBackSprites)], nil];
        CCSequence *hillSeq = [CCSequence actions: hillScaleTo, [CCCallFunc actionWithTarget:self selector:@selector(syncHillScale)], [CCCallFunc actionWithTarget:self selector:@selector(setVisibleHillSprites)], nil];
        CCSequence *frontSeq = [CCSequence actions: frontScaleTo, [CCCallFunc actionWithTarget:self selector:@selector(syncFrontScale)], [CCCallFunc actionWithTarget:self selector:@selector(setVisibleFrontSprites)], nil];
        CCSequence *frontAccentSeq = [CCSequence actions: frontAccentScaleTo, [CCCallFunc actionWithTarget:self selector:@selector(setVisibleFrontAccentSprites)], nil];
        
        [backParallax runAction:backSeq];
        [hillParallax runAction:hillSeq];
        [frontParallax runAction:frontSeq];
        [frontAccent runAction:frontAccentSeq];
    }
    
    [groundHolder runAction: groundScaleTo];
    //CCLOG(@"PARRALAX LAYER - DONE SCALING BY");
}

// scale is the change in scale of GamePlayLayer. scale the layers at the same rate
// as the parallax scrolling
- (void) zoomBy: (float) scaleAmount {
    //CCLOG(@"CAME INTO ZOOM BY: %f", scaleAmount);
    if (scaleAmount != 0) {
        backParallax.scale -= scaleAmount*.35f;
        hillParallax.scale -= scaleAmount*.55f;
        frontParallax.scale -= scaleAmount*0.95f;
        frontAccent.scale -= scaleAmount*0.95f;
        
        backScale = backParallax.scale;
        hillScale = hillParallax.scale;
        frontScale = frontParallax.scale;
        
        [self setVisibleBackgrounds];
        //CCLOG(@"PARRALAX LAYER - DONE ZOOMING BY");
    }
}

// XXX Need to get this to scroll both directions to support panning
- (void) scrollXBy:(float)scrollXAmount YBy:(float)scrollYAmount
{
    if(scrollXAmount == 0.0f && scrollYAmount == 0.0f) {
        return;
    }
    
//    gamePlayHeight = -1*scrollYAmount;
    
//    CCLOG(@"PBL.scroll:  changing pos from (%f,%f) to (%f,%f), deltas=(%f,%f)\n", self.position.x, self.position.y, self.position.x, self.position.y - (scrollYAmount * 0.3), scrollXAmount, scrollYAmount);
    
    CGPoint newPos = CGPointMake(self.position.x, self.position.y - (scrollYAmount * 0.3)); 
    if (newPos.y > maxYPos) {
        newPos.y = maxYPos;
    }
    self.position = newPos;
    gamePlayHeight = -1*self.position.y;
    
    //CCLOG(@"\n\nBACK PARALLAX START");
    [self scrollLayer: backParallax amount: scrollXAmount speed: 0.35f scale: backScale];
    
    //CCLOG(@"\n\nHILL PARALLAX START");
    [self scrollLayer: hillParallax amount: scrollXAmount speed: 0.55f scale: hillScale];
    
    //CCLOG(@"\n\nFRONT PARALLAX START");
    [self scrollLayer: frontParallax amount: scrollXAmount speed: 1.0f scale: frontScale];
    [self scrollLayer: frontAccent amount: scrollXAmount speed:1.0f scale: frontScale];
    
    [self setVisibleBackgrounds];
}

- (void) scrollLayer: (CCNode *) parallax amount: (float) scrollAmount speed: (float) speed scale: (float) scale
{
    //CCLOG(@"SCROLLING SCALE: %f, SCREEN SIZE: %f, SCROLL AMOUNT: %f", scale, visibleScreenWidth, scrollAmount);
    for(CCNode * sprite in [parallax children])
    {
        CGPoint pos = sprite.position;
        //CCLOG(@"=======>\n%s ORIGINAL POSITION: %f, SIZE: %f", sprite.visible == YES ? "VISIBLE" : "INVISIBLE", pos.x*scale, [sprite boundingBox].size.width);
        
        // Scroll by the requested amount, in either direction
        pos.x -= scrollAmount * speed;
        sprite.position = pos;
        
        // hide sprites that have now gone off screen, show those that are on screen
        [self showSprite: sprite : scale];
    }
}

- (void) cleanupLayer : (BOOL) forNextLevel 
{
    CCLOG(@"===  ParallaxBackgroundLayer.cleanupLayer  ===\n");
    
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    if (forNextLevel) {
        [self cleanupCrows : YES];
        [crows removeAllObjects];
        [crows release];
        crows = nil;
        
        [balloons removeAllObjects];
        [balloons release];
        balloons = nil;
        
        [flags removeAllObjects];
        [flags release];
        flags = nil;
        
        for (TorchFire * torch in torchFires) {
            [torch stopSystem];
            torch.visible = NO;
        }
        
        [torchFires removeAllObjects];
        [torchFires release];
        torchFires = nil;
        
        [foregroundObjects removeAllObjects];
        [foregroundObjects release];
        foregroundObjects = nil;
    }
    
    [frontParallax removeAllChildrenWithCleanup:YES];
    [frontAccent removeAllChildrenWithCleanup:YES];
    [backParallax removeAllChildrenWithCleanup:YES];
    [hillParallax removeAllChildrenWithCleanup:YES];
    [groundHolder removeAllChildrenWithCleanup:YES];
    
    [self removeChild:frontParallax cleanup:YES];
    [self removeChild:frontAccent cleanup:YES];
    [self removeChild:backParallax cleanup:YES];
    [self removeChild:hillParallax cleanup:YES];
    [self removeChild:groundHolder cleanup:YES];
    
    groundHolder = nil;
    frontParallax = nil;
    frontAccent = nil;
    backParallax = nil;
    hillParallax = nil;
    
    gamePlayHeight = 0;
    //self.position = CGPointZero;
    self.position = ccp(self.position.x, maxYPos);
}

- (void) dealloc {
    CCLOG(@"----------------------------- ParallaxBackgroundLayer dealloc");
    // Calling cleanupLayer above crashes due to crow cleanup calling updateObjectOnParallax
    // Don't want to duplicate code, but just ok for now
    [self stopAllActions];
    [self unscheduleAllSelectors];

    /*Crow *node;
    for (int crowIndex = [crows count]-1; crowIndex >= 0; crowIndex--) {
        node = (Crow*)[crows objectAtIndex:crowIndex];
        [node destroyPhysicsObject];
        [node removeFromParentAndCleanup:YES];
     }*/
    
    // Pick up crow animations from the selected world
    [Crow resetAnimations];
    
    [self cleanupCrows: YES];
    [crows removeAllObjects];
    [crows release];
    crows = nil;
        
    [balloons removeAllObjects];
    [balloons release];
    balloons = nil;
        
    [flags removeAllObjects];
    [flags release];
    flags = nil;
        
    [torchFires removeAllObjects];
    [torchFires release];
    torchFires = nil;
        
    [foregroundObjects removeAllObjects];
    [foregroundObjects release];
    foregroundObjects = nil;
    
    [frontParallax removeAllChildrenWithCleanup:YES];
    [frontAccent removeAllChildrenWithCleanup:YES];
    [backParallax removeAllChildrenWithCleanup:YES];
    [hillParallax removeAllChildrenWithCleanup:YES];
    [groundHolder removeAllChildrenWithCleanup:YES];
    
    [frontParallax removeFromParentAndCleanup:YES];
    [frontAccent removeFromParentAndCleanup:YES];
    [backParallax removeFromParentAndCleanup:YES];
    [hillParallax removeFromParentAndCleanup:YES];
    [groundHolder removeFromParentAndCleanup:YES];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WIND_BLOWING object:nil];

    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
