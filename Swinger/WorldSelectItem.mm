//
//  WorldSelectItem.m
//  Swinger
//
//  Created by Min Kwon on 7/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "WorldSelectItem.h"
#import "Constants.h"
#import "Macros.h"
#import "LevelSelectScene.h"
#import "GPUtil.h"
#import "TextureTypes.h"
#import "AudioEngine.h"
#import "UserData.h"
#import "StoreManager.h"
#import "GPImageButton.h"
#import "StoreScene.h"

const int INS_FUNDS_TAG = 58;
const int BUY_CONF_TAG = 59;

@implementation WorldSelectItem

@synthesize worldName;

+ (id) nodeWithWorldName:(NSString*)world {
    return [[[self alloc] initWithWorldName:world] autorelease];
}

- (id) initWithWorldName:(NSString*)world {
    self = [super init];
    
    if (self) {
        worldName = world;
        StoreManager * store = [StoreManager sharedInstance];
        UserData * uData = [UserData sharedInstance];
        WorldData * wData = [store getWorldData:worldName];
        int levelsCompleted = [uData getNumLevelsCompleted];
        locked = wData.price > 0 && levelsCompleted < wData.level && ![uData isWorldPurchased:worldName];
        
        if ([WORLD_GRASS_KNOLLS isEqualToString:worldName]) {
            thumbNailSprite = [CCSprite spriteWithFile:@"GrassKnollsThumb.png"];
        }
        else if ([WORLD_FOREST_RETREAT isEqualToString:worldName]) {
            thumbNailSprite = [CCSprite spriteWithFile:@"ForestRetreatThumb.png"];
        }
        
        [self addChild:thumbNailSprite];
        
        if (locked) {
            lock = [CCSprite spriteWithFile:@"lock.png"];
            lock.scale = 2;
            lock.position = CGPointMake([thumbNailSprite boundingBox].size.width/2, [thumbNailSprite boundingBox].size.height/2);
            lock.anchorPoint = ccp(0.5, 0.5);
            [thumbNailSprite addChild:lock];
            
            CCLabelBMFont *levelNo = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", wData.level]
                                                            fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
            levelNo.scale = 0.5;
            levelNo.position = ccp(ssipadauto(12),ssipadauto(8)); //[lock boundingBox].size.width/2, [lock boundingBox].size.height/2 - ssipadauto(6));
            [lock addChild: levelNo];
            
            // Need a button with price to unlock the world early
            CCNode * myPrice = [CCNode node];
            CCLabelBMFont * coins = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%.f", wData.price] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
            coins.position = ccp(ssipadauto(8), 0);
            
            CCSprite *coinImg = [CCSprite spriteWithSpriteFrameName:@"Coin1_2.png"];
            coinImg.scale = 0.5;
            coinImg.position = ccp(-([coins boundingBox].size.width/2), 0);
            
            [myPrice addChild: coinImg];
            [myPrice addChild: coins];
            
            
            unlock = [GPImageButton controlOnTarget:self andSelector:@selector(unlockWorld) imageFromFile:@"Button_Store.png"];
            //unlock.scale = 0.85;
            unlock.scaleX = 0.9;
            unlock.scaleY = 1.25;
            unlock.position = CGPointMake(0, -([thumbNailSprite boundingBox].size.height/2 + [unlock boundingBox].size.height + ssipadauto(30)));
            myPrice.position = ccp(0, ssipadauto(-7));
            [unlock addChild: myPrice];
            
            CCLabelBMFont * msg = [CCLabelBMFont labelWithString:@"Unlock Now!" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
            msg.scale = 0.8;
            msg.position = ccp(ssipadauto(-10), ssipadauto(8));
            msg.rotation = -5;
            [unlock addChild: msg];
            
            [self addChild:unlock];
        }
    }
    
    return self;
}

- (void) unlockWorld {
    
    StoreManager * store = [StoreManager sharedInstance];
    UserData * uData = [UserData sharedInstance];
    WorldData * wData = [store getWorldData:worldName];
    
    if (uData.totalCoins >= wData.price) {
        //
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Buy %@?", worldName] message:[NSString stringWithFormat:@"Do you want to unlock this world for %.0f coins?", wData.price] delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:nil] autorelease];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"Yes!"];
        alert.tag = BUY_CONF_TAG;
        [alert show];
        
    } else {
        // give user option of getting more coins
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Need more coins..." message:@"Check out your options" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:nil] autorelease];
        alert.tag = INS_FUNDS_TAG;
        // optional - add more buttons:
        [alert addButtonWithTitle:@"Yes!"];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        if (alertView.tag == INS_FUNDS_TAG) {
            // not enough coins go to buy some
            [self goToBank];
        } else if (alertView.tag == BUY_CONF_TAG) {
            // purchase the world and unlock it
            StoreManager * store = [StoreManager sharedInstance];
            UserData * uData = [UserData sharedInstance];
            WorldData * wData = [store getWorldData:worldName];
            [uData purchaseWorld: worldName cost: wData.price];
            
            unlock.visible = NO;
            locked = NO;
            lock.visible = NO;
        }
    }
}

- (void) goToBank {
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreScene nodeWithScreen:kStoreBankType]]];
}


- (CGRect) boundingBox {
    return [thumbNailSprite boundingBox];
}

- (void) onEnter {
    CCLOG(@"**** WorldSelectItem onEnter");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** WorldSelectItem onExit");
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
                // Remove old atlas, if any
                
                id press = [CCScaleTo actionWithDuration:0.05 scale:0.9];
                id press2 = [CCScaleTo actionWithDuration:0.05 scale:1.05];
                id press3 = [CCScaleTo actionWithDuration:0.02 scale:0.95];
                id press4 = [CCScaleTo actionWithDuration:0.02 scale:1.02];
                id press5 = [CCScaleTo actionWithDuration:0.02 scale:0.98];
                id press6 = [CCScaleTo actionWithDuration:0.02 scale:1.0];
                
                id cb = [CCCallFunc actionWithTarget:self selector:@selector(loadLevel)];
                id seq = [CCSequence actions:press, press2, press3, press4, press5, press6, cb, nil];
                [self runAction:seq];
                [[AudioEngine sharedEngine] playEffect:SND_BLOP gain:[UserData sharedInstance].fxVolumeLevel];
            }
        }
    }
}

- (void) loadLevel {
    
    
    NSString *atlasName;            
    if ([WORLD_GRASS_KNOLLS isEqualToString:worldName]) {
        atlasName = BACKGROUND_ATLAS;
    }
    else if ([WORLD_FOREST_RETREAT isEqualToString:worldName]) {
        atlasName = FOREST_RETREAT_ATLAS;
    }            
    g_currentWorldAtlas = atlasName;
    
    
    [[CCTextureCache sharedTextureCache] addImageAsync:[GPUtil getAtlasImageName:g_currentWorldAtlas] 
                                                target:self 
                                              selector:@selector(loadAtlas:)];

}

- (void) loadAtlas:(CCTexture2D*)tex {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[GPUtil getAtlasPList:g_currentWorldAtlas] texture:tex];
    [tex setAliasTexParameters];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 
                                                                                 scene:[LevelSelectScene nodeWithWorld:worldName]]];
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
