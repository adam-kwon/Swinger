//
//  LevelSelectScene.m
//  Swinger
//
//  Created by Min Kwon on 6/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "LevelSelectScene.h"
#import "CCLayerColor+extension.h"
#import "Macros.h"
#import "MainGameScene.h"
#import "AudioEngine.h"
#import "GPImageButton.h"
#import "WorldSelectScene.h"
#import "LevelSelectItem.h"
#import "UserData.h"

@implementation LevelSelectScene


+ (id) nodeWithWorld:(NSString*)worldName {
    return [[[self alloc] initWithWorld:worldName] autorelease];
}

- (id) initWithWorld:(NSString*)worldName {
    self = [super init];
    if (self) {
        screenSize = [[CCDirector sharedDirector] winSize];

        // shadow
        CCSprite *shadow = [CCLayerColor getFullScreenLayerWithColor: ccc3to4(CC3_COLOR_BLACK, 0)];
        shadow.anchorPoint = CGPointZero;
        shadow.position = CGPointZero;
        [self addChild:shadow z:-1];
        
        CCSprite *wallPaper = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        wallPaper.scaleX = screenSize.width/[wallPaper boundingBox].size.width + 0.1;
        wallPaper.scaleY = screenSize.height/[wallPaper boundingBox].size.height + 0.1;
        wallPaper.anchorPoint = CGPointZero;
        wallPaper.position = CGPointZero;
        [self addChild:wallPaper z:-2];

        [self moveWallpaper: wallPaper];
        
        GPImageButton *backButton = [GPImageButton controlOnTarget:self andSelector:@selector(goBack) imageFromFile:@"backButton.png"];
        backButton.position = CGPointMake(ssipad(890, screenSize.width - 46), ssipad(704, 298));
        
        CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"BACK" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        [backButton setText:backText];

        [self addChild:backButton];
        
        CCLabelBMFont *worldNameText = [CCLabelBMFont labelWithString:worldName fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        worldNameText.anchorPoint = ccp(0,1);
        worldNameText.position = CGPointMake(ssipad(100, 30), ssipad(704, 298));
        [self addChild:worldNameText];
        
        
        background = [CCNode node];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild:background];
        
        // Let's just manually lay them out for now.
        startX = ssipad(200, 70 + screenSize.width - 480);
        const int startY = ssipad(480, 215);
        const int horizontalGap = ssipadauto(105);
        const int verticalGap = ssipadauto(110);
        
        const int columns = 8;
        const int rows = 2;

        levels = [[CCArray alloc] init];

        int level;
        for (int row = 0; row < rows; row++) {
            if (row == 0) {
                level = 1;
            } else {
                level = 5;
            }
            CGPoint previousPosition = CGPointMake(startX, startY - row * verticalGap);
            
            LevelSelectItem *levelSpriteStart = [LevelSelectItem nodeWithWorldName:worldName level:level++];
            levelSpriteStart.position = previousPosition;
            [background addChild:levelSpriteStart];
            [levels addObject:levelSpriteStart];

            for (int col = 1; col < columns; col++) {
                if (0 == row && 4 == col) {
                    level = 9;
                } else if (1 == row && 4 == col) {
                    level = 13;
                }
                LevelSelectItem *levelSprite = [LevelSelectItem nodeWithWorldName:worldName level:level++];
                levelSprite.position = CGPointMake(previousPosition.x + horizontalGap, previousPosition.y);
                [background addChild:levelSprite];
                [levels addObject:levelSprite];
                
                previousPosition = levelSprite.position;
            }
        }
        
        // get largest level achieved in the current world
        int highLevel = [[UserData sharedInstance] getLevel: worldName];
        int dotIndex = 0;
        
        if (highLevel > 8 && highLevel < 16) {
            
            id ease = [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:0.25
                                                                          position:CGPointMake(-(screenSize.width-ssipadauto(92)), 0)]];
            [background runAction:ease];
            
            dotIndex = 1;
        }
        
        dots = [CCNode node];
        dots.anchorPoint = CGPointZero;
        [self addChild:dots];
        
        const int dotGap = 5;
        int i;
        int totalWidth = 0;
        
        for (i = 0; i < 2; i++) {
            CCSprite *dot = [CCSprite spriteWithFile:@"whiteDot.png"];
            dot.anchorPoint = CGPointZero;
            if (i == dotIndex) {
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
        dots.position = CGPointMake(screenSize.width/2 - totalWidth/2, 30);
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[WorldSelectScene node]]];    
}

- (void) onEnter {
    CCLOG(@"**** LevelSelectScene onEnter");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:[UserData sharedInstance].musicVolumeLevel];
        [[AudioEngine sharedEngine] playBackgroundMusic:MENU_MUSIC loop:YES];
    }
    
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** LevelSelectScene onExit");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self stopAllActions];
    [self unscheduleAllSelectors];
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
    
    CCSprite *level;
    if (deltaScroll < -threshold) {
        // Scroll right to left
        spriteIndex = 4;
        
    } else if (deltaScroll > threshold) {
        // Scroll left to right
        spriteIndex = 0;
    } else {
        // Selection (touch)
        // Handled by respective LevelSelectItems
        return;
    }
    
    level = [levels objectAtIndex:spriteIndex];
    float nextX = normalizeToScreenCoord(background.position.x, level.position.x, 1.0);
    float deltaX = nextX - startX;
    
    id ease = [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:0.25 
                                                                  position:CGPointMake(-deltaX, 0)]];
    [background runAction:ease];
    
    CCSprite *sprite;
    for (int i = 0; i < [[dots children] count]; i++) {
        sprite = [[dots children] objectAtIndex:i];
        if (i == spriteIndex/4) {
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
    CCLOG(@"------------------ LevelSelectScene dealloc");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [levels removeAllObjects];
    [levels release];
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}
@end
