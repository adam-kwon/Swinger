//
//  LevelCompleteScene.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/18/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "LevelCompleteScene.h"
#import "LevelCompleteScoreCard.h"
#import "GPLabel.h"
#import "GPUtil.h"
#import "CCLayerColor+extension.h"
#import "LevelSelectScene.h"
#import "GPImageButton.h"
#import "AudioEngine.h"
#import "TextureTypes.h"
#import "PlayerTrail.h"
#import "StoreScene.h"
#import "AchievementManager.h"
#import "GameLoadingScene.h"
#import "StoreManager.h"
#import "PowerUpData.h"
#import "LifeLineData.h"
#import "WorldData.h"
#import "UserData.h"
#import "TorchFire.h"

static const float maxAngle = 75;
static const int unlockedItemTag = 12345678;
static const int NEW_ITEM_TAG = 1234456;
static float angleInc = 7.5;
static CGPoint logoPos;
static float ropeLength;

// Screen Shake parameters
static double dtSum = 0;
static float shakeFactor = 0;
static float shakesPerSecond = 1000;
static float shakeDuration = 5.5f;
static float cardNum = 0;
static float cardDistance = ssipadauto(62);

@implementation LevelCompleteScene

+ (id) nodeWithStats: (UserData*) stats world:(NSString *)world level:(int)level {
    return [[[self alloc] initWithStats: stats world: world level: level] autorelease];
}

- (id) initWithStats: (UserData *) stats world:(NSString *)theWorld level:(int)theLevel {
    self = [super init];
    if (self) {
        // Allow user to advance to the next level
        BOOL newLevelAcheived = [stats setLevel:theWorld level:theLevel+1];
        
        [self loadSpriteSheets];
        scores = [[CCArray alloc] initWithCapacity: 5];
        
        screenSize = [[CCDirector sharedDirector] winSize];
        
        content = [CCNode node];
        content.contentSize = screenSize;
        content.position = CGPointZero;
        [self addChild:content z:1];
        
        scoreSheet = [CCNode node];
        scoreSheet.contentSize = screenSize;
        scoreSheet.position = CGPointZero;
        [content addChild:scoreSheet z:2];
        
        scoreCardMessage = [CCLabelBMFont labelWithString:@"" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        scoreCardMessage.scale = ssipad(0.8f, 0.7f);
        scoreCardMessage.opacity = 0;
        scoreCardMessage.anchorPoint = ccp(0,0.5);
        [scoreSheet addChild:scoreCardMessage z:5];
        
        /*msgEffects = [HappyStars particleWithFile:@"dustParticles.plist"];
        msgEffects.anchorPoint = ccp(0,0.5);
        msgEffects.scale = ssipadauto(0.625);
        msgEffects.position = CGPointZero;
        [scoreSheet addChild: msgEffects z:10];*/
        
        logoPos = ccp(ssipad(260, 130), ssipad(400, 151));
        ropeLength = ssipad(270, 135);
        angleInc = 2.5;
        
        // shadow
        shadow = [CCLayerColor getFullScreenLayerWithColor:ccc4(0, 0, 0, 10)];
        shadow.anchorPoint = CGPointZero;
        shadow.position = CGPointZero;
        [self addChild:shadow z:-1];
        
        background = [CCSprite spriteWithFile:ssipad(@"TempTitleBGiPad.png", @"TempTitleBG.png")];
        background.scaleX = screenSize.width/[background boundingBox].size.width + 0.1;
        background.scaleY = screenSize.height/[background boundingBox].size.height + 0.1;
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild:background z:-2];
        
        [self scrollBackground: background];
        
        logo = [CCSprite spriteWithFile:@"SwingStarLogo.png"];
        logo.position = logoPos;
        logo.opacity = 0;
        [self addChild:logo z:1];
        
        logoTrail = [PlayerTrail particleWithFile:@"playerTrail.plist"];
        logoTrail.scale = ssipad(2.5f, 1.5f);
        logoTrail.position = logo.position;
        [self addChild:logoTrail z:-1];
        
        // world label
        world = [CCLabelBMFont labelWithString:theWorld fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        world.scale = 1.25f;
        world.anchorPoint = ccp(0,1);
        world.color = CC3_COLOR_ORANGE;
        world.position = ccp(ssipad(240, 120), ssipad(760, 310));
        [content addChild: world];
        
        // Time and Score
        CCLabelBMFont * timeLabel = [CCLabelBMFont labelWithString:@"Time:" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        timeLabel.anchorPoint = ccp(1,0.5);
        timeLabel.position = ccp(ssipad(220, 110),ssipad(600, 250));
        [content addChild: timeLabel];
        
        const int gapX = ssipadauto(10);
        const int gapY = ssipadauto(32);
        
        unsigned long playTimeSecs = stats.currentTime;
        
        time = [CCLabelBMFont labelWithString:[self formatTime: playTimeSecs] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        time.anchorPoint = ccp(0,0.5);
        time.position = ccp(timeLabel.position.x + gapX, timeLabel.position.y);
        [content addChild: time];
        
        CGPoint bestTimePosition = ccp(timeLabel.position.x, timeLabel.position.y - gapY);
        unsigned long theBestTime = [stats getBestTime:theWorld level:theLevel];
        BOOL bestTimeAchieved = [stats isBestTime:theWorld level: theLevel];
        NSString * bestTimeString = @"New Best Time!";
        
        if (!bestTimeAchieved) {
            bestTimeString = [self formatTime: theBestTime];
            
            CCLabelBMFont * bestTimeLabel = [CCLabelBMFont labelWithString:@"Best:" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
            bestTimeLabel.color = CC3_COLOR_CANTALOPE;
            bestTimeLabel.anchorPoint = ccp(1,0.5);
            bestTimeLabel.scale = 0.55f;
            bestTimeLabel.position = bestTimePosition;
            [content addChild:bestTimeLabel];
        } else {
            [stats setBestTime:theWorld level:theLevel];
            CCSprite *bestTimeImg = [CCSprite spriteWithFile:@"highscore.png"];
            bestTimeImg.anchorPoint = ccp(0,0.5);
            bestTimeImg.scale = 0.3;
            bestTimeImg.position = ccp(bestTimePosition.x + ssipadauto(120), bestTimePosition.y+ssipadauto(10));
            [content addChild:bestTimeImg z:-1];
        }
        
        bestTime = [CCLabelBMFont labelWithString:bestTimeString fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        bestTime.color = CC3_COLOR_CANTALOPE;
        bestTime.anchorPoint = ccp(0,0.5);
        bestTime.scale = 0.55f;
        bestTime.position = ccp(bestTimePosition.x + gapX, bestTimePosition.y);
        [content addChild:bestTime];
    
        CCLabelBMFont * scoreLabel = [CCLabelBMFont labelWithString:@"Score:" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        scoreLabel.anchorPoint = ccp(1,0.5);
        scoreLabel.position = ccp(bestTimePosition.x, bestTimePosition.y - gapY);
        [content addChild: scoreLabel];
        
        score = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", stats.currentScore] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        score.anchorPoint = ccp(0,0.5);
        score.position = ccp(scoreLabel.position.x + gapX, scoreLabel.position.y);
        [content addChild: score];
        
        BOOL highScoreAchieved = [stats isHighScore:theWorld level:theLevel];
        unsigned long theHighScore = [stats getHighScore:theWorld level:theLevel];
        CGPoint highScorePosition = ccp(scoreLabel.position.x, scoreLabel.position.y - gapY);
        NSString * highScoreString = @"New High Score!";
        
        if (!highScoreAchieved) {
            highScoreString = [NSString stringWithFormat:@"%d", theHighScore];
            
            CCLabelBMFont * highScoreLabel = [CCLabelBMFont labelWithString:@"Best:" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
            highScoreLabel.color = CC3_COLOR_CANTALOPE;
            highScoreLabel.anchorPoint = ccp(1,0.5);
            highScoreLabel.scale = 0.55f;
            highScoreLabel.position = highScorePosition;
            [content addChild: highScoreLabel];
        } else {
            [stats setHighScore:theWorld level:theLevel];
            CCSprite *highScoreImg = [CCSprite spriteWithFile:@"highscore.png"];
            highScoreImg.anchorPoint = ccp(0,0.5);
            highScoreImg.scale = 0.3;
            highScoreImg.position = ccp(highScorePosition.x + gapX + ssipadauto(120), highScorePosition.y+ssipadauto(10));
            [content addChild:highScoreImg z:-1];
        }
        
        high = [CCLabelBMFont labelWithString:highScoreString fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        high.color = CC3_COLOR_CANTALOPE;
        high.anchorPoint = ccp(0,0.5);
        high.scale = 0.55f;
        high.position = ccp(highScorePosition.x + gapX, highScorePosition.y);
        [content addChild: high];
    
        
        float dividerXPos = high.position.x + ssipadauto(199);
        
        [self drawHorizontalLine: ccp(dividerXPos, highScorePosition.y - ssipad(58, 28))];
        
        // Level label
        level = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Level %d", (theLevel)] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        level.color = CC3_COLOR_BLUE;
        level.scale = 0.80f;
        level.anchorPoint = ccp(0,1);
        level.position = ccp(dividerXPos + ssipadauto(40), world.position.y - ssipad(60, 20));
        [content addChild:level];
        
        float jumpAmt = ssipadauto(30);
        int numTimes = stats.landingBonus;
        
        // Coins section
        CCSprite * coin1 = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin1.anchorPoint = ccp(0.5,0.5);
        coin1.position = ccp(dividerXPos + ssipadauto(22), time.position.y);
        [content addChild: coin1];
        [self moveUpAndDown1:coin1 amount: jumpAmt times:numTimes];
        
        CCSprite * coin2 = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin2.anchorPoint = ccp(0.5,0.5);
        coin2.position = ccp(coin1.position.x + ssipadauto(10), coin1.position.y - ssipadauto(5));
        [content addChild: coin2];
        [self moveUpAndDown2:coin2 amount: jumpAmt times: numTimes];
        
        CCSprite * coin3 = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin3.anchorPoint = ccp(0.5,0.5);
        coin3.position = ccp(coin1.position.x, coin2.position.y - ssipadauto(5));
        [content addChild: coin3];
        [self moveUpAndDown2:coin3 amount: jumpAmt times: numTimes];
        
        coins = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", stats.currentCoins] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        coins.anchorPoint = ccp(0,0.5);
        coins.scale = 0.75f;
        coins.position = ccp(coin2.position.x + ssipadauto(5), coin1.position.y);
        [content addChild: coins z:1];
        
        totalCoins = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", stats.totalCoins] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        totalCoins.color = CC3_COLOR_CANTALOPE;
        totalCoins.anchorPoint = ccp(0,0.5);
        totalCoins.scale = 0.60f;
        totalCoins.position = ccp(coin2.position.x + ssipadauto(5), coin3.position.y - ssipadauto(4));
        [content addChild: totalCoins z:1];
        
        // stars section
        CCSprite * star1 = [CCSprite spriteWithSpriteFrameName:@"Star1.png"];
        star1.anchorPoint = ccp(0.5,0.5);
        star1.position = ccp(dividerXPos + ssipadauto(27), coin3.position.y - gapY - ssipadauto(2));
        [content addChild: star1];
        [self moveUpAndDown2: star1 amount: jumpAmt times:numTimes];
        
        stars = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", stats.totalLives] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        stars.anchorPoint = ccp(0,0.5);
        stars.scale = 0.75f;
        stars.position = ccp(star1.position.x + ssipadauto(10), star1.position.y);
        [content addChild: stars z:1];
        
        /*totalStars = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", stats.totalLives] fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        totalStars.color = CC3_COLOR_CANTALOPE;
        totalStars.anchorPoint = ccp(0,0.5);
        totalStars.scale = 0.60f;
        totalStars.position = ccp(stars.position.x, star1.position.y - ssipadauto(12));
        [content addChild: totalStars z:1];*/
        
        // Store and Play bottom buttons
        store = [GPImageButton controlOnTarget:self andSelector:@selector(store) imageFromFile:@"Button_Store.png"];
        CCLabelBMFont *storeText = [CCLabelBMFont labelWithString:@"STORE" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        store.anchorPoint = ccp(0,0);
        [store setText:storeText];
        store.position = CGPointMake(ssipad(200,90), ssipad(90,45));
        //store.visible = NO;
        [content addChild:store];
        
        play = [GPImageButton controlOnTarget:self andSelector:@selector(play) imageFromFile:@"Button_Play.png"];
        CCLabelBMFont *playText = [CCLabelBMFont labelWithString:@"PLAY" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
        play.anchorPoint = ccp(0,0);
        [play setText:playText];
        play.position = CGPointMake(ssipad(820,screenSize.width-90), ssipad(90, 45));
        //play.visible = NO;
        [content addChild:play];
        
        // starting scores
        /*double s1 = 7;
        double s2 = 6.5;
        double s3 = 6.25;
        double s4 = 6.1;
        double s5 = 6.55;
        
        // calculate bonus olympic scores
        // 1 - Good Landing - weight 1.5
        // 2 - High Percent of Perfect Jumps - weight 0.25
        // 3 - Total Time vs. Best Time - weight 0.25
        // 4 - Number of Tries - weight 0.50
        // 5 - Skip Bonus - weight 0.25
        // 6 - Score vs High Score - weight 0.25
        double bonus = (stats.landingBonus * 0.5) + 
                       (stats.perfectJumpCount/(stats.perfectJumpCount + stats.imperfectJumpCount) * 0.25) + 
                       (bestTimeAchieved ? 0.25 : ((stats.currentTime - theBestTime)/stats.currentTime) * 0.25) +
                       ([self calculateRestartScore: stats.restartCount at: theLevel]) +
                       (stats.skipCount > 0 ? 0.25 : 0) + 
                       (highScoreAchieved ? 0.25 : ((theHighScore - stats.currentScore)/theHighScore) * 0.25);
        
        CCLOG(@"BONUS AMOUNT: %f", bonus);
        
        s1 += bonus;
        s2 += bonus;
        s3 += bonus;
        s4 += bonus;
        s5 += bonus;
        
        highScore = s1;
        
        [scores insertObject:[NSNumber numberWithDouble:s1] atIndex:0];
        [scores insertObject:[NSNumber numberWithDouble:s2] atIndex:1];
        [scores insertObject:[NSNumber numberWithDouble:s3] atIndex:2];
        [scores insertObject:[NSNumber numberWithDouble:s4] atIndex:3];
        [scores insertObject:[NSNumber numberWithDouble:s5] atIndex:4];
        
        [self showScoreCards];*/
        
        [self showNewItems];
        [self cheer];
        // report the score to GameCenter
        [[AchievementManager sharedInstance] reportScoreToGameCenter:@"LB_HighScores" score:stats.currentScore];
        
        if (newLevelAcheived) {
            // check for and display rewards and unlocked items
            
            /*switch ([[UserData sharedInstance] getNumLevelsCompleted]) {
                case 6:
                    // give player extra 2 lives
                    //[self showExtraLives: 2];
                    //break;
                case 12:
                    [self showExtraLives: 2];
                    break;
                default:
                    [self showUnlockedItems: theLevel];
                    break;
            }*/
            [self showUnlockedItems: [stats getNumLevelsCompleted]];
        }
    }

    return self;
}

/*- (void) showExtraLives: (int) numLives {
    
    UserData * userData = [UserData sharedInstance];
    userData.totalLives += numLives;
    
    CCSprite * sprite = [CCSprite spriteWithSpriteFrameName:@"Star1.png"];
    sprite.scale = 2;
    [self showReward: [NSString stringWithFormat: @"Earned %d free life lines", numLives] sprite: sprite store: NO];
}*/

- (void) showUnlockedItems: (unsigned int) currentLevel {
    
    UserData * userData = [UserData sharedInstance];
    StoreManager *storeData = [StoreManager sharedInstance];
    CCSprite * sprite = nil;
    NSString * description = nil;
    BOOL showStoreButton = NO;
    CCArray * powerUps = [storeData powerUpData];
    PowerUpData * unlocked = nil;
    
    for (PowerUpData * puData in powerUps) {
        
        if (puData.level == currentLevel &&
            puData.price > 0.0f &&
            ![userData isPowerUpPurchased: puData.name type: puData.type]) {
            
            unlocked = puData;
            break;
        }
    }
    
    if (unlocked != nil) {
        
        storeData.newItemUnlocked = YES;
        
        sprite = [CCSprite spriteWithFile: unlocked.spriteName];
        sprite.scale = 2;
        description = [NSString stringWithFormat: @"UNLOCKED %@", unlocked.name];
        showStoreButton = YES;
    } else {
        // check for unlocked lives
        
        LifeLineData * unlockedLife = nil;
        CCArray *lifeLines = [storeData lifeLineData];
        
        for (LifeLineData * lData in lifeLines) {
            
            if (lData.level == currentLevel && lData.price == 0.0f) {
                unlockedLife = lData;
                break;
            }
        }
        
        if (unlockedLife != nil) {
            sprite = [CCSprite spriteWithSpriteFrameName:@"Star1.png"];
            description = unlockedLife.description;
            sprite.scale = 2;
            
            UserData * userData = [UserData sharedInstance];
            userData.totalLives += unlockedLife.numLives;
            
        } else {
            // Check for unlocked worlds
            
            WorldData * worldData = nil;
            CCArray *worlds = [storeData worldData];
            
            for (WorldData * wData in worlds) {
                
                if (wData.level == currentLevel &&
                    wData.price > 0.0f &&
                    ![userData isWorldPurchased: wData.name]) {
                    
                    worldData = wData;
                    break;
                }
            }
            
            if (worldData != nil) {
                sprite = [CCSprite spriteWithFile: worldData.spriteName];
                sprite.scale = 0.5;
                description = @"UNLOCKED WORLD!"; //[NSString stringWithFormat: @"UNLOCKED World %@", worldData.name];
            }
        }
    }
    
    if (sprite != nil && description != nil) {
        [self showReward: description sprite: sprite store: showStoreButton];
    }
}

- (void) showReward: (NSString *) name sprite: (CCSprite *) sprite store: (BOOL) showStore {
    
    play.visible = NO;
    store.visible = NO;
    shadow.opacity = 75;
    
    CCLayerColor * unlockedLayer = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_STEEL_BLUE, 225)];
    unlockedLayer.contentSize = CGSizeMake(screenSize.width/2, screenSize.height/2);
    unlockedLayer.anchorPoint = ccp(0.5, 0.5); //self.anchorPoint;
    //unlockedLayer.position = ccp(0,0);
    [self addChild: unlockedLayer z:10 tag:unlockedItemTag];
    
    // Borders
    CCLayerColor * border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_WHITE, 255)];
    border.contentSize = CGSizeMake(unlockedLayer.contentSize.width + 2, 2);
    border.anchorPoint = unlockedLayer.anchorPoint;
    border.position = ccp(0,0);
    [unlockedLayer addChild: border z:1];
    
    border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_WHITE, 255)];
    border.contentSize = CGSizeMake(2, unlockedLayer.contentSize.height + 2);
    border.anchorPoint = unlockedLayer.anchorPoint;
    border.position = ccp(unlockedLayer.contentSize.width, 0);
    [unlockedLayer addChild: border z:1];
    
    border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_WHITE, 255)];
    border.contentSize = CGSizeMake(2, unlockedLayer.contentSize.height + 2);
    border.anchorPoint = unlockedLayer.anchorPoint;
    border.position = ccp(0, 0);
    [unlockedLayer addChild: border z:1];
    
    border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_WHITE, 255)];
    border.contentSize = CGSizeMake(unlockedLayer.contentSize.width + 2, 2);
    border.anchorPoint = unlockedLayer.anchorPoint;
    border.position = ccp(0, unlockedLayer.contentSize.height);
    [unlockedLayer addChild: border z:1];
    
    // add powerup info
    CCLabelBMFont *text = [CCLabelBMFont labelWithString: name fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
    text.position = ccp(unlockedLayer.contentSize.width/2, (unlockedLayer.contentSize.height - ssipadauto(10) - text.contentSize.height/2));
    //text.scale = 0.5f;
    [unlockedLayer addChild: text z:2];
    
    sprite.position = ccp(unlockedLayer.contentSize.width/2, unlockedLayer.contentSize.height/2 + ssipadauto(10));
    sprite.rotation = -10;
    [unlockedLayer addChild: sprite z:2];
    
    HappyStars * fx = [HappyStars particleWithFile:@"hotBall.plist"];
    //fx.anchorPoint = ccp(0,0.5);
    fx.scale = ssipadauto(0.85); //ssipadauto(0.25);
    fx.position = ccp(unlockedLayer.contentSize.width/2, unlockedLayer.contentSize.height/2 + ssipadauto(10));
    [unlockedLayer addChild: fx z:3];
    //msgEffects.position = ccp(scoreCardMessage.position.x + ssipadauto(70), scoreCardMessage.position.y);
    //[self showMessageEffect];
    fx.visible = YES;
    [fx resetSystem];
    
    if (showStore) {
        GPImageButton *viewStoreBtn = [GPImageButton controlOnTarget:self andSelector:@selector(storePowerups) imageFromFile:@"Button_Store.png"];
        CCLabelBMFont *viewStoreText = [CCLabelBMFont labelWithString:@"View in Store" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        viewStoreText.scale = 1.25;
        [viewStoreBtn setText:viewStoreText];
        //viewStoreBtn.anchorPoint = ccp(0.5, 0.5);
        viewStoreBtn.position = ccp(unlockedLayer.contentSize.width/2, ssipadauto(30) + viewStoreBtn.contentSize.height);
        viewStoreBtn.scale = 0.6;
        [unlockedLayer addChild:viewStoreBtn z:2];
    }
    
    GPImageButton *closeBtn = [GPImageButton controlOnTarget:self andSelector:@selector(closeUnlockedItems) imageFromFile:@"plusButton.png"];
    //closeBtn.scale = 0.5;
    closeBtn.rotation = 45;
    closeBtn.position = ccp(unlockedLayer.contentSize.width, unlockedLayer.contentSize.height);
    [unlockedLayer addChild:closeBtn z:2];
    
    id ease;
    
    // Randomize where it comes from to add some spice
    /*int chance = arc4random() % 4;
     if (chance == 0) {
     unlockedLayer.position = CGPointMake(0, -(screenSize.height + unlockedLayer.contentSize.height/2));
     }
     else if (chance == 1) {
     unlockedLayer.position = CGPointMake(0, (screenSize.height + unlockedLayer.contentSize.height/2));
     }
     else if (chance == 2) {*/
    unlockedLayer.position = CGPointMake((screenSize.width + unlockedLayer.contentSize.width/2), screenSize.height/2);
    /*}
     else if (chance == 3) {
     unlockedLayer.position = CGPointMake((screenSize.width + unlockedLayer.contentSize.width/2), 0);
     }*/
    
    CCDelayTime * delay = [CCDelayTime actionWithDuration:0.25];
    ease = [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:0.6
                                                                     position:CGPointMake(screenSize.width/2-unlockedLayer.contentSize.width/2, screenSize.height/2-unlockedLayer.contentSize.height/2)]];
    id moveRight1 = [CCMoveBy actionWithDuration:0.1 position: ccp(ssipadauto(5), 0)];
    id moveLeft1 = [CCMoveBy actionWithDuration:0.1 position: ccp(ssipadauto(-10), 0)];
    id moveRight2 = [CCMoveBy actionWithDuration:0.1 position: ccp(ssipadauto(7.5), 0)];
    id moveLeft2 = [CCMoveBy actionWithDuration:0.1 position: ccp(ssipadauto(-5), 0)];
    id moveRight3 = [CCMoveBy actionWithDuration:0.1 position: ccp(ssipadauto(2.5), 0)];
    id spin = [CCRotateBy actionWithDuration:0.8 angle:720];
    
    [unlockedLayer runAction:[CCSequence actions: delay,[CCSpawn actions: spin, [CCSequence actions: ease, moveRight1, moveLeft1, moveRight2, moveLeft2, moveRight3, nil], nil],nil]];
    
    float currentScale = sprite.scale;
    
    id scaleUp = [CCScaleTo actionWithDuration:0.5 scale:currentScale + 0.05f];
    id scaleDown = [CCScaleTo actionWithDuration:0.5 scale:currentScale - 0.05f];
    
    [sprite runAction: [CCRepeatForever actionWithAction:[CCSequence actions: scaleUp, scaleDown, nil]]];
}

- (void) showNewItems {
    
    [store removeChildByTag:NEW_ITEM_TAG cleanup:YES];
    if ([StoreManager sharedInstance].newItemUnlocked) {
        
        CCSprite * newSprite = [CCSprite spriteWithFile:@"new.png"];
        newSprite.scale = 0.75;
        newSprite.position = ccp(ssipadauto(60),
                                 ssipadauto(20));
        [store addChild: newSprite z:2 tag:NEW_ITEM_TAG];
    }
}

- (void) closeUnlockedItems {
    
    [self showNewItems];
    store.visible = YES;
    play.visible = YES;
    shadow.opacity = 10;
    
    [self removeChildByTag: unlockedItemTag cleanup: YES];
}

- (double) calculateRestartScore: (unsigned long) restartCount at: (unsigned long) theLevel {
    double rScore = 0;
    
    rScore = 0;
    
    if (theLevel <= 5) {
        if (restartCount <= 1) {
            rScore = 0.5;
        } else if (restartCount <= 2) {
            rScore = 0.25;
        }
    } else if (theLevel <= 10) {
        if (restartCount <= 3) {
            rScore = 0.5;
        } else if (restartCount <= 4) {
            rScore = 0.25;
        }
    } else if (theLevel <= 20) {
        if (restartCount <= 4) {
            rScore = 0.5;
        } else if (restartCount <= 6) {
            rScore = 0.25;
        }
    }
    
    return rScore;
}

- (NSString *) formatTime: (unsigned long) timeInSecs {
    int minutes  = timeInSecs/60;
    int seconds  = timeInSecs%60;
    
    NSString *minuteStr = [NSString stringWithFormat:@"%d",minutes];
    NSString *secondStr  = [NSString stringWithFormat:@"%d", seconds];
    
    if (minutes < 10) {
        minuteStr = [NSString stringWithFormat:@"0%d", minutes];
    }
    
    if (seconds < 10) {
        secondStr = [NSString stringWithFormat:@"0%d", seconds];
    }
    
    return [NSString stringWithFormat:@"%@:%@", minuteStr, secondStr];
}

- (void) scrollBackground: (CCSprite *) theBackground {
    float duration = 20;
    float moveAmt = [theBackground boundingBox].size.width - screenSize.width;
    
    theBackground.position = ccp(0,0);
    
    if (moveAmt > 0) {
        
        CCMoveBy * scrollRight = [CCMoveBy actionWithDuration:duration position: ccp(theBackground.position.x - moveAmt, 0)];
        CCScaleTo * scaleUp = [CCScaleBy actionWithDuration:duration scale:1.25f];
        CCSpawn * spawn1 = [CCSpawn actionOne:scrollRight two:scaleUp];
        
        [theBackground stopAllActions];
        [theBackground runAction: [CCRepeatForever actionWithAction:[CCSequence actions:spawn1, [spawn1 reverse], nil]]];
    }
}

- (void) moveUpAndDown1: (CCSprite*) sprite amount: (float) amount times: (int) times {

    CCMoveBy * moveUpLarge = [CCMoveBy actionWithDuration:.25f position:ccp(0,amount)];
    CCCallFunc * playBlop = [CCCallFunc actionWithTarget:self selector:@selector(playBlop)];
    CCDelayTime * wait = [CCDelayTime actionWithDuration:0.5f];
    CCMoveBy * moveDownLarge = [CCMoveBy actionWithDuration:0.1f position:ccp(0,-amount)];
    CCMoveBy * moveUp = [CCMoveBy actionWithDuration:0.15f position:ccp(0,-amount*.75f)];
    CCMoveBy * moveDown = [CCMoveBy actionWithDuration:0.15f position:ccp(0,amount*.75f)];
    CCSequence * seq = [CCSequence actions: moveUpLarge, wait, moveDownLarge, playBlop, moveUp, moveDown, moveUp, moveDown, wait,/*moveUp, moveDown,*/ nil];
    
    CCRepeat * repeat = [CCRepeat actionWithAction: seq times:times];
    CCSpeed  * speedUp = [CCSpeed actionWithAction:repeat speed:ssipad(3,4)];
    [sprite stopAllActions];
    [sprite runAction: speedUp];
}

- (void) moveUpAndDown2: (CCSprite*) sprite amount: (float) amount times: (int) times {
    
    CCDelayTime * wait = [CCDelayTime actionWithDuration:.85f];
    CCDelayTime * wait2 = [CCDelayTime actionWithDuration:0.5f];
    CCMoveBy * moveUp = [CCMoveBy actionWithDuration:0.15f position:ccp(0,-amount*.75f)];
    CCMoveBy * moveDown = [CCMoveBy actionWithDuration:0.15f position:ccp(0,amount*.75f)];
    CCSequence * seq = [CCSequence actions: wait, moveUp, moveDown, moveUp, moveDown, wait2,/*moveUp, moveDown,*/ nil];
    
    CCRepeat * repeat = [CCRepeat actionWithAction: seq times:times];
    CCSpeed  * speedUp = [CCSpeed actionWithAction:repeat speed:ssipad(3,4)];
    [sprite stopAllActions];
    [sprite runAction: speedUp];
}

- (void) cheer {
    
    NSString * spriteName = @"gonzoCheer_5.png";
    CCSprite * gonzo = [CCSprite spriteWithSpriteFrameName:spriteName];
    gonzo.position = ccp(screenSize.width/2, ssipadauto(40));
    [self addChild: gonzo z:0];
    
    CGPoint jumpDistance = ccp(ssipadauto(10),ssipadauto(50));
    id animate = [CCAnimate actionWithAnimation: [[CCAnimationCache sharedAnimationCache] animationByName:@"gonzoCheerAnimation"] restoreOriginalFrame:NO];
    id wait = [CCDelayTime actionWithDuration:0.25];
    id moveUp = [CCEaseSineOut actionWithAction:[CCMoveBy actionWithDuration:0.5 position:jumpDistance]];
    id jump = [CCSpawn actions: moveUp, wait, animate, nil];
    id fall = [CCEaseSineIn actionWithAction:[CCMoveBy actionWithDuration:0.25 position:ccp(-jumpDistance.x, -jumpDistance.y)]];
    id stand = [CCDelayTime actionWithDuration:0.1];
    id seq = [CCSequence actions: jump, fall, stand, nil];
    
    id cheering = [CCRepeatForever actionWithAction: seq];
    [gonzo runAction: cheering];
    
    
}

- (void) showScoreCards {
    
    CCSprite * elephantSprite = [CCSprite spriteWithSpriteFrameName:@"ElephantWalk1.png"];
    elephantSprite.anchorPoint = ccp(1,0);
    elephantSprite.position = ssipad(ccp(-50,20), ccp(-25,10));
    elephantSprite.flipX = YES;
    [self addChild: elephantSprite z:0];
    
    id action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"elephantWalkAnimation"] restoreOriginalFrame:NO];
    id walkingAction = [CCRepeatForever actionWithAction:action];
    id walkSpeedAction = [CCSpeed actionWithAction:walkingAction speed:1.2f];
    [elephantSprite runAction:walkSpeedAction];
    
    
    CCDelayTime * wait = [CCDelayTime actionWithDuration:1.f];
    CCCallFunc  * shake = [CCCallFunc actionWithTarget:self selector:@selector(shake)];
    CCMoveBy    * runAcross = [CCMoveBy actionWithDuration:6.f position:ccp(screenSize.width + [elephantSprite boundingBox].size.width + ssipadauto(15), 0)];
    CCFadeOut   * fadeOut = [CCFadeOut actionWithDuration:0.1];
    CCSequence * seq = [CCSequence actions: wait, shake, runAcross, fadeOut, nil];
    
    [elephantSprite runAction:seq];
    
    CCDelayTime * shortWait = [CCDelayTime actionWithDuration:0.5f];
    CCCallFunc * showCard = [CCCallFunc actionWithTarget:self selector:@selector(showCard)];
    CCCallFunc * showButtons = [CCCallFunc actionWithTarget:self selector:@selector(showButtons)];
    CCCallFunc * showMsg = [CCCallFunc actionWithTarget:self selector:@selector(showMessage)];
    
    cardNum = 0;
    [self runAction:[CCSequence actions: wait, showCard, shortWait, showCard, shortWait, showCard, shortWait, showCard, shortWait, showCard, shortWait, showButtons, showMsg, nil]];
}

- (void) showButtons {
    store.visible = YES;
    play.visible = YES;
}

- (void) showMessage {
    
    CCMoveBy * move = [CCMoveBy actionWithDuration:0.2 position:ccp(ssipad(-170, -90), 0)];
    CCCallFunc * call = [CCCallFunc actionWithTarget:self selector:@selector(showScoreMessage)];
    
    [scoreSheet stopAllActions];
    [scoreSheet runAction: [CCSequence actions: move, call, nil]];
}

- (void) showScoreMessage {
    
    NSString * msg = @"Solid!";
    
    if (CCRANDOM_MINUS1_1() == 1) {
        msg = @"Swing On!";
    }
    
    if (highScore > 7.5) {
        if (highScore < 8.4) {
            if (CCRANDOM_MINUS1_1() < 0) {
                msg = @"Smoooth!";
            } else {
                msg = @"Nice Swing!";
            }
        } else if (highScore < 9.0) {
            if (CCRANDOM_MINUS1_1() < 0) {
                msg = @"Way To Go!";
            } else {
                msg = @"Awesome!";
            }
        } else if (highScore < 9.4) {
            if (CCRANDOM_MINUS1_1() < 0) {
                msg = @"Swingtastic!";
            } else {
                msg = @"Super Swing!";
            }
        } else {
            if (CCRANDOM_MINUS1_1() < 0) {
                msg = @"WOOOHOOOO!";
            } else {
                msg = @"SWING GURU!";
            }
        }
    }
    
    CGPoint point = ssipad(ccp(separator.position.x + 2,250), ccp(separator.position.x,106));

    scoreCardMessage.position = ccp(point.x + ssipad(180,90), point.y);
    [scoreCardMessage setString: msg];
    CCFadeIn * fadeIn = [CCFadeIn actionWithDuration:0.1];
    [scoreCardMessage stopAllActions];
    [scoreCardMessage runAction: fadeIn];
    
    msgEffects.position = ccp(scoreCardMessage.position.x + ssipadauto(70), scoreCardMessage.position.y);
    [self showMessageEffect];
}

- (void) showCard {
    //int i = 0;
    CGPoint point = ssipad(ccp(250+(cardNum*2*cardDistance),250), ccp(125+(cardNum*cardDistance),106));
    [self showCard: [[scores objectAtIndex:cardNum] doubleValue] at: point];
    cardNum++;
}

- (void) showCard: (double) theScore at: (CGPoint) pos {
    // Cards fall down from above because of all the shaking
    LevelCompleteScoreCard * scoreCard = [LevelCompleteScoreCard nodeWithScore:theScore];
    [scoreSheet addChild: scoreCard z:4];
    [scoreCard moveTo: pos];
}

- (void) drawHorizontalLine: (CGPoint) pos {
    ccColor4B lineColor = ccc4(255, 165, 0, 255);
    
    separator = [CCLayerColor layerWithColor:lineColor];
    separator.anchorPoint = ccp(0,1);
    [separator setContentSize:CGSizeMake(4,ropeLength-ssipad(0,15))];
    
    separator.position = ccp(pos.x, pos.y + ssipad(0,15));
    [content addChild: separator z:2];
    
    rope = [CCLayerColor layerWithColor:lineColor];
    rope.anchorPoint = ccp(0,1);
    [rope setContentSize:CGSizeMake(2, ropeLength)];

    rope.position = ccp(pos.x - ssipadauto(155), pos.y);
    rope.rotation = 0;
    rope.opacity = 0;
    [self addChild: rope z:2];
    
    cap = [CCSprite spriteWithSpriteFrameName:@"SwingPoleTop1.png"];
    cap.position = ccp(rope.position.x, rope.position.y + ropeLength);
    cap.opacity = 0;
    [self addChild: cap z:3];
    
    handle = [CCSprite spriteWithSpriteFrameName:@"SwingPoleTop1.png"];
    handle.scale = 0.5;
    handle.opacity = 0;
    handle.position = ccp(logoPos.x + (rope.position.x - logoPos.x) + 1, logoPos.y - ssipadauto(25));
    [self addChild: handle z:3];
    
    float anchorX = 0.5 + ((rope.position.x - logoPos.x + 1)/[logo boundingBox].size.width);
    float anchorY = 0.5 - (ssipadauto(25)/[logo boundingBox].size.height);
    
    logo.anchorPoint = ccp(anchorX, anchorY);
    logo.position = handle.position;
    
    pole = [CCSprite spriteWithSpriteFrameName:@"SwingPole1.png"];
    pole.anchorPoint = ccp(0.5,1);
    pole.scaleY = ssipad(0.95f, 0.8f);
    pole.position = ccp(cap.position.x, cap.position.y - [cap boundingBox].size.height/2);
    pole.opacity = 0;
    [self addChild: pole z:0];
}

- (void) onEnter {
    CCLOG(@"**** LevelCompleteScene onEnter");
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    
    if (![[AudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[AudioEngine sharedEngine] setBackgroundMusicVolume:[UserData sharedInstance].musicVolumeLevel];
        [[AudioEngine sharedEngine] playBackgroundMusic:MENU_MUSIC loop:YES];
    }
    [super onEnter];
}

- (void) onExit {
    CCLOG(@"**** LevelCompleteScene onExit");
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [self stopAllActions];
    [self unscheduleAllSelectors];
	[super onExit];
}

#pragma mark - Touch Handling
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //play.visible = YES;
    //store.visible = YES;
    
    return YES;
}

- (void) playBlop {
    [[AudioEngine sharedEngine] playEffect:SND_BLOP gain:0.8f];
}

- (void) playAah {
    [[AudioEngine sharedEngine] stopBackgroundMusic];
    [[AudioEngine sharedEngine] playEffect:SND_CHILDREN_AAH];
}

- (void) playCheer {
    [[AudioEngine sharedEngine] playEffect:SND_CHEER];
}

- (void) playWind {
    [[AudioEngine sharedEngine] playEffect:SND_WIND];
}

- (void) play {
    //[self doSwing];
    [self goToSelectLevel];
}

- (void) store {
    //[[AudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreScene node]]];
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLoadingScene nodeWithDelay:3 goTo:kGoToSceneStore]]];
}

- (void) storePowerups {
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreScene nodeWithScreen:kStorePowerUpType]]];
}

- (void) goToSelectLevel {
    [[AudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.f scene:[LevelSelectScene nodeWithWorld: world.string]]];
}

- (void) doSwing {
    // Fade out separator into a rope
    float fadeDur = .85f;
    
    CCMoveBy * moveForwardScore = [CCMoveBy actionWithDuration:0.1 position:ccp(25, 0)];
    CCCallFunc * playWind = [CCCallFunc actionWithTarget:self selector:@selector(playWind)];
    CCMoveBy * moveOutScore = [CCMoveBy actionWithDuration:fadeDur-0.3 position:ccp(-(screenSize.width + ssipadauto(30)), 0)];
    CCCallFunc * playAah = [CCCallFunc actionWithTarget:self selector:@selector(playAah)];
    
    [content stopAllActions];
    [content runAction:[CCSequence actions: moveForwardScore, playWind, moveOutScore, playAah, nil]];
    
    CCFadeOut * fadeOutSep = [CCFadeOut actionWithDuration:fadeDur];
    [separator stopAllActions];
    [separator runAction: fadeOutSep];
    
    CCFadeOut * fadeOutShadow = [CCFadeOut actionWithDuration:fadeDur];
    [shadow stopAllActions];
    [shadow runAction: fadeOutShadow];
    
    CCFadeIn * fadeInRope = [CCFadeIn actionWithDuration:fadeDur];
    [rope stopAllActions];
    [rope runAction: fadeInRope];
    
    CCFadeIn * fadeInHandle = [CCFadeIn actionWithDuration:fadeDur];
    [handle stopAllActions];
    [handle runAction: fadeInHandle];
    
    CCFadeIn * fadeInCap = [CCFadeIn actionWithDuration:fadeDur];
    [cap stopAllActions];
    [cap runAction: fadeInCap];
    
    CCFadeIn * fadeInPole = [CCFadeIn actionWithDuration:fadeDur];
    [pole stopAllActions];
    [pole runAction: fadeInPole];
    
    CCFadeIn * fadeInLogo = [CCFadeIn actionWithDuration:fadeDur];
    CCCallFunc * doSwing = [CCCallFunc actionWithTarget:self selector:@selector(scheduleSwing)];
    [logo stopAllActions];
    [logo runAction:[CCSequence actions: fadeInLogo, doSwing, nil]];
}

- (void) showMessageEffect {
    msgEffects.visible = YES;
    [msgEffects resetSystem];
}

- (void) hideMessageEffect {
    msgEffects.visible = NO;
    [msgEffects stopSystem];
}

- (void) showTrail {
    logoTrail.visible = YES;
    [logoTrail resetSystem];
}

- (void) hideTrail {
    logoTrail.visible = NO;
    [logoTrail stopSystem];
}

- (void) scheduleSwing {

    //[self showTrail];
    [background stopAllActions];
    
    // swing the logo off screen and move to next scene
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(swingLogo) forTarget:self interval:0.005 paused:NO];
}

- (void) swingLogo {
    
    rope.rotation += angleInc;
    float angleDegs = 90 - rope.rotation;
    float angle = CC_DEGREES_TO_RADIANS(angleDegs);
    CGPoint origin = ccp(logoPos.x, logoPos.y + ropeLength);
    
    float xPos = (origin.x - (ropeLength*cosf(angle))) + ((rope.position.x - logoPos.x) + 1);
    float yPos = (origin.y - (ropeLength*sinf(angle))) - ssipadauto(25);
    
    handle.position = ccp(xPos, yPos);
    logo.position = handle.position;
    logo.rotation = rope.rotation;
    logoTrail.position = logo.position;
    
    if (rope.rotation > maxAngle) {
        angleInc += 2; // move faster on the way back
        angleInc *= -1;
        
        [self showTrail];
        [[AudioEngine sharedEngine] playEffect:SND_SWOOSH];
    } else if (rope.rotation < -maxAngle) {
        // unschedule swinging and toss logo off screen
        [[CCScheduler sharedScheduler] unscheduleSelector:@selector(swingLogo) forTarget:self];
        
        CCMoveBy * toss = [CCMoveBy actionWithDuration:0.55 position:ccp(ssipad(600,300),ssipad(150,0))];
        CCMoveBy * tossTrail = [CCMoveBy actionWithDuration:0.55 position:ccp(ssipad(600,300),ssipad(150,0))];
        CCCallFunc * fadeTrail = [CCCallFunc actionWithTarget:self selector:@selector(hideTrail)];
        CCCallFunc * playCheer = [CCCallFunc actionWithTarget:self selector:@selector(playCheer)];
        CCCallFunc * goToNextScene = [CCCallFunc actionWithTarget:self selector:@selector(goToSelectLevel)];
        
        CCRotateBy * rotateBy = [CCRotateBy actionWithDuration:0.5 angle:-360];
        CCRepeat * rotate = [CCRepeat actionWithAction:rotateBy times:3.f];
        
        [logo stopAllActions];
        [logo runAction:rotate];
        [logo runAction:[CCSequence actions: toss, playCheer, goToNextScene, nil]];
        [logoTrail stopAllActions];
        [logoTrail runAction:[CCSequence actions: tossTrail, fadeTrail, nil]];
    }
}

- (void) loadSpriteSheets {    

    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:[GPUtil getAtlasImageName:CHARACTER_ATLAS]];        
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[GPUtil getAtlasPList:CHARACTER_ATLAS] texture:tex];
    [tex setAliasTexParameters];
    
    // elephant walk animation
    /*{
        NSMutableArray *elephantFrames = [NSMutableArray array];
        for (int i=1; i <= 6; i++){
            NSString *file = [NSString stringWithFormat:@"ElephantWalk%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [elephantFrames addObject:frame];
        }
        
        CCAnimation *animElephant = [CCAnimation animationWithFrames:elephantFrames delay:.0833f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animElephant name:@"elephantWalkAnimation"];
    }*/
    
    // TODO - select animation based on the character the user has selected
    // gonzo cheering
    {
        NSMutableArray *cheerFrames = [NSMutableArray array];
        for (int i=1; i <= 5; i++){
            NSString *file = [NSString stringWithFormat:@"gonzoCheer_%d.png", i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [cheerFrames addObject:frame];
        }
        
        CCAnimation *animCheer = [CCAnimation animationWithFrames:cheerFrames delay:.0733f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animCheer name:@"gonzoCheerAnimation"];
    }
}

- (void) shake {
    shakeFactor = ssipadauto(2.5);
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(doShake:) forTarget:self interval:0.01 paused:NO];
    [[CCScheduler sharedScheduler] scheduleSelector : @selector(stopShake) forTarget:self interval:shakeDuration paused:NO];
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
    self.position = ccp(0,0);
}

- (void) dealloc {
    
    [self unscheduleAllSelectors];
    [self stopAllActions];
    
    [scores removeAllObjects];
    [scores release];
    
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
