//
//  MainGameScene.m
//  Swinger
//
//  Created by James Sandoz on 4/23/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "MainGameScene.h"
#import "LevelCompleteScene.h"
#import "GamePlayLayer.h"
#import "StaticBackgroundLayer.h"
#import "SkyLayer.h"
#import "ParallaxBackgroundLayer.h"
#import "TouchCloudLayer.h"
#import "HUDLayer.h"
#import "AudioEngine.h"
#import "AudioManager.h"
#import "Notifications.h"


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
float PTM_RATIO;

@interface MainGameScene(Private)
- (void) addGamePlayLayer;
- (void) addHUDLayer;
- (void) addSkyLayer;
- (void) addStaticBackgroundLayer;
- (void) addParallaxBackgroundLayer;
- (void) addTouchCloudLayer;
@end

@implementation MainGameScene

@synthesize world;
@synthesize level;

static MainGameScene* instance;

// Screen Shake parameters
static double dtSum = 0;
static float shakeFactor = 0;
static float shakesPerSecond = 1000;

+ (MainGameScene *) sharedScene {
	NSAssert(instance != nil, @"MainGameScene instance not yet initialized!");
	return instance;
}

+ (id) nodeWithWorld:(NSString*)worldName level:(int)levelNumber {
    return [[[self alloc] initWithWorld:worldName level:levelNumber] autorelease];
}

- (id) initWithWorld:(NSString*)worldName level:(int)levelNumber {
    if ((self = [super init])) {
        instance = self;
        world = worldName;
        level = levelNumber;
        currentlyShaking = NO;
        
        screenSize = [CCDirector sharedDirector].winSize;
        [self loadAnimations];
        [self addStaticBackgroundLayer];
        [self addSkyLayer];
        [self addParallaxBackgroundLayer];
        [self addHUDLayer];
        [self addTouchCloudLayer];
        [self addGamePlayLayer];
    }
    
    return self;
}

- (void) loadAnimations {
    // This is where you load animations
    
    // Putting each animation loading in its own block for limit the scope
    // of the variables. Ran into a silly bug where I was using starFrames
    // for coins. Blocking it off like this will throw a compilation error
    // so we will be better able to avoid stupid bugs like this.
    
    // star animation
    {
        NSMutableArray *starFrames = [NSMutableArray array];
        for (int i=1; i <= 4; i++){
            NSString *file = [NSString stringWithFormat:@"Star%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [starFrames addObject:frame];
        }
        
        CCAnimation *animStars = [CCAnimation animationWithFrames:starFrames delay:.1f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animStars name:@"starAnimation"];
    }
    
    // coin animation
    {
        NSMutableArray *coinFrames = [NSMutableArray array];
        for (int i=1; i <= 4; i++){
            NSString *file = [NSString stringWithFormat:@"Coin%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [coinFrames addObject:frame];
        }
        
        CCAnimation *animCoins = [CCAnimation animationWithFrames:coinFrames delay:.1f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animCoins name:@"coinAnimation"];
    }
    
    // coin 5 animation
    {
        NSMutableArray *coinFrames = [NSMutableArray array];
        for (int i=1; i <= 4; i++){
            NSString *file = [NSString stringWithFormat:@"Coin5_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [coinFrames addObject:frame];
        }
        
        CCAnimation *animCoins = [CCAnimation animationWithFrames:coinFrames delay:.1f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animCoins name:@"coin5Animation"];
    }
    
    // coin 10 animation
    {
        NSMutableArray *coinFrames = [NSMutableArray array];
        for (int i=1; i <= 4; i++){
            NSString *file = [NSString stringWithFormat:@"Coin10_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [coinFrames addObject:frame];
        }
        
        CCAnimation *animCoins = [CCAnimation animationWithFrames:coinFrames delay:.1f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animCoins name:@"coin10Animation"];
    }
    
    if ([world isEqualToString: WORLD_GRASS_KNOLLS]) {
        
        // tent flag animation fast
        {
            NSMutableArray *flagFrames = [NSMutableArray array];
            for (int i=1; i <= 6; i++){
                NSString *file = [NSString stringWithFormat:@"L1a_TentFlag%d.png", i];
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
                [flagFrames addObject:frame];
            }
            
            CCAnimation *animFlag = [CCAnimation animationWithFrames:flagFrames delay:.125f];
            [[CCAnimationCache sharedAnimationCache] addAnimation:animFlag name:@"flagAnimation"];
        }
        
        // tent flag animation slow
        {
            NSMutableArray *flagFrames = [NSMutableArray array];
            for (int i=1; i <= 6; i++){
                NSString *file = [NSString stringWithFormat:@"L1a_TentFlag%d.png", i];
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
                [flagFrames addObject:frame];
            }
            
            CCAnimation *animFlag = [CCAnimation animationWithFrames:flagFrames delay:.15f];
            [[CCAnimationCache sharedAnimationCache] addAnimation:animFlag name:@"flagAnimationSlow"];
        }
    }
    
    // elephant walk animation
    {
        NSMutableArray *elephantFrames = [NSMutableArray array];
        for (int i=1; i <= 6; i++){
            NSString *file = [NSString stringWithFormat:@"ElephantWalk%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [elephantFrames addObject:frame];
        }
        
        CCAnimation *animElephant = [CCAnimation animationWithFrames:elephantFrames delay:.0833f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animElephant name:@"elephantWalkAnimation"];
    }
    
    // elephant buck animation
    {
        NSMutableArray *elephantFrames = [NSMutableArray array];
        for (int i=1; i <= 3; i++){
            NSString *file = [NSString stringWithFormat:@"ElephantBuck%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [elephantFrames addObject:frame];
        }
        
        CCAnimation *animElephant = [CCAnimation animationWithFrames:elephantFrames delay:.125f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animElephant name:@"elephantBuckAnimation"];
    }
    
    // strong man running animation
    {
        NSMutableArray *runningFrames = [NSMutableArray array];
        for (int i=1; i <= 7; i++){
            NSString *file = [NSString stringWithFormat:@"StrongmanRun%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [runningFrames addObject:frame];
        }
        
        CCAnimation *animStrongman = [CCAnimation animationWithFrames:runningFrames delay:.0733f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animStrongman name:@"strongmanRunAnimation"];
    }
    
    // strong man jumping animation
    {
        NSMutableArray *frames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:@"StrongmanJump.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [frames addObject:frame];
        }
        
        CCAnimation *animStrongman = [CCAnimation animationWithFrames:frames delay:.125f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animStrongman name:@"strongmanJumpAnimation"];
    }
    
    // strong man smashing animation
    {
        NSMutableArray *frames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:@"StrongmanSmash.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [frames addObject:frame];
        }
        
        CCAnimation *animStrongman = [CCAnimation animationWithFrames:frames delay:.125f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animStrongman name:@"strongmanSmashAnimation"];
    }
    
    // strong man standing animation
    {
        NSMutableArray *frames = [NSMutableArray array];
        for (int i=1; i <= 3; i++){
            NSString *file = [NSString stringWithFormat:@"StrongmanStand%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [frames addObject:frame];
        }
        
        CCAnimation *animStrongman = [CCAnimation animationWithFrames:frames delay:.125f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animStrongman name:@"strongmanStandAnimation"];
    }
    
    // wind direction/vane animation
    {
        NSMutableArray *frames = [NSMutableArray array];
        for (int i=1; i <= 6; i++){
            NSString *file = [NSString stringWithFormat:@"Wind_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [frames addObject:frame];
        }
        
        CCAnimation *animWindVane = [CCAnimation animationWithFrames:frames delay:.125f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animWindVane name:@"windArrowAnimation"];
    }
    
    if ([world isEqualToString: WORLD_GRASS_KNOLLS]) {
        // ground animation
        {
            NSMutableArray *frames = [NSMutableArray array];
            CCSpriteFrame *frame;
            for (int i=1; i <= 4; i++){
                NSString *file = [NSString stringWithFormat:@"%d.png", i];
                frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
                [frames addObject:frame];
            }
            
            for (int i=4; i >= 1; i--){
                NSString *file = [NSString stringWithFormat:@"%d.png", i];
                frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
                [frames addObject:frame];
            }
            
            CCAnimation *animGrass = [CCAnimation animationWithFrames:frames delay:.2f];
            [[CCAnimationCache sharedAnimationCache] addAnimation:animGrass name:@"groundAnimation"];
        }
    }
}

- (void) shake: (float) shakeAmt duration: (float) duration {
    
    if (currentlyShaking) {
        //CCLOG(@"Currently shaking, ignoring request!");
        return;
    }
    
    currentlyShaking = YES;
    shakeFactor = shakeAmt;
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(doShake:) forTarget:self interval:0.016 paused:NO];
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(stopShake) forTarget:self interval:duration paused:NO];
}

- (void) doShake : (ccTime) dt {
    dtSum += dt;
    float shakeX = sinf(dtSum*M_PI*2*shakesPerSecond) * shakeFactor;
    float shakeY = cosf(dtSum*M_PI*2*shakesPerSecond) * shakeFactor;
    
    self.position = ccp(shakeX, shakeY);
}

- (void) stopShake {
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(doShake:) forTarget:self];
    [[CCScheduler sharedScheduler] unscheduleSelector:@selector(stopShake) forTarget:self];
    currentlyShaking = NO;
    self.position = ccp(0,0);
}

- (void) addGamePlayLayer {
    [self addChild:[GamePlayLayer node] z:2];
}

- (void) addHUDLayer {
    [self addChild:[HUDLayer node] z:200];
}


- (void) addStaticBackgroundLayer {
    [self addChild:[StaticBackgroundLayer node] z:-10];
}

- (void) addSkyLayer {
    [self addChild:[SkyLayer node] z:-8];
}

- (void) addParallaxBackgroundLayer {
    [self addChild:[ParallaxBackgroundLayer node] z:1];
}

- (void) addTouchCloudLayer {
    [self addChild:[TouchCloudLayer node] z:3];
}

- (void) levelComplete: (UserData *) stats {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[LevelCompleteScene nodeWithStats:stats world: world level:level]]];
}

- (void)dealloc
{
    CCLOG(@"----------------------------- MainGameScene dealloc");
    [self unscheduleAllSelectors];
	[self stopAllActions];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
