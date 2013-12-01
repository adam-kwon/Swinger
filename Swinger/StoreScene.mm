//
//  StoreScene.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/27/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "GPLabel.h"
#import "GPUtil.h"
#import "CCLayerColor+extension.h"
#import "LevelSelectScene.h"
#import "GPImageButton.h"
#import "AudioEngine.h"
#import "TextureTypes.h"
#import "StoreScene.h"
#import "UserData.h"
#import "MainMenuScene.h"
#import "StoreItem.h"
#import "PlayerChooser.h"
#import "PowerUpChooser.h"
#import "LifeLineChooser.h"
#import "BankChooser.h"

const int NEW_ITEM_TAG = 578223;
NSMutableArray * buttonCache;

@implementation StoreScene

+ (id) node {
    return [[[self alloc] init] autorelease];
}

+ (id) nodeWithScreen: (StoreItemType) screen {
    return [[[self alloc] initWithStartScreen: screen] autorelease];
}

- (id) init {
    return [self initWithStartScreen: kStorePlayerType];
}

- (id) initWithStartScreen: (StoreItemType) startScreen {
    
    if (self = [super init]) {
        
        storeData = [StoreManager sharedInstance];
        userData = [UserData sharedInstance];
        
        [self loadSpriteSheets];
        screenSize = [[CCDirector sharedDirector] winSize];
        buttonCache = [[NSMutableArray alloc] initWithCapacity: 4];
        
        // Nil out screens - not sure if necessary
        playerScreen = nil;
        powerUpScreen = nil;
        livesScreen = nil;
        bankScreen = nil;
        
        // shadow
        CCLayerColor * shadow = [CCLayerColor getFullScreenLayerWithColor:ccc3to4(CC3_COLOR_BLUE, 40)];
        shadow.anchorPoint = CGPointZero;
        shadow.position = CGPointZero;
        [self addChild:shadow z:-1];
        
        CCNode * bankInfo = [self createBankInfo];
        
        // Level section
        level = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Level %d", [userData getNumLevelsCompleted]] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        level.anchorPoint = ccp(0,0.5);
        level.position = ccp(ssipad(10,5),ssipad(100,50)); //ccp(lives1.position.x, lifeLines.position.y - ssipadauto(16));
        [bankInfo addChild: level z:1];
        
        // Coins section
        CCSprite * coinImg = [CCSprite spriteWithSpriteFrameName:@"Coin4.png"];
        GPImageButton *coin1 = [GPImageButton controlOnTarget:self andSelector:@selector(goToBank) imageFromSprite:coinImg];
        coin1.scale = 0.5;
        coin1.position = ccp(level.position.x + ssipadauto(28), level.position.y - ssipadauto(20));
        [bankInfo addChild: coin1];
        
        coins = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", userData.totalCoins] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        coins.anchorPoint = ccp(0,0.5);
        coins.position = ccp(coin1.position.x + ssipadauto(8), coin1.position.y);
        [bankInfo addChild: coins z:1];
        
        CCSprite * livesImg = [CCSprite spriteWithSpriteFrameName:@"Star4.png"];
        GPImageButton *lives1 = [GPImageButton controlOnTarget:self andSelector:@selector(buyLifeLines) imageFromSprite:livesImg];
        lives1.scale = 0.4;
        lives1.position = ccp(coin1.position.x, coin1.position.y - ssipadauto(16));
        [bankInfo addChild: lives1];
        
        lifeLines = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", userData.totalLives] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        //lifeLines.scale = 0.5;
        lifeLines.anchorPoint = ccp(0,0.5);
        lifeLines.position = ccp(coins.position.x, lives1.position.y);
        [bankInfo addChild: lifeLines z:1];
        
        CCSprite *plusBtn = [CCSprite spriteWithFile:@"plusButton.png"];
        plusBtn.scale = 0.70;
        GPImageButton *addBank = [GPImageButton controlOnTarget:self andSelector:@selector(goToBank) imageFromSprite:plusBtn];
        addBank.position = ccp(lives1.position.x - ssipadauto(18), lives1.position.y + ssipadauto(10));
        [bankInfo addChild: addBank];
        
        // main buttons
        GPImageButton *backButton = [GPImageButton controlOnTarget:self andSelector:@selector(goBack) imageFromFile:@"backButton.png"];
        backButton.position = CGPointMake(ssipad(90, 45), ssipad(734, 304));
        CCLabelBMFont *backText = [CCLabelBMFont labelWithString:@"BACK" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        [backButton setText:backText];
        
        [self addChild:backButton];
        
        player = [GPImageButton controlOnTarget:self andSelector:@selector(pickPlayer) imageFromFile:@"Button_Store.png"];
        CCLabelBMFont *text = [CCLabelBMFont labelWithString:@"PLAYER" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.85;
        [player setText:text];
        player.position = ccp(ssipad(150, 75), ssipad(bankInfo.position.y - 250, bankInfo.position.y - 115));
        [self addChild:player];
        [buttonCache addObject:player];
        
        float buttonGap = ssipadauto(45);
        
        powerUps = [GPImageButton controlOnTarget:self andSelector:@selector(buyPowerups) imageFromFile:@"Button_Store.png"];
        text = [CCLabelBMFont labelWithString:@"POWER UPS" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.85f;
        [powerUps setText:text];
        powerUps.position = ccp(player.position.x, player.position.y - buttonGap);
        [self addChild:powerUps];
        [buttonCache addObject: powerUps];
        
        [powerUps removeChildByTag:NEW_ITEM_TAG cleanup:YES];
        if (storeData.newItemUnlocked) {
            
            CCSprite * newSprite = [CCSprite spriteWithFile:@"new.png"];
            newSprite.scale = 0.75;
            newSprite.position = ccp(ssipadauto(60),
                                     ssipadauto(20));
            [powerUps addChild: newSprite z:2 tag:NEW_ITEM_TAG];
        }
        
        lives = [GPImageButton controlOnTarget:self andSelector:@selector(buyLifeLines) imageFromFile:@"Button_Store.png"];
        text = [CCLabelBMFont labelWithString:@"LIFE LINES" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.85f;
        [lives setText:text];
        lives.position = ccp(powerUps.position.x, powerUps.position.y - buttonGap);
        [self addChild:lives];
        [buttonCache addObject: lives];
        
        bank= [GPImageButton controlOnTarget:self andSelector:@selector(goToBank) imageFromFile:@"Button_Store.png"];
        text = [CCLabelBMFont labelWithString:@"BANK" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        text.scale = 0.85f;
        [bank setText:text];
        bank.position = ccp(lives.position.x, lives.position.y - buttonGap);
        [self addChild:bank];
        [buttonCache addObject: bank];
        
        // Separator
        ccColor4B lineColor = ccc3to4(CC3_COLOR_CANTALOPE, 255);
        
        CCLayerColor *separator = [CCLayerColor layerWithColor:lineColor];
        [separator setContentSize:CGSizeMake(1,ssipad(-694,-300))];
        separator.position = ccp(player.position.x + [player boundingBox].size.width + ssipad(126, 63), player.position.y + ssipad(200, 100));
        [self addChild: separator z:-1];
        
        // Content Area
        contentArea = [CCNode node];
        contentArea.anchorPoint = ccp(0,1);
        contentArea.contentSize = ssipad(CGSizeMake(730,700), CGSizeMake(333,296));
        contentArea.position = ccp(separator.position.x + ssipadauto(2), backButton.position.y);
        [self addChild: contentArea z:-1];
        
        /*background = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 100)];
         background.contentSize = contentArea.contentSize;
         background.anchorPoint = contentArea.anchorPoint;
         background.position = ccp(0,0);
         [contentArea addChild: background z:-1];*/
        
        //CCSprite * wallPaper = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        CCSprite * wallPaper = [CCSprite spriteWithSpriteFrameName:@"L1a_Background.png"];
        wallPaper.scale = 1.2f;
        wallPaper.anchorPoint = CGPointZero;
        wallPaper.position = CGPointZero;
        [self addChild: wallPaper z:-2];
        
        switch (startScreen) {
            case kStorePowerUpType:
                [self buyPowerups];
                break;
            case kStoreLifeLineType:
                [self buyLifeLines];
                break;
            case kStoreBankType:
                [self goToBank];
                break;
            default:
                [self pickPlayer];
                break;
        }
    }
    
    return self;
}

- (CCNode *) createBankInfo {
    
    CCNode * bankInfo = [CCNode node];
    bankInfo.contentSize = ssipad(CGSizeMake(240, 120), CGSizeMake(120, 60));
    bankInfo.anchorPoint = ccp(0,1);
    bankInfo.position = ccp(ssipadauto(10), screenSize.height - ssipad(100, 40));
    [self addChild: bankInfo];
    
    CCLayerColor *background = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_STEEL_BLUE, 225)];
    background.contentSize = bankInfo.contentSize;
    background.anchorPoint = bankInfo.anchorPoint;
    background.position = ccp(0,0);
    [bankInfo addChild: background z:-1];
    
    // Borders
    CCLayerColor * border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
    border.contentSize = CGSizeMake(bankInfo.contentSize.width, 1);
    border.anchorPoint = bankInfo.anchorPoint;
    border.position = ccp(0,0);
    [bankInfo addChild: border z:-1];
    
    border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
    border.contentSize = CGSizeMake(1, bankInfo.contentSize.height);
    border.anchorPoint = bankInfo.anchorPoint;
    border.position = ccp(bankInfo.contentSize.width - 1, 0);
    [bankInfo addChild: border z:-1];
    
    border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
    border.contentSize = CGSizeMake(1, bankInfo.contentSize.height);
    border.anchorPoint = bankInfo.anchorPoint;
    border.position = ccp(0, 0);
    [bankInfo addChild: border z:-1];
    
    border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
    border.contentSize = CGSizeMake(bankInfo.contentSize.width, 1);
    border.anchorPoint = bankInfo.anchorPoint;
    border.position = ccp(0, bankInfo.contentSize.height - 1);
    [bankInfo addChild: border z:-1];
    
    return bankInfo;
}

- (void) buttonClicked: (GPImageButton *) button {
    
    [self scaleUp: button];
    [button setTextColor:CC3_COLOR_WHITE];
    for (GPImageButton * btn in buttonCache) {
        if (btn != button) {
            [self scaleDown: btn];
            [btn setTextColor:CC3_COLOR_CANTALOPE];
        }
    }
}

- (void) scaleDown: (GPImageButton *) btn {
    
    CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:0.05 scale:0.8f];
    CCEaseIn  * easeIn  = [CCEaseIn actionWithAction: scaleTo];
    
    [btn runAction: easeIn];
}

- (void) scaleUp: (GPImageButton *) btn {
    
    CCScaleTo * scaleTo = [CCScaleTo actionWithDuration:0.05 scale:0.9f];
    CCEaseOut  * easeOut  = [CCEaseOut actionWithAction: scaleTo];
    
    [btn runAction: easeOut];
}

- (void) pickPlayer {
    [self buttonClicked: player];
    
    if (playerScreen == nil) {
        // lazy initialization
        [self createPlayerScreen];
    } else if (!playerScreen.visible) {
        [playerScreen onEnter];
    }
    
    [self show: playerScreen];
}

- (void) buyPowerups {
    storeData.newItemUnlocked = NO;
    [self buttonClicked: powerUps];
    
    if (powerUpScreen == nil) {
        // lazy initialization
        [self createPowerUpScreen];
    } else if (!powerUpScreen.visible) {
        [powerUpScreen onEnter];
    }
    
    [self show: powerUpScreen];
}

- (void) buyLifeLines {
    [self buttonClicked: lives];
    
    if (livesScreen == nil) {
        // lazy initialization
        [self createLivesScreen];
    } else if (!livesScreen.visible) {
        [livesScreen onEnter];
    }
    
    [self show: livesScreen];
}

- (void) goToBank {
    [self buttonClicked: bank];
    
    if (bankScreen == nil) {
        // lazy initialization
        [self createBankScreen];
    } else if (!bankScreen.visible) {
        [bankScreen onEnter];
    }
    
    [self show: bankScreen];
}

- (void) show: (StoreChooser *) screen {
    
    screen.visible = YES;
    
    // hide other screens
    if (playerScreen != screen && playerScreen != nil) {
        playerScreen.visible = NO;
        [playerScreen onExit];
    }
    
    if (powerUpScreen != screen && powerUpScreen != nil) {
        powerUpScreen.visible = NO;
        [powerUpScreen onExit];
    }
    
    if (livesScreen != screen && livesScreen != nil) {
        livesScreen.visible = NO;
        [livesScreen onExit];
    }
    
    if (bankScreen != screen && bankScreen != nil) {
        bankScreen.visible = NO;
        [bankScreen onExit];
    }
}

- (void) setPlayerSkin: (id) obj {
    int index = [obj numberValue].intValue;
    
    if (index == 0) {
        // select gonzo
        [userData setPlayerType:kPlayerTypeGonzo];
    }
}

- (void) refresh {
    
    [coins setString: [NSString stringWithFormat:@"%d", userData.totalCoins]];
    [lifeLines setString: [NSString stringWithFormat:@"%d", userData.totalLives]];
    
    // refresh individual sub-screens
    [playerScreen refresh];
    [powerUpScreen refresh];
    [livesScreen refresh];
    [bankScreen refresh];
}

- (void) goBack {
    //[[AudioEngine sharedEngine] stopBackgroundMusic];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MainMenuScene node]]];
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:0.5f];
}

- (void) onEnter {
    CCLOG(@"**** StoreScene onEnter");
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:userData.musicVolumeLevel];
        [[AudioEngine sharedEngine] playBackgroundMusic:MENU_MUSIC loop:YES];
    }
    [super onEnter];
}

- (void) onExit {
    CCLOG(@"**** StoreScene onExit");
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
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    lastMoved = touchPoint;
}

- (void) createPlayerScreen {
    playerScreen = [PlayerChooser make: ssipad(CGSizeMake(730-10,700), CGSizeMake(screenSize.width - 152,306)) store: self];
    [contentArea addChild: playerScreen z:1];
}

- (void) createPowerUpScreen {
    powerUpScreen = [PowerUpChooser make: ssipad(CGSizeMake(730-10,700), CGSizeMake(screenSize.width - 152,306)) store: self];
    [contentArea addChild: powerUpScreen z:1];
}

- (void) createLivesScreen {
    livesScreen = [LifeLineChooser make: ssipad(CGSizeMake(730-10,700), CGSizeMake(screenSize.width - 152,306)) store: self];
    [contentArea addChild: livesScreen z:1];
}

- (void) createBankScreen {
    bankScreen = [BankChooser make: ssipad(CGSizeMake(730-10,700), CGSizeMake(screenSize.width - 152,306)) store: self];
    [contentArea addChild: bankScreen z:1];
}

- (void) loadSpriteSheets {    
    
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:[GPUtil getAtlasImageName:BACKGROUND_ATLAS]];        
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[GPUtil getAtlasPList:BACKGROUND_ATLAS] texture:tex];
    [tex setAliasTexParameters];
}

- (void) dealloc {
    CCLOG(@"*******STORE SCENE DEALLOCATED******");
    [buttonCache removeAllObjects];
    [buttonCache release];
    
    [super dealloc];
}

@end
