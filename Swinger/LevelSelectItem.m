//
//  LevelSelectItem.m
//  Swinger
//
//  Created by Min Kwon on 7/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "LevelSelectItem.h"
#import "Constants.h"
#import "MainGameScene.h"
#import "AudioEngine.h"
#import "GameLoadingScene.h"
#import "UserData.h"
#import "CCLabelBMFont.h"
#import "CCTouchDispatcher.h"

@implementation LevelSelectItem

@synthesize worldName;
@synthesize level;

+ (id) nodeWithWorldName:(NSString*)world level:(int)levelNumber {
    return [[[self alloc] initWithWorldName:world level:levelNumber] autorelease];
}

- (id) initWithWorldName:(NSString*)world level:(int)levelNumber {
    self = [super init];
    
    if (self) {
        worldName = world;
        level = levelNumber;
        UserData * userData = [UserData sharedInstance];
        int unlockedLevel = [userData getLevel:worldName];
        locked = NO;//level > unlockedLevel; //YES;
        
        if ([WORLD_GRASS_KNOLLS isEqualToString:worldName]) {
            thumbNailSprite = [CCSprite spriteWithFile:@"Level1SelectThumb.png"];
            
            /*switch (level) {
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                case 10:
                case 11:
                case 12:
                case 13:
                case 14:
                case 15:
                case 16:
                    locked = NO;
                    break;
                default:                    
                    break;
            }*/
        }
        else if ([WORLD_FOREST_RETREAT isEqualToString:worldName]) {
            thumbNailSprite = [CCSprite spriteWithFile:@"Level2SelectThumb.png"];            
            /*switch (level) {
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    locked = NO;
                    break;
                default:                    
                    break;
            }*/
        }
        [self addChild:thumbNailSprite];
                
        if (locked) {
            CCSprite *lock = [CCSprite spriteWithFile:@"lock.png"];
            lock.position = CGPointMake([thumbNailSprite boundingBox].size.width/2, [thumbNailSprite boundingBox].size.height/2);            
            [thumbNailSprite addChild:lock];
        } else {
            UserData* uData = [UserData sharedInstance];
            CCLabelBMFont *levelNo = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", level] 
                                                            fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
            if ([uData getLevel: worldName] > level) {
                levelNo.color = CC3_COLOR_GRAY2;
            } else {
                levelNo.color = CC3_COLOR_WHITE;
            }
            
            levelNo.position = CGPointMake([thumbNailSprite boundingBox].size.width/2, [thumbNailSprite boundingBox].size.height/2);
            [thumbNailSprite addChild:levelNo];
        }
    }
    
    return self;
}

- (CGRect) boundingBox {
    return [thumbNailSprite boundingBox];
}

- (void) onEnter {
    CCLOG(@"**** LevelSelectItem onEnter");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** LevelSelectItem onExit");
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
    
    if (deltaScroll < -threshold) {
        // Scroll right to left
    } else if (deltaScroll > threshold) {
        // Scroll left to right
    } else {
        // Selection (touch)
        if (!locked) {
            float screenX = normalizeToScreenCoord(self.parent.position.x, self.position.x, 1.0);
            CGRect spriteRect = CGRectMake(screenX - [self boundingBox].size.width/2, 
                                           self.position.y - [self boundingBox].size.height/2, 
                                           [self boundingBox].size.width, 
                                           [self boundingBox].size.height);
            
            if (CGRectContainsPoint(spriteRect, touchPoint)) {
                id press = [CCScaleTo actionWithDuration:0.05 scale:0.9];
                id press2 = [CCScaleTo actionWithDuration:0.05 scale:1.05];
                id press3 = [CCScaleTo actionWithDuration:0.02 scale:0.95];
                id press4 = [CCScaleTo actionWithDuration:0.02 scale:1.02];
                id press5 = [CCScaleTo actionWithDuration:0.02 scale:0.98];
                id press6 = [CCScaleTo actionWithDuration:0.02 scale:1.0];
                id cb = [CCCallFunc actionWithTarget:self selector:@selector(startGame)];
                id seq = [CCSequence actions:press, press2, press3, press4, press5, press6, cb, nil];
                [self runAction:seq];
                [[AudioEngine sharedEngine] playEffect:SND_BLOP gain:[UserData sharedInstance].fxVolumeLevel];        
            }
        }
    }    
}

- (void) startGame {
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5
    //                                                                             scene:[MainGameScene nodeWithWorld:worldName level:level]]];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.1
                                                                                 scene:[GameLoadingScene nodeWithDelay:3 goTo:kGoToSceneGameStart world:worldName level:level]]];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    lastMoved = touchPoint;
}

- (void) dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
