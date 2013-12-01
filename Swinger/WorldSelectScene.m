//
//  WorldSelectScene.m
//  Swinger
//
//  Created by Min Kwon on 6/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "WorldSelectScene.h"
#import "TextureTypes.h"
#import "CCLayerColor+extension.h"
#import "Macros.h"
#import "LevelSelectScene.h"
#import "GPImageButton.h"
#import "MainMenuScene.h"
#import "WorldSelectItem.h"
#import "Constants.h"

@implementation WorldSelectScene

- (id) init {
    self = [super init];
    if (self) {
        screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *wallPaper = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        wallPaper.scaleX = screenSize.width/[wallPaper boundingBox].size.width + 0.1;
        wallPaper.scaleY = screenSize.height/[wallPaper boundingBox].size.height + 0.1;
        wallPaper.anchorPoint = CGPointZero;
        wallPaper.position = CGPointZero;
        [self addChild:wallPaper z:-2];
        
        // shadow
        CCSprite *shadow = [CCLayerColor getFullScreenLayerWithColor: ccc3to4(CC3_COLOR_BLACK, 0)];
        shadow.anchorPoint = CGPointZero;
        shadow.position = CGPointZero;
        [self addChild:shadow z:-1];
        
        [self moveWallpaper: wallPaper];

        GPImageButton *backButton = [GPImageButton controlOnTarget:self andSelector:@selector(goBack) imageFromFile:@"backButton.png"];
        backButton.position = CGPointMake(ssipad(890, screenSize.width - 46), ssipad(704, 298));
        [self addChild:backButton];

        CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"BACK" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        [backButton setText:backText];

        
        background = [CCNode node];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild:background];

        const int gap = ssipad(140, 70);// + (screenSize.width - 480));
        worlds = [[CCArray alloc] init];
        
        WorldSelectItem *world1;
        world1 = [WorldSelectItem nodeWithWorldName:WORLD_GRASS_KNOLLS];
        world1.position = CGPointMake(screenSize.width/2, screenSize.height/2);
        [background addChild:world1];
        [worlds addObject:world1];

        WorldSelectItem *world2 = [WorldSelectItem nodeWithWorldName:WORLD_FOREST_RETREAT];
        world2.position = CGPointMake(world1.position.x + [world1 boundingBox].size.width + gap, world1.position.y);
        [background addChild:world2];
        [worlds addObject:world2];

//        WorldSelectItem *world3 = [WorldSelectItem nodeWithWorldName:WORLD_GRASS_KNOLLS];
//        world3.position = CGPointMake(world2.position.x + [world2 boundingBox].size.width + gap, world2.position.y);
//        [background addChild:world3];
//        [worlds addObject:world3];
        
        currentlyVisibleWorldIndex = 0;
        
        
        dots = [CCNode node];
        dots.anchorPoint = CGPointZero;
        [self addChild:dots];
        
        const int dotGap = 5;
        int i;
        int totalWidth = 0;
        
        for (i = 0; i < 2; i++) {
            CCSprite *dot = [CCSprite spriteWithFile:@"whiteDot.png"];
            dot.anchorPoint = CGPointZero;
            if (i == 0) {
                dot.color = ccc3(255, 255, 255);
            } else {
                dot.color = ccc3(0, 0, 0);
            }
            dot.scale = 0.40;
            [dots addChild:dot];
            dot.position = CGPointMake(i*[dot boundingBox].size.width + i*dotGap, 0);
            totalWidth += [dot boundingBox].size.width;
        }
        totalWidth += ((i-1) * dotGap);
        dots.position = CGPointMake(screenSize.width/2 - totalWidth/2, ssipad(30, 15));

    }
    
    return self;
}

- (void) moveWallpaper: (CCSprite *) theWallpaper {
    float duration = 20;
    float moveAmt = [theWallpaper boundingBox].size.width - screenSize.width;
    
    theWallpaper.position = ccp(0,0);
    
    if (moveAmt > 0) {
        
        CCMoveBy * scrollRight = [CCMoveBy actionWithDuration:duration position: ccp(theWallpaper.position.x - moveAmt, 0)];
        CCScaleTo * scaleUp = [CCScaleBy actionWithDuration:duration scale:1.25f];
        CCSpawn * spawn1 = [CCSpawn actionOne:scrollRight two:scaleUp];
        
        [theWallpaper stopAllActions];
        [theWallpaper runAction: [CCRepeatForever actionWithAction:[CCSequence actions:spawn1, [spawn1 reverse], nil]]];
    }
}

- (void) goBack {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MainMenuScene node]]];    
}

- (void) onEnter {
    CCLOG(@"**** WorldSelectScene onEnter");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** WorldSelectScene onExit");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

#pragma mark - Touch Handling
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    touchStart = [touch locationInView:[touch view]];
    touchStart = [[CCDirector sharedDirector] convertToGL:touchStart];
    
    lastMoved = touchStart;
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    const int threshold = 40;
    float deltaScroll = touchPoint.x - touchStart.x;
    
    WorldSelectItem *world;
    if (deltaScroll < -threshold) {
        // Scroll right to left
        currentlyVisibleWorldIndex = MIN([worlds count]-1, currentlyVisibleWorldIndex+1);        
    } else if (deltaScroll > threshold) {
        // Scroll left to right
        currentlyVisibleWorldIndex = MAX(0, currentlyVisibleWorldIndex-1);
    } else {
        // Selection (touch)
        // Handled by respective WorldSelectItems
    }

    world = [worlds objectAtIndex:currentlyVisibleWorldIndex];
    float nextX = normalizeToScreenCoord(background.position.x, world.position.x, 1.0);
    float deltaX = nextX - screenSize.width/2;
    id ease = [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:0.25 
                                                                  position:CGPointMake(-deltaX, 0)]];
    [background runAction:ease];

    CCSprite *sprite;
    for (int i = 0; i < [[dots children] count]; i++) {
        sprite = [[dots children] objectAtIndex:i];
        if (i == currentlyVisibleWorldIndex) {
            sprite.color = ccc3(255, 255, 255);            
        } else {
            sprite.color = ccc3(0, 0, 0);
        }
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    float deltaScroll = touchPoint.x - lastMoved.x;
    background.position = CGPointMake(background.position.x + deltaScroll, background.position.y);
    
    lastMoved = touchPoint;
}

- (void) dealloc {
    CCLOG(@"------------------ WorldSelectScene dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [worlds removeAllObjects];
    [worlds release];
    [self removeAllChildrenWithCleanup:YES];
        
    [super dealloc];
}

@end
